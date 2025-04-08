import codeql.util.Boolean
import codingstandards.cpp.RestrictedRangeAnalysis
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis as SimpleRangeAnalysis

predicate exprMayEqualZero(Expr e) {
  RestrictedRangeAnalysis::upperBound(e) >= 0 and
  RestrictedRangeAnalysis::lowerBound(e) <= 0 and
  not guardedNotEqualZero(e)
}

newtype TFPClassification =
  TFinite() or
  TNaN() or
  TInfinite()

class FPClassification extends TFPClassification {
  string toString() {
    this = TFinite() and
    result = "finite"
    or
    this = TNaN() and
    result = "NaN"
    or
    this = TInfinite() and
    result = "infinite"
  }
}

newtype TFPClassificationConstraint =
  /* The value may be infinite, NaN, or finite. */
  TUnclassified() or
  /**
   * The value must be one of: infinite, NaN, or finite.
   *
   * If strict is `true` then this inverts naively. For example, `!isfinite(x)` means `x` must not
   * be finite. However, `!iszero(x)` is true for some finite values, and inverts to
   * `TUnclassified`.
   */
  TExactFPClassification(TFPClassification cls, Boolean strict) or
  /* The value must not be one of: infinite, NaN, or finite. */
  TExcludeFPClassification(TFPClassification cls1)

class FPClassificationConstraint extends TFPClassificationConstraint {
  string toString() {
    this = TUnclassified() and
    result = "unclassified"
    or
    exists(FPClassification cls, Boolean strict |
      this = TExactFPClassification(cls, strict) and
      result = "must be " + cls.toString() + ", strict: " + strict.toString()
      or
      this = TExcludeFPClassification(cls) and
      result = "must NOT be " + cls.toString()
    )
  }

  /**
   * Invert the constraint, for instance, "must be finite" becomes "must not be finite".
   *
   * Non-strict exact constraints are inverted to the unclassified constraint. For example,
   * `iszero(x)` guarantees `x` to be finite, however, `!iszero(x)` can be true for all three
   * classes of floating point values.
   *
   * The unclassified constraint inverts to itself.
   */
  FPClassificationConstraint invert() {
    // Unclassified inverts to itself.
    this = TUnclassified() and result = this
    or
    exists(FPClassification cls |
      // `!isfinite()` implies is infinite or NaN.
      this = TExactFPClassification(cls, true) and
      result = TExcludeFPClassification(cls)
      or
      // `!iszero()` implies nothing.
      this = TExactFPClassification(cls, false) and
      result = TUnclassified()
      or
      // For completeness: `!isfinite(x) ? ... : x` would imply `isfinite(x)`.
      this = TExcludeFPClassification(cls) and
      result = TExactFPClassification(cls, true)
    )
  }

  /**
   * Naively invert the constraint, for instance, "must be finite" becomes "must not be finite".
   *
   * Word of caution: inverting a guard condition does not necessarily invert the constraint. For
   * example, `iszero(x)` guarantees `x` to be finite, however, `isnotzero(x)` does not guarantee
   * `x` not to be finite.
   *
   * The unclassified constraint is not inverted.
   */
  FPClassificationConstraint naiveInversion() {
    this = TUnclassified() and result = this
    or
    exists(FPClassification cls |
      this = TExactFPClassification(cls, _) and
      result = TExcludeFPClassification(cls)
      or
      this = TExcludeFPClassification(cls) and
      result = TExactFPClassification(cls, true)
    )
  }

  predicate mustBe(FPClassification cls) { this = TExactFPClassification(cls, _) }

  predicate mustNotBe(FPClassification cls) {
    this = TExcludeFPClassification(cls)
    or
    this = TExactFPClassification(_, _) and
    not this = TExactFPClassification(cls, _)
  }

  predicate mayBe(FPClassification cls) { not mustNotBe(cls) }
}

/**
 * The names of the functions or macros that classify floating point values.
 *
 * These names reflect a check that a value is finite, or infinite, or NaN. Finite and NaN checks
 * are either strict (return true for all values in the class) or not (return true for some
 * values).
 *
 * The infinite check is always strict, and specially, returns 1 or -1 for positive or negative
 * infinity.
 */
newtype TFPClassifierName =
  TClassifiesFinite(string name, boolean strict) {
    strict = true and
    name = ["finite" + ["", "l", "f"], "isfinite"]
    or
    strict = false and
    name = ["isnormal", "issubnormal", "iszero"]
  } or
  TClassifiesNaN(string name, boolean strict) {
    strict = true and
    name = "isnan" + ["", "f", "l"]
    or
    strict = false and
    name = "issignaling"
  } or
  TClassifiesInfinite(string name) { name = "isinf" + ["", "f", "l"] }

class FPClassifierName extends TFPClassifierName {
  string name;
  boolean strict;

  FPClassifierName() {
    this = TClassifiesFinite(name, strict)
    or
    this = TClassifiesInfinite(name) and
    strict = true
    or
    this = TClassifiesNaN(name, strict)
  }

  string toString() { result = name }

  /** The classification name, for instance, "isfinite". */
  string getName() { result = name }

  /**
   * Whether the check holds for all values in the class, or only some.
   *
   * For instance, "isfinite" is strict because it returns true for all finite values, but
   * "isnormal" is not as it returns false for some finite values.
   */
  predicate isStrict() { strict = true }

  FPClassificationConstraint getConstraint() {
    this = TClassifiesFinite(_, strict) and
    result = TExactFPClassification(any(TFinite t), strict)
    or
    this = TClassifiesNaN(_, strict) and
    result = TExactFPClassification(any(TNaN t), strict)
    or
    this = TClassifiesInfinite(_) and
    // TODO: isinf() is special
    result = TExactFPClassification(any(TInfinite t), false)
  }
}

/**
 * An invocation of a classification function, for instance, "isfinite(x)", implemented as a macro.
 */
class FPClassifierMacroInvocation extends MacroInvocation {
  FPClassifierName classifier;

  FPClassifierMacroInvocation() { getMacroName() = classifier.getName() }

  Expr getCheckedExpr() {
    // Getting the checked expr in a cross-platform way is extroardinarily difficult, as glibc has
    // multiple conditional implementations of the same macro. Assume the checked expr is a
    // variable access so we can search optimistically like so:
    exists(VariableAccess va |
      va.getTarget().getName() = getExpandedArgument(0) and
      va = getAnExpandedElement() and
      result = va
    )
  }

  /**
   * The classification name, for instance, "isfinite".
   */
  FPClassifierName getFPClassifierName() { result = classifier }
}

/**
 * A classification function, for instance, "isfinite", when implemented as a function.
 */
class FPClassifierFunction extends Function {
  FPClassifierName classifier;

  FPClassifierFunction() { getName() = classifier.getName() }

  FPClassifierName getFPClassifierName() { result = classifier }
}

class FPClassificationGuard instanceof GuardCondition {
  Expr floatExpr;
  Expr checkResultExpr;
  FPClassifierName classifier;

  FPClassificationGuard() {
    super.comparesEq(checkResultExpr, _, _, _) and
    (
      exists(FPClassifierMacroInvocation m |
        floatExpr = m.getCheckedExpr() and
        checkResultExpr = m.getExpr() and
        classifier = m.getFPClassifierName()
      )
      or
      exists(FunctionCall fc, FPClassifierFunction f |
        fc.getTarget() = f and
        floatExpr = fc.getArgument(0) and
        checkResultExpr = fc and
        classifier = f.getFPClassifierName()
      )
    )
  }

  string toString() {
    result =
      classifier.toString() + " guard on " + floatExpr.toString() + " via " +
        checkResultExpr.toString()
  }

  predicate constrainsFPClass(Expr e, FPClassificationConstraint constraint, Boolean testIsTrue) {
    floatExpr = e and
    exists(BooleanValue value, boolean areEqual, int testResult, FPClassificationConstraint base |
      super.comparesEq(checkResultExpr, testResult, areEqual, value) and
      base = getBaseConstraint(areEqual, testResult) and
      if value.getValue() = testIsTrue then constraint = base else constraint = base.invert()
    )
  }

  // Helper predicate, gets base constraint assuming `classifier() == value` or `classifier != value`.
  private FPClassificationConstraint getBaseConstraint(Boolean areEqual, int testResult) {
    exists(FPClassificationConstraint base |
      testResult = 0 and
      exists(Boolean strict |
        // Handle isfinite() != 0:
        classifier = TClassifiesFinite(_, strict) and
        base = TExactFPClassification(TFinite(), strict)
        or
        // Handle isNaN() != 0:
        classifier = TClassifiesNaN(_, strict) and
        base = TExactFPClassification(TNaN(), strict)
        or
        // Handle isinf() != 0, which matches for +/- infinity:
        classifier = TClassifiesInfinite(_) and
        base = TExactFPClassification(TInfinite(), true)
      ) and
      // Invert the base constraint in the case of `classifier() == 0`
      if areEqual = false then result = base else result = base.invert()
      or
      // Handle isinf() == 1 or isInf() == -1, which matches for one of +/- infinity:
      testResult = 1 and
      classifier = TClassifiesInfinite(_) and
      base = TExactFPClassification(TInfinite(), false) and
      // Invert the base constraint in the case of `classifier() != 1`
      if areEqual = true then result = base else result = base.invert()
      // TODO: handle fpclassify() == FP_INFINITE, FP_NAN, FP_NORMAL, FP_ZERO, etc.
    )
  }

  predicate controls(Expr e, boolean testIsTrue) {
    exists(IRGuardCondition irg, IRBlock irb, Instruction eir, BooleanValue bval |
      irg.getUnconvertedResultExpression() = this and
      bval.getValue() = testIsTrue and
      irg.valueControls(irb, bval) and
      eir.getAst().(ControlFlowNode).getBasicBlock() = e.getBasicBlock() and
      eir.getBlock() = irb
    )
  }
}

predicate guardedNotEqualZero(Expr e) {
  /* Note Boolean cmpEq, false means cmpNeq */
  exists(Expr checked, GuardCondition guard, boolean cmpEq, BooleanValue value |
    hashCons(checked) = hashCons(e) and
    guard.controls(e.getBasicBlock(), cmpEq) and
    value.getValue() = cmpEq and
    guard.comparesEq(checked, 0, false, value)
  )
  or
  exists(Expr checked, Expr val, int valVal, GuardCondition guard, boolean cmpEq |
    hashCons(checked) = hashCons(e) and
    forex(float v |
      v = [RestrictedRangeAnalysis::lowerBound(val), RestrictedRangeAnalysis::upperBound(val)]
    |
      valVal = v
    ) and
    guard.controls(e.getBasicBlock(), cmpEq) and
    guard.comparesEq(checked, val, -valVal, false, cmpEq)
  )
}

predicate guardedNotFPClass(Expr e, FPClassification cls) {
  /* Note Boolean cmpEq, false means cmpNeq */
  exists(
    Expr checked, FPClassificationGuard guard, FPClassificationConstraint constraint, boolean cmpEq
  |
    hashCons(checked) = hashCons(e) and
    guard.controls(e, cmpEq) and
    guard.constrainsFPClass(checked, constraint, cmpEq) and
    constraint.mustNotBe(cls) and
    not checked = e
  )
}

predicate exprMayEqualInfinity(Expr e, Boolean positive) {
  exists(float target |
    positive = true and target = 1.0 / 0.0
    or
    positive = false and target = -1.0 / 0.0
  |
    RestrictedRangeAnalysis::upperBound(e.getUnconverted()) = target or
    RestrictedRangeAnalysis::lowerBound(e.getUnconverted()) = target
  ) and
  not guardedNotFPClass(e, TInfinite()) and
  not e.getType() instanceof IntegralType
}

signature float upperBoundPredicate(Expr e);

signature float lowerBoundPredicate(Expr e);

signature predicate exprMayEqualZeroPredicate(Expr e);

predicate exprMayEqualZeroNaive(Expr e) { e.getValue().toFloat() = 0 }

/**
 * Get the math function name variants for the given name, e.g., "acos" has variants "acos",
 * "acosf", and "acosl".
 */
Function getMathVariants(string name) { result.hasGlobalOrStdName([name, name + "f", name + "l"]) }

module DomainError<
  upperBoundPredicate/1 ub, lowerBoundPredicate/1 lb, exprMayEqualZeroPredicate/1 mayEqualZero>
{
  predicate hasDomainError(FunctionCall fc, string description) {
    exists(Function functionWithDomainError | fc.getTarget() = functionWithDomainError |
      functionWithDomainError = [getMathVariants(["acos", "asin", "atanh"])] and
      not (
        ub(fc.getArgument(0)) <= 1.0 and
        lb(fc.getArgument(0)) >= -1.0
      ) and
      description =
        "the argument has a range " + lb(fc.getArgument(0)) + "..." + ub(fc.getArgument(0)) +
          " which is outside the domain of this function (-1.0...1.0)"
      or
      functionWithDomainError = getMathVariants(["atan2", "pow"]) and
      (
        mayEqualZero(fc.getArgument(0)) and
        mayEqualZero(fc.getArgument(1)) and
        description = "both arguments are equal to zero"
      )
      or
      functionWithDomainError = getMathVariants("pow") and
      (
        ub(fc.getArgument(0)) < 0.0 and
        ub(fc.getArgument(1)) < 0.0 and
        description = "both arguments are less than zero"
      )
      or
      functionWithDomainError = getMathVariants("acosh") and
      ub(fc.getArgument(0)) < 1.0 and
      description = "argument is less than 1"
      or
      //pole error is the same as domain for logb and tgamma (but not ilogb - no pole error exists)
      functionWithDomainError = getMathVariants(["ilogb", "logb", "tgamma"]) and
      fc.getArgument(0).getValue().toFloat() = 0 and
      description = "argument is equal to zero"
      or
      functionWithDomainError = getMathVariants(["log", "log10", "log2", "sqrt"]) and
      ub(fc.getArgument(0)) < 0.0 and
      description = "argument is negative"
      or
      functionWithDomainError = getMathVariants("log1p") and
      ub(fc.getArgument(0)) < -1.0 and
      description = "argument is less than 1"
      or
      functionWithDomainError = getMathVariants("fmod") and
      fc.getArgument(1).getValue().toFloat() = 0 and
      description = "y is 0"
    )
  }
}

import DomainError<RestrictedRangeAnalysis::upperBound/1, RestrictedRangeAnalysis::lowerBound/1, exprMayEqualZero/1> as RestrictedDomainError
import DomainError<SimpleRangeAnalysis::upperBound/1, SimpleRangeAnalysis::lowerBound/1, exprMayEqualZeroNaive/1> as SimpleDomainError
