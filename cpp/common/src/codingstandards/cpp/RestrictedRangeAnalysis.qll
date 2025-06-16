import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.valuenumbering.HashCons

/**
 * A fork of SimpleRangeAnalysis.qll, which is intended to only give results
 * with a conservative basis. Forked from codeql/cpp-all@1.4.2.
 *
 * For instance, since range analysis is local, a function call (e.g. `f()`) is
 * given the widest possible range in the original library. In this fork, we do
 * not provide any result.
 *
 * Original library level doc comment from SimpleRangeAnalysis.qll:
 *
 * > Simple range analysis library. Range analysis is usually done as an
 * > abstract interpretation over the lattice of range values. (A range is a
 * > pair, containing a lower and upper bound for the value.) The problem
 * > with this approach is that the lattice is very tall, which means it can
 * > take an extremely large number of iterations to find the least fixed
 * > point. This example illustrates the problem:
 *
 * >    int count = 0;
 * >    for (; p; p = p->next) {
 * >      count = count+1;
 * >    }
 *
 * > The range of 'count' is initially (0,0), then (0,1) on the second
 * > iteration, (0,2) on the third iteration, and so on until we eventually
 * > reach maxInt.
 *
 * > This library uses a crude solution to the problem described above: if
 * > the upper (or lower) bound of an expression might depend recursively on
 * > itself then we round it up (down for lower bounds) to one of a fixed set
 * > of values, such as 0, 1, 2, 256, and +Inf. This limits the height of the
 * > lattice which ensures that the analysis will terminate in a reasonable
 * > amount of time. This solution is similar to the abstract interpretation
 * > technique known as 'widening', but it is less precise because we are
 * > unable to inspect the bounds from the previous iteration of the fixed
 * > point computation. For example, widening might be able to deduce that
 * > the lower bound is -11 but we would approximate it to -16.
 *
 * > QL does not allow us to compute an aggregate over a recursive
 * > sub-expression, so we cannot compute the minimum lower bound and maximum
 * > upper bound during the recursive phase of the query. Instead, the
 * > recursive phase computes a set of lower bounds and a set of upper bounds
 * > for each expression. We compute the minimum lower bound and maximum
 * > upper bound after the recursion is finished. This is another reason why
 * > we need to limit the number of bounds per expression, because they will
 * > all be stored until the recursive phase is finished.
 *
 * > The ranges are represented using a pair of floating point numbers. This
 * > is simpler than using integers because floating point numbers cannot
 * > overflow and wrap. It is also convenient because we can detect overflow
 * > and negative overflow by looking for bounds that are outside the range
 * > of the type.
 *
 * The differences between this library and the original are:
 *  - The `largeValue()` predicate, with a value of 1e15, used in place of
 *    `exprMaxVal()` and `exprMinVal()` in most places.
 *  - Support for range analysis extensions removed for simplicity.
 *  - Additional predicates have been added to check for non-zero values, and guards
 *    against values equalling zero.
 *  - Division by a constant value has been added as a supported operations. Division
 *    is always widened, as support for division introduces examples of significantly
 *    longer chains of dependent expressions than merely addition and multiplication.
 *    These long chains can introduce exponential growth in the number of candidate
 *    bounds, even without recursive binary operations, so widening is always applied.
 *  - Division operations where the range of the denominator includes zero (and its
 *    not guarded to be non-zero) and produce infinite upper and/or lower bounds.
 *  - Support for monotonically increasing and decreasing math functions has been
 *    added, including `log`, `exp`, `asin`, `atan`, `sinh`, and `sqrt`. If a math
 *    function increases or decreases monotonically, then the lower or upper bound of
 *    its input can be used to compute the lower or upper bound of the function call.
 *    Not all math functions increase or decrease monotonically.
 */
module RestrictedRangeAnalysis {
  import cpp
  private import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils as Util
  import semmle.code.cpp.rangeanalysis.RangeSSA
  import SimpleRangeAnalysisCached
  private import semmle.code.cpp.rangeanalysis.NanAnalysis

  float largeValue() { result = 1000000000000000.0 }

  /**
   * This fixed set of lower bounds is used when the lower bounds of an
   * expression are recursively defined. The inferred lower bound is rounded
   * down to the nearest lower bound in the fixed set. This restricts the
   * height of the lattice, which prevents the analysis from exploding.
   *
   * Note: these bounds were chosen fairly arbitrarily. Feel free to add more
   * bounds to the set if it helps on specific examples and does not make
   * performance dramatically worse on large codebases, such as libreoffice.
   */
  private float wideningLowerBounds(ArithmeticType t) {
    result = 2.0 or
    result = 1.0 or
    result = 0.0 or
    result = -1.0 or
    result = -2.0 or
    result = -8.0 or
    result = -16.0 or
    result = -128.0 or
    result = -256.0 or
    result = -32768.0 or
    result = -65536.0 or
    result = -largeValue() or
    result = Util::typeLowerBound(t)
    //result = max(float v | v = Util::typeLowerBound(t) or v = -largeValue())
  }

  /** See comment for `wideningLowerBounds`, above. */
  private float wideningUpperBounds(ArithmeticType t) {
    result = -2.0 or
    result = -1.0 or
    result = 0.0 or
    result = 1.0 or
    result = 2.0 or
    result = 7.0 or
    result = 15.0 or
    result = 127.0 or
    result = 255.0 or
    result = 32767.0 or
    result = 65535.0 or
    result = largeValue() or
    result = Util::typeUpperBound(t)
    //result = min(float v | v = Util::typeLowerBound(t) or v = largeValue())
  }

  /**
   * Gets the value of the expression `e`, if it is a constant.
   * This predicate also handles the case of constant variables initialized in different
   * compilation units, which doesn't necessarily have a getValue() result from the extractor.
   */
  private string getValue(Expr e) {
    if exists(e.getValue())
    then result = e.getValue()
    else
      /*
       * It should be safe to propagate the initialization value to a variable if:
       * The type of v is const, and
       * The type of v is not volatile, and
       * Either:
       *   v is a local/global variable, or
       *   v is a static member variable
       */

      exists(VariableAccess access, StaticStorageDurationVariable v |
        not v.getUnderlyingType().isVolatile() and
        v.getUnderlyingType().isConst() and
        e = access and
        v = access.getTarget() and
        result = getValue(v.getAnAssignedValue())
      )
  }

  private float varMaxVal(Variable v) {
    result = min(float f | f = Util::varMaxVal(v) or f = largeValue())
  }

  private float varMinVal(Variable v) {
    result = max(float f | f = Util::varMinVal(v) or f = -largeValue())
  }

  private float exprMaxVal(Expr e) {
    result = min(float f | f = Util::exprMaxVal(e) or f = largeValue())
  }

  private float exprMinVal(Expr e) {
    result = max(float f | f = Util::exprMinVal(e) or f = -largeValue())
  }

  /**
   * A bitwise `&` expression in which both operands are unsigned, or are effectively
   * unsigned due to being a non-negative constant.
   */
  private class UnsignedBitwiseAndExpr extends BitwiseAndExpr {
    UnsignedBitwiseAndExpr() {
      (
        this.getLeftOperand()
            .getFullyConverted()
            .getType()
            .getUnderlyingType()
            .(IntegralType)
            .isUnsigned() or
        getValue(this.getLeftOperand().getFullyConverted()).toInt() >= 0
      ) and
      (
        this.getRightOperand()
            .getFullyConverted()
            .getType()
            .getUnderlyingType()
            .(IntegralType)
            .isUnsigned() or
        getValue(this.getRightOperand().getFullyConverted()).toInt() >= 0
      )
    }
  }

  /**
   * Gets the floor of `v`, with additional logic to work around issues with
   * large numbers.
   */
  bindingset[v]
  float safeFloor(float v) {
    // return the floor of v
    v.abs() < 2.pow(31) and
    result = v.floor()
    or
    // `floor()` doesn't work correctly on large numbers (since it returns an integer),
    // so fall back to unrounded numbers at this scale.
    not v.abs() < 2.pow(31) and
    result = v
  }

  /** A `MulExpr` where exactly one operand is constant. */
  private class MulByConstantExpr extends MulExpr {
    float constant;
    Expr operand;

    MulByConstantExpr() {
      exists(Expr constantExpr |
        this.hasOperands(constantExpr, operand) and
        constant = getValue(constantExpr.getFullyConverted()).toFloat() and
        not exists(getValue(operand.getFullyConverted()).toFloat())
      )
    }

    /** Gets the value of the constant operand. */
    float getConstant() { result = constant }

    /** Gets the non-constant operand. */
    Expr getOperand() { result = operand }
  }

  private class UnsignedMulExpr extends MulExpr {
    UnsignedMulExpr() {
      this.getType().(IntegralType).isUnsigned() and
      // Avoid overlap. It should be slightly cheaper to analyze
      // `MulByConstantExpr`.
      not this instanceof MulByConstantExpr
    }
  }

  /**
   * Holds if `expr` is effectively a multiplication of `operand` with the
   * positive constant `positive`.
   */
  private predicate effectivelyMultipliesByPositive(Expr expr, Expr operand, float positive) {
    operand = expr.(MulByConstantExpr).getOperand() and
    positive = expr.(MulByConstantExpr).getConstant() and
    positive >= 0.0 // includes positive zero
    or
    operand = expr.(UnaryPlusExpr).getOperand() and
    positive = 1.0
    or
    operand = expr.(CommaExpr).getRightOperand() and
    positive = 1.0
    or
    operand = expr.(StmtExpr).getResultExpr() and
    positive = 1.0
  }

  /**
   * Holds if `expr` is effectively a multiplication of `operand` with the
   * negative constant `negative`.
   */
  private predicate effectivelyMultipliesByNegative(Expr expr, Expr operand, float negative) {
    operand = expr.(MulByConstantExpr).getOperand() and
    negative = expr.(MulByConstantExpr).getConstant() and
    negative < 0.0 // includes negative zero
    or
    operand = expr.(UnaryMinusExpr).getOperand() and
    negative = -1.0
  }

  private class AssignMulByConstantExpr extends AssignMulExpr {
    float constant;

    AssignMulByConstantExpr() {
      constant = getValue(this.getRValue().getFullyConverted()).toFloat()
    }

    float getConstant() { result = constant }
  }

  private class AssignMulByPositiveConstantExpr extends AssignMulByConstantExpr {
    AssignMulByPositiveConstantExpr() { constant >= 0.0 }
  }

  private class AssignMulByNegativeConstantExpr extends AssignMulByConstantExpr {
    AssignMulByNegativeConstantExpr() { constant < 0.0 }
  }

  private class UnsignedAssignMulExpr extends AssignMulExpr {
    UnsignedAssignMulExpr() {
      this.getType().(IntegralType).isUnsigned() and
      // Avoid overlap. It should be slightly cheaper to analyze
      // `AssignMulByConstantExpr`.
      not this instanceof AssignMulByConstantExpr
    }
  }

  /**
   * Holds if `expr` is effectively a division of `operand` with the
   * positive constant `positive`.
   */
  private predicate dividesByPositive(DivExpr expr, Expr operand, float positive) {
    operand = expr.(DivExpr).getLeftOperand() and
    positive = expr.(DivExpr).getRightOperand().getValue().toFloat() and
    positive > 0.0 // doesn't include zero
  }

  /**
   * Holds if `expr` is effectively a division of `operand` with the
   * negative constant `negative`.
   */
  private predicate dividesByNegative(Expr expr, Expr operand, float negative) {
    operand = expr.(DivExpr).getLeftOperand() and
    negative = getValue(expr.(DivExpr).getRightOperand().getFullyConverted()).toFloat() and
    negative < 0.0 // doesn't include zero
  }

  /**
   * Holds if `expr` may divide by zero. Excludes dividing a constant zero divided by zero,
   * which produces NaN instead of an infinite value.
   */
  predicate dividesNonzeroByZero(Expr expr) {
    exists(Expr divisor, Expr numerator |
      divisor = expr.(DivExpr).getRightOperand() and
      numerator = expr.(DivExpr).getLeftOperand() and
      getTruncatedLowerBounds(divisor) <= 0.0 and
      getTruncatedUpperBounds(divisor) >= 0.0 and
      not isCheckedNotZero(divisor) and
      not getValue(numerator).toFloat() = 0.0
    )
  }

  bindingset[name]
  Function getMathVariants(string name) {
    result.hasGlobalOrStdName([name, name + "f", name + "l"])
  }

  /**
   * New support added for mathematical functions that either monotonically increase, or decrease,
   * or that have a known lower or upper bound.
   *
   * For instance, log(x) monotonically increases over x, and acos(x) monotonically decreases,
   * while sin(x) has a known output range of -1 to 1.
   *
   * `pow` is especially common so minimal work is done to support that here as well. `pow(c, x)`
   * monotonically increases or decreases over `x` if `c` is a constant, though the reverse is not
   * true except in special cases.
   */
  newtype TSupportedMathFunctionCall =
    /* A monotonically increasing function call. `extra` is a constant for `pow(x, c)`. */
    TMonotonicIncrease(FunctionCall fc, Expr input, float extra) {
      // Note: Codeql has no default implementation in codeql for exp2, atanh, acosh, asinh, or
      // log1p so we haven't taken the time to support them yet.
      fc.getTarget() =
        getMathVariants(["log", "log2", "log10", "exp", "asin", "atan", "sinh", "sqrt"]) and
      input = fc.getArgument(0) and
      extra = 0.0
      or
      // Notes: pow is monotonic if the base argument is constant, increasing if the base is greater
      // than 1 or between -1 and 0, and decreasing otherwise. A constant power is monotonic over the
      // base in the positive or negative domain, but distinguishing those separately can introduce
      // non-monotonic recursion errors.
      fc.getTarget() = getMathVariants("pow") and
      extra = fc.getArgument(0).getValue().toFloat() and
      (
        extra > 1.0
        or
        extra < 0.0 and extra > -1.0
      ) and
      input = fc.getArgument(1)
    } or
    /* A monotonically decreasing function call. `extra` is a constant for `pow(x, c)`. */
    TMonotonicDecrease(FunctionCall fc, Expr input, float extra) {
      fc.getTarget() = getMathVariants(["acos"]) and
      input = fc.getArgument(0) and
      extra = 0.0
      or
      fc.getTarget() = getMathVariants("pow") and
      extra = fc.getArgument(0).getValue().toFloat() and
      (
        extra < -1.0
        or
        extra > 0.0 and extra < 1.0
      ) and
      input = fc.getArgument(1)
    } or
    /* A non-mononotic function call with a known lower bound. */
    TNonMonotonicLowerBound(FunctionCall fc, float lb) {
      fc.getTarget() = getMathVariants("cosh") and
      lb = 1.0
      or
      fc.getTarget() = getMathVariants(["cos", "sin"]) and
      lb = -1.0
    } or
    /* A non-mononotic function call with a known upper bound. */
    TNonMonotonicUpperBound(FunctionCall fc, float lb) {
      fc.getTarget() = getMathVariants(["cos", "sin"]) and
      lb = 1.0
    }

  /**
   * A function call that is supported by range analysis.
   */
  class SupportedFunctionCall extends TSupportedMathFunctionCall {
    string toString() {
      exists(FunctionCall fc |
        this = TMonotonicIncrease(fc, _, _) and
        result = "Monotonic increase " + fc.getTarget().getName()
        or
        this = TMonotonicDecrease(fc, _, _) and
        result = "Monotonic decrease " + fc.getTarget().getName()
        or
        this = TNonMonotonicLowerBound(fc, _) and
        result = "Nonmonotonic lower bound " + fc.getTarget().getName()
        or
        this = TNonMonotonicUpperBound(fc, _) and
        result = "Nonmonotonic upper bound " + fc.getTarget().getName()
      )
    }

    /** Get the function call node this algebraic type corresponds to. */
    FunctionCall getFunctionCall() {
      this = TMonotonicIncrease(result, _, _)
      or
      this = TMonotonicDecrease(result, _, _)
      or
      this = TNonMonotonicLowerBound(result, _)
      or
      this = TNonMonotonicUpperBound(result, _)
    }

    /** Get the function name (`sin`, `pow`, etc.) without the `l` or `f` suffix. */
    bindingset[this, result]
    string getBaseFunctionName() { getMathVariants(result) = getFunctionCall().getTarget() }

    /**
     * Compute a result bound based on an input value and an extra constant value.
     *
     * The functions `getUpperBound()` and `getLowerBound()` automatically handle the differences
     * between monotonically increasing and decreasing functions, and provide the input value. The
     * `extra` float exists to support `pow(x, c)` for the constant `c`, otherwise it is `0.0`.
     */
    bindingset[value, extra, this]
    float compute(float value, float extra) {
      exists(string name | name = getBaseFunctionName() |
        name = "log" and
        result = value.log()
        or
        name = "log2" and
        result = value.log2()
        or
        name = "log10" and
        result = value.log10()
        or
        name = "exp" and
        result = value.exp()
        or
        name = "asin" and
        result = value.asin()
        or
        name = "atan" and
        result = value.atan()
        or
        name = "acos" and
        result = value.acos()
        or
        name = "sinh" and
        result = value.sinh()
        or
        name = "sqrt" and
        result = value.sqrt()
        or
        name = "pow" and
        result = extra.pow(value)
      )
    }

    /**
     * Get the lower bound of this function, based on its fixed range (if it has one) or based on
     * the lower or upper bound of its input, if it is a monotonically increasing or decreasing
     * function.
     */
    float getLowerBound() {
      this = TNonMonotonicLowerBound(_, result)
      or
      exists(Expr expr, float bound, float extra |
        (
          this = TMonotonicIncrease(_, expr, extra) and
          bound = getFullyConvertedLowerBounds(expr)
          or
          this = TMonotonicDecrease(_, expr, extra) and
          bound = getFullyConvertedUpperBounds(expr)
        ) and
        result = compute(bound, extra)
      )
    }

    /**
     * Get the lower bound of this function, based on its fixed range (if it has one) or based on
     * the lower or upper bound of its input, if it is a monotonically increasing or decreasing
     * function.
     */
    float getUpperBound() {
      this = TNonMonotonicUpperBound(_, result)
      or
      exists(Expr expr, float bound, float extra |
        (
          this = TMonotonicIncrease(_, expr, extra) and
          bound = getFullyConvertedUpperBounds(expr)
          or
          this = TMonotonicDecrease(_, expr, extra) and
          bound = getFullyConvertedLowerBounds(expr)
        ) and
        result = compute(bound, extra)
      )
    }
  }

  predicate supportedMathFunction(FunctionCall fc) {
    exists(SupportedFunctionCall sfc | sfc.getFunctionCall() = fc)
  }

  /**
   * Holds if `expr` is checked with a guard to not be zero.
   *
   * Since our range analysis only tracks an upper and lower bound, that means if a variable has
   * range [-10, 10], its range includes zero. In the body of an if statement that checks it's not
   * equal to zero, we cannot update the range to reflect that as the upper and lower bounds are
   * not changed. This problem is not the case for gt, lt, gte, lte, or ==, as these can be used to
   * create a new subset range that does not include zero.
   *
   * It is important to know if an expr may be zero to avoid division by zero creating infinities.
   */
  predicate isCheckedNotZero(Expr expr) {
    exists(RangeSsaDefinition def, StackVariable v, VariableAccess guardVa, Expr guard |
      // This is copied from getGuardedUpperBound, which says its only an approximation. This is
      // indeed wrong in many cases.
      def.isGuardPhi(v, guardVa, guard, _) and
      exists(unique(BasicBlock b | b = def.(BasicBlock).getAPredecessor())) and
      expr = def.getAUse(v) and
      isNEPhi(v, def, guardVa, 0)
    )
    or
    guardedHashConsNotEqualZero(expr)
  }

  predicate guardedHashConsNotEqualZero(Expr e) {
    /* Note Boolean cmpEq, false means cmpNeq */
    exists(Expr check, Expr val, int valVal, GuardCondition guard, boolean cmpEq |
      hashCons(check) = hashCons(e) and
      valVal = getValue(val).toFloat() and
      guard.controls(e.getBasicBlock(), cmpEq) and
      (
        guard.comparesEq(check, val, -valVal, false, cmpEq) or
        guard.comparesEq(val, check, -valVal, false, cmpEq)
      )
    )
  }

  /** Set of expressions which we know how to analyze. */
  predicate analyzableExpr(Expr e) {
    // The type of the expression must be arithmetic. We reuse the logic in
    // `exprMinVal` to check this.
    exists(Util::exprMinVal(e)) and
    (
      exists(getValue(e).toFloat())
      or
      effectivelyMultipliesByPositive(e, _, _)
      or
      effectivelyMultipliesByNegative(e, _, _)
      or
      dividesByPositive(e, _, _)
      or
      dividesByNegative(e, _, _)
      or
      // Introduces non-monotonic recursion. However, analysis mostly works with this
      // commented out.
      // or
      // dividesNonzeroByZero(e)
      e instanceof DivExpr // TODO: confirm this is OK
      or
      supportedMathFunction(e)
      or
      e instanceof MinExpr
      or
      e instanceof MaxExpr
      or
      e instanceof ConditionalExpr
      or
      e instanceof AddExpr
      or
      e instanceof SubExpr
      or
      e instanceof UnsignedMulExpr
      or
      e instanceof AssignExpr
      or
      e instanceof AssignAddExpr
      or
      e instanceof AssignSubExpr
      or
      e instanceof UnsignedAssignMulExpr
      or
      e instanceof AssignMulByConstantExpr
      or
      e instanceof CrementOperation
      or
      e instanceof RemExpr
      or
      // A conversion is analyzable, provided that its child has an arithmetic
      // type. (Sometimes the child is a reference type, and so does not get
      // any bounds.) Rather than checking whether the type of the child is
      // arithmetic, we reuse the logic that is already encoded in
      // `exprMinVal`.
      exists(Util::exprMinVal(e.(Conversion).getExpr()))
      or
      // Also allow variable accesses, provided that they have SSA
      // information.
      exists(RangeSsaDefinition def | e = def.getAUse(_))
      or
      e instanceof UnsignedBitwiseAndExpr
      or
      // `>>` by a constant
      exists(getValue(e.(RShiftExpr).getRightOperand()))
    )
  }

  /**
   * Set of definitions that this definition depends on. The transitive
   * closure of this relation is used to detect definitions which are
   * recursively defined, so that we can prevent the analysis from exploding.
   *
   * The structure of `defDependsOnDef` and its helper predicates matches the
   * structure of `getDefLowerBoundsImpl` and
   * `getDefUpperBoundsImpl`. Therefore, if changes are made to the structure
   * of the main analysis algorithm then matching changes need to be made
   * here.
   */
  private predicate defDependsOnDef(
    RangeSsaDefinition def, StackVariable v, RangeSsaDefinition srcDef, StackVariable srcVar
  ) {
    // Definitions with a defining value.
    exists(Expr expr | assignmentDef(def, v, expr) | exprDependsOnDef(expr, srcDef, srcVar))
    or
    // Assignment operations with a defining value
    exists(AssignOperation assignOp |
      analyzableExpr(assignOp) and
      def = assignOp and
      def.getAVariable() = v and
      exprDependsOnDef(assignOp, srcDef, srcVar)
    )
    or
    exists(CrementOperation crem |
      def = crem and
      def.getAVariable() = v and
      exprDependsOnDef(crem.getOperand(), srcDef, srcVar)
    )
    or
    // Phi nodes.
    phiDependsOnDef(def, v, srcDef, srcVar)
  }

  /**
   * Helper predicate for `defDependsOnDef`. This predicate matches
   * the structure of `getLowerBoundsImpl` and `getUpperBoundsImpl`.
   */
  private predicate exprDependsOnDef(Expr e, RangeSsaDefinition srcDef, StackVariable srcVar) {
    exists(Expr operand |
      effectivelyMultipliesByNegative(e, operand, _) and
      exprDependsOnDef(operand, srcDef, srcVar)
    )
    or
    exists(Expr operand |
      effectivelyMultipliesByPositive(e, operand, _) and
      exprDependsOnDef(operand, srcDef, srcVar)
    )
    or
    exists(Expr operand |
      (dividesByPositive(e, operand, _) or dividesByNegative(e, operand, _)) and
      exprDependsOnDef(operand, srcDef, srcVar)
    )
    or
    exists(DivExpr div | div = e | exprDependsOnDef(div.getAnOperand(), srcDef, srcVar))
    or
    exists(MinExpr minExpr | e = minExpr | exprDependsOnDef(minExpr.getAnOperand(), srcDef, srcVar))
    or
    exists(MaxExpr maxExpr | e = maxExpr | exprDependsOnDef(maxExpr.getAnOperand(), srcDef, srcVar))
    or
    exists(ConditionalExpr condExpr | e = condExpr |
      exprDependsOnDef(condExpr.getAnOperand(), srcDef, srcVar)
    )
    or
    exists(AddExpr addExpr | e = addExpr | exprDependsOnDef(addExpr.getAnOperand(), srcDef, srcVar))
    or
    exists(SubExpr subExpr | e = subExpr | exprDependsOnDef(subExpr.getAnOperand(), srcDef, srcVar))
    or
    exists(UnsignedMulExpr mulExpr | e = mulExpr |
      exprDependsOnDef(mulExpr.getAnOperand(), srcDef, srcVar)
    )
    or
    exists(AssignExpr addExpr | e = addExpr | exprDependsOnDef(addExpr.getRValue(), srcDef, srcVar))
    or
    exists(AssignAddExpr addExpr | e = addExpr |
      exprDependsOnDef(addExpr.getAnOperand(), srcDef, srcVar)
    )
    or
    exists(AssignSubExpr subExpr | e = subExpr |
      exprDependsOnDef(subExpr.getAnOperand(), srcDef, srcVar)
    )
    or
    exists(UnsignedAssignMulExpr mulExpr | e = mulExpr |
      exprDependsOnDef(mulExpr.getAnOperand(), srcDef, srcVar)
    )
    or
    exists(AssignMulByConstantExpr mulExpr | e = mulExpr |
      exprDependsOnDef(mulExpr.getLValue(), srcDef, srcVar)
    )
    or
    exists(CrementOperation crementExpr | e = crementExpr |
      exprDependsOnDef(crementExpr.getOperand(), srcDef, srcVar)
    )
    or
    exists(RemExpr remExpr | e = remExpr | exprDependsOnDef(remExpr.getAnOperand(), srcDef, srcVar))
    or
    exists(Conversion convExpr | e = convExpr |
      exprDependsOnDef(convExpr.getExpr(), srcDef, srcVar)
    )
    or
    // unsigned `&`
    exists(UnsignedBitwiseAndExpr andExpr |
      andExpr = e and
      exprDependsOnDef(andExpr.getAnOperand(), srcDef, srcVar)
    )
    or
    // `>>` by a constant
    exists(RShiftExpr rs |
      rs = e and
      exists(getValue(rs.getRightOperand())) and
      exprDependsOnDef(rs.getLeftOperand(), srcDef, srcVar)
    )
    or
    e = srcDef.getAUse(srcVar)
  }

  /**
   * Helper predicate for `defDependsOnDef`. This predicate matches
   * the structure of `getPhiLowerBounds` and `getPhiUpperBounds`.
   */
  private predicate phiDependsOnDef(
    RangeSsaDefinition phi, StackVariable v, RangeSsaDefinition srcDef, StackVariable srcVar
  ) {
    exists(VariableAccess access, Expr guard | phi.isGuardPhi(v, access, guard, _) |
      exprDependsOnDef(guard.(ComparisonOperation).getAnOperand(), srcDef, srcVar) or
      exprDependsOnDef(access, srcDef, srcVar)
    )
    or
    srcDef = phi.getAPhiInput(v) and srcVar = v
  }

  /** The transitive closure of `defDependsOnDef`. */
  private predicate defDependsOnDefTransitively(
    RangeSsaDefinition def, StackVariable v, RangeSsaDefinition srcDef, StackVariable srcVar
  ) {
    defDependsOnDef(def, v, srcDef, srcVar)
    or
    exists(RangeSsaDefinition midDef, StackVariable midVar |
      defDependsOnDef(def, v, midDef, midVar)
    |
      defDependsOnDefTransitively(midDef, midVar, srcDef, srcVar)
    )
  }

  /** The set of definitions that depend recursively on themselves. */
  private predicate isRecursiveDef(RangeSsaDefinition def, StackVariable v) {
    defDependsOnDefTransitively(def, v, def, v)
  }

  /**
   * Holds if the bounds of `e` depend on a recursive definition, meaning that
   * `e` is likely to have many candidate bounds during the main recursion.
   */
  private predicate isRecursiveExpr(Expr e) {
    exists(RangeSsaDefinition def, StackVariable v | exprDependsOnDef(e, def, v) |
      isRecursiveDef(def, v)
    )
  }

  /**
   * Holds if `binop` is a binary operation that's likely to be assigned a
   * quadratic (or more) number of candidate bounds during the analysis. This can
   * happen when two conditions are satisfied:
   * 1. It is likely there are many more candidate bounds for `binop` than for
   *    its operands. For example, the number of candidate bounds for `x + y`,
   *    denoted here nbounds(`x + y`), will be O(nbounds(`x`) * nbounds(`y`)).
   *    In contrast, nbounds(`b ? x : y`) is only O(nbounds(`x`) + nbounds(`y`)).
   * 2. Both operands of `binop` are recursively determined and are therefore
   *    likely to have a large number of candidate bounds.
   */
  private predicate isRecursiveBinary(BinaryOperation binop) {
    (
      binop instanceof UnsignedMulExpr
      or
      binop instanceof AddExpr
      or
      binop instanceof SubExpr
    ) and
    isRecursiveExpr(binop.getLeftOperand()) and
    isRecursiveExpr(binop.getRightOperand())
  }

  private predicate applyWideningToBinary(BinaryOperation op) {
    // Original behavior:
    isRecursiveBinary(op)
    or
    // As we added support for DivExpr, we found cases of combinatorial explosion that are not
    // caused by recursion. Given expr `x` that depends on a phi node that has evaluated y unique
    // values, `x + x` will in the worst case evaluate to y^2 unique values, even if `x` is not
    // recursive. By adding support for division, we have revealed certain pathological cases in
    // open source code, for instance `posix_time_from_utc` from boringssl. We can reduce this
    // greatly by widening, and targeting division effectively reduces the chains of evaluations
    // that cause this issue while preserving the original behavior.
    //
    // There is also a set of functions intended to estimate the combinations of phi nodes each
    // expression depends on, which could be used to accurately widen only expensive nodes. However,
    // that estimation is more involved than it may seem, and hasn't yet resulted in a net
    // improvement. See `estimatedPhiCombinationsExpr` and `estimatedPhiCombinationsDef`.
    //
    // This approach currently has the best performance.
    op instanceof DivExpr
  }

  /**
   * Recursively scan this expr to see how many phi nodes it depends on. Binary expressions
   * induce a combination effect, so `a + b` where `a` depends on 3 phi nodes and `b` depends on 4
   * will induce 3*4 = 12 phi node combinations.
   *
   * This currently requires additional optimization to be useful in practice.
   */
  int estimatedPhiCombinationsExpr(Expr expr) {
    if isRecursiveExpr(expr)
    then
      // Assume 10 values were computed to analyze recursive expressions.
      result = 10
    else (
      exists(RangeSsaDefinition def, StackVariable v | expr = def.getAUse(v) |
        def.isPhiNode(v) and
        result = estimatedPhiCombinationsDef(def, v)
      )
      or
      exists(BinaryOperation binop |
        binop = expr and
        result =
          estimatedPhiCombinationsExpr(binop.getLeftOperand()) *
            estimatedPhiCombinationsExpr(binop.getRightOperand())
      )
      or
      not expr instanceof BinaryOperation and
      exists(RangeSsaDefinition def, StackVariable v | exprDependsOnDef(expr, def, v) |
        result = estimatedPhiCombinationsDef(def, v)
      )
      or
      not expr instanceof BinaryOperation and
      not exprDependsOnDef(expr, _, _) and
      result = 1
    )
  }

  /**
   * Recursively scan this def to see how many phi nodes it depends on.
   *
   * If this def is a phi node, it sums its downstream cost and adds one to account for itself,
   * which is not exactly correct.
   *
   * This def may also be a crement expression (not currently supported), or an assign expr
   * (currently not supported), or an unanalyzable expression which is the root of the recursion
   * and given a value of 1.
   */
  language[monotonicAggregates]
  int estimatedPhiCombinationsDef(RangeSsaDefinition def, StackVariable v) {
    if isRecursiveDef(def, v)
    then
      // Assume 10 values were computed to analyze recursive expressions.
      result = 10
    else (
      if def.isPhiNode(v)
      then
        exists(Expr e | e = def.getAUse(v) |
          result =
            1 +
              sum(RangeSsaDefinition srcDef |
                srcDef = def.getAPhiInput(v)
              |
                estimatedPhiCombinationsDef(srcDef, v)
              )
        )
      else (
        exists(Expr expr | assignmentDef(def, v, expr) |
          result = estimatedPhiCombinationsExpr(expr)
        )
        or
        v = def.getAVariable() and
        not assignmentDef(def, v, _) and
        result = 1
      )
    )
  }

  /**
   * We distinguish 3 kinds of RangeSsaDefinition:
   *
   * 1. Definitions with a defining value.
   *    For example: x = y+3 is a definition of x with defining value y+3.
   *
   * 2. Phi nodes: x3 = phi(x0,x1,x2)
   *
   * 3. Unanalyzable definitions.
   *    For example: a parameter is unanalyzable because we know nothing
   *    about its value. We assign these range [-largeValue(), largeValue()]
   *
   * This predicate finds all the definitions in the first set.
   */
  private predicate assignmentDef(RangeSsaDefinition def, StackVariable v, Expr expr) {
    Util::getVariableRangeType(v) instanceof ArithmeticType and
    (
      def = v.getInitializer().getExpr() and def = expr
      or
      exists(AssignExpr assign |
        def = assign and
        assign.getLValue() = v.getAnAccess() and
        expr = assign.getRValue()
      )
    )
  }

  /** See comment above assignmentDef. */
  private predicate analyzableDef(RangeSsaDefinition def, StackVariable v) {
    assignmentDef(def, v, _)
    or
    analyzableExpr(def.(AssignOperation)) and
    v = def.getAVariable()
    or
    analyzableExpr(def.(CrementOperation)) and
    v = def.getAVariable()
    or
    phiDependsOnDef(def, v, _, _)
  }

  predicate canBoundExpr(Expr e) {
    exists(RangeSsaDefinition def, StackVariable v | e = def.getAUse(v) | analyzableDef(def, v))
    or
    analyzableExpr(e)
    or
    exists(getGuardedUpperBound(e))
    or
    lowerBoundFromGuard(e, _, _, _)
  }

  /**
   * Computes a normal form of `x` where -0.0 has changed to +0.0. This can be
   * needed on the lesser side of a floating-point comparison or on both sides of
   * a floating point equality because QL does not follow IEEE in floating-point
   * comparisons but instead defines -0.0 to be less than and distinct from 0.0.
   */
  bindingset[x]
  private float normalizeFloatUp(float x) { result = x + 0.0 }

  /**
   * Computes `x + y`, rounded towards +Inf. This is the general case where both
   * `x` and `y` may be large numbers.
   */
  bindingset[x, y]
  private float addRoundingUp(float x, float y) {
    if normalizeFloatUp((x + y) - x) < y or normalizeFloatUp((x + y) - y) < x
    then result = (x + y).nextUp()
    else result = (x + y)
  }

  /**
   * Computes `x + y`, rounded towards -Inf. This is the general case where both
   * `x` and `y` may be large numbers.
   */
  bindingset[x, y]
  private float addRoundingDown(float x, float y) {
    if (x + y) - x > normalizeFloatUp(y) or (x + y) - y > normalizeFloatUp(x)
    then result = (x + y).nextDown()
    else result = (x + y)
  }

  /**
   * Computes `x + small`, rounded towards +Inf, where `small` is a small
   * constant.
   */
  bindingset[x, small]
  private float addRoundingUpSmall(float x, float small) {
    if (x + small) - x < small then result = (x + small).nextUp() else result = (x + small)
  }

  /**
   * Computes `x + small`, rounded towards -Inf, where `small` is a small
   * constant.
   */
  bindingset[x, small]
  private float addRoundingDownSmall(float x, float small) {
    if (x + small) - x > small then result = (x + small).nextDown() else result = (x + small)
  }

  private predicate lowerBoundableExpr(Expr expr) {
    (analyzableExpr(expr) or dividesNonzeroByZero(expr)) and
    getUpperBoundsImpl(expr) <= Util::exprMaxVal(expr) and
    not exists(getValue(expr).toFloat())
  }

  /**
   * Gets the lower bounds of the expression.
   *
   * Most of the work of computing the lower bounds is done by
   * `getLowerBoundsImpl`. However, the lower bounds computed by
   * `getLowerBoundsImpl` may not be representable by the result type of the
   * expression. For example, if `x` and `y` are of type `int32` and each
   * have lower bound -2147483648, then getLowerBoundsImpl` will compute a
   * lower bound -4294967296 for the expression `x+y`, even though
   * -4294967296 cannot be represented as an `int32`. Such unrepresentable
   * bounds are replaced with `exprMinVal(expr)`. This predicate also adds
   * `exprMinVal(expr)` as a lower bound if the expression might overflow
   * positively, or if it is unanalyzable.
   *
   * Note: most callers should use `getFullyConvertedLowerBounds` rather than
   * this predicate.
   */
  private float getTruncatedLowerBounds(Expr expr) {
    // If the expression evaluates to a constant, then there is no
    // need to call getLowerBoundsImpl.
    analyzableExpr(expr) and
    result = getValue(expr).toFloat()
    or
    // Some of the bounds computed by getLowerBoundsImpl might
    // overflow, so we replace invalid bounds with exprMinVal.
    exists(float newLB | newLB = normalizeFloatUp(getLowerBoundsImpl(expr)) |
      if Util::exprMinVal(expr) <= newLB and newLB <= Util::exprMaxVal(expr)
      then
        // Apply widening where we might get a combinatorial explosion.
        if applyWideningToBinary(expr)
        then
          result =
            max(float widenLB |
              widenLB = wideningLowerBounds(expr.getUnspecifiedType()) and
              not widenLB > newLB
            )
        else result = newLB
      else result = Util::exprMinVal(expr)
    ) and
    lowerBoundableExpr(expr)
    or
    // The expression might overflow and wrap. If so, the
    // lower bound is exprMinVal.
    analyzableExpr(expr) and
    exprMightOverflowPositively(expr) and
    not result = getValue(expr).toFloat() and
    result = Util::exprMinVal(expr)
    or
    // The expression is not analyzable, so its lower bound is
    // unknown. Note that the call to exprMinVal restricts the
    // expressions to just those with arithmetic types. There is no
    // need to return results for non-arithmetic expressions.
    not analyzableExpr(expr) and
    result = exprMinVal(expr)
  }

  /**
   * Gets the upper bounds of the expression.
   *
   * Most of the work of computing the upper bounds is done by
   * `getUpperBoundsImpl`. However, the upper bounds computed by
   * `getUpperBoundsImpl` may not be representable by the result type of the
   * expression. For example, if `x` and `y` are of type `int32` and each
   * have upper bound 2147483647, then getUpperBoundsImpl` will compute an
   * upper bound 4294967294 for the expression `x+y`, even though 4294967294
   * cannot be represented as an `int32`. Such unrepresentable bounds are
   * replaced with `exprMaxVal(expr)`.  This predicate also adds
   * `exprMaxVal(expr)` as an upper bound if the expression might overflow
   * negatively, or if it is unanalyzable.
   *
   * Note: most callers should use `getFullyConvertedUpperBounds` rather than
   * this predicate.
   */
  private float getTruncatedUpperBounds(Expr expr) {
    (analyzableExpr(expr) or dividesNonzeroByZero(expr)) and
    (
      // If the expression evaluates to a constant, then there is no
      // need to call getUpperBoundsImpl.
      if
        exists(getValue(expr).toFloat()) and
        not getValue(expr) = "NaN"
      then result = getValue(expr).toFloat()
      else (
        // Some of the bounds computed by `getUpperBoundsImpl`
        // might overflow, so we replace invalid bounds with
        // `exprMaxVal`.
        exists(float newUB | newUB = normalizeFloatUp(getUpperBoundsImpl(expr)) |
          if Util::exprMinVal(expr) <= newUB and newUB <= Util::exprMaxVal(expr)
          then
            // Apply widening where we might get a combinatorial explosion.
            if applyWideningToBinary(expr)
            then
              result =
                min(float widenUB |
                  widenUB = wideningUpperBounds(expr.getUnspecifiedType()) and
                  not widenUB < newUB
                )
            else result = newUB
          else result = Util::exprMaxVal(expr)
        )
        or
        // The expression might overflow negatively and wrap. If so,
        // the upper bound is `exprMaxVal`.
        exprMightOverflowNegatively(expr) and
        result = Util::exprMaxVal(expr)
      )
    )
    or
    not analyzableExpr(expr) and
    // The expression is not analyzable, so its upper bound is
    // unknown. Note that the call to exprMaxVal restricts the
    // expressions to just those with arithmetic types. There is no
    // need to return results for non-arithmetic expressions.
    result = exprMaxVal(expr)
  }

  /** Only to be called by `getTruncatedLowerBounds`. */
  private float getLowerBoundsImpl(Expr expr) {
    (
      exists(Expr operand, float operandLow, float positive |
        effectivelyMultipliesByPositive(expr, operand, positive) and
        operandLow = getFullyConvertedLowerBounds(operand) and
        result = positive * operandLow
      )
      or
      exists(Expr operand, float operandHigh, float negative |
        effectivelyMultipliesByNegative(expr, operand, negative) and
        operandHigh = getFullyConvertedUpperBounds(operand) and
        result = negative * operandHigh
      )
      or
      exists(Expr operand, float operandLow, float positive |
        dividesByPositive(expr, operand, positive) and
        operandLow = getFullyConvertedLowerBounds(operand) and
        result = operandLow / positive
      )
      or
      exists(Expr operand, float operandLow, float negative |
        dividesByNegative(expr, operand, negative) and
        operandLow = getFullyConvertedUpperBounds(operand) and
        result = operandLow / negative
      )
      or
      exists(DivExpr div | expr = div |
        dividesNonzeroByZero(expr) and
        result = getFullyConvertedLowerBounds(div.getLeftOperand()) / 0
      )
      or
      exists(SupportedFunctionCall sfc | sfc.getFunctionCall() = expr |
        result = sfc.getLowerBound()
      )
      or
      exists(MinExpr minExpr |
        expr = minExpr and
        // Return the union of the lower bounds from both children.
        result = getFullyConvertedLowerBounds(minExpr.getAnOperand())
      )
      or
      exists(MaxExpr maxExpr |
        expr = maxExpr and
        // Compute the cross product of the bounds from both children.  We are
        // using this mathematical property:
        //
        //    max (minimum{X}, minimum{Y})
        //  = minimum { max(x,y) | x in X, y in Y }
        exists(float x, float y |
          x = getFullyConvertedLowerBounds(maxExpr.getLeftOperand()) and
          y = getFullyConvertedLowerBounds(maxExpr.getRightOperand()) and
          if x >= y then result = x else result = y
        )
      )
      or
      // ConditionalExpr (true branch)
      exists(ConditionalExpr condExpr |
        expr = condExpr and
        // Use `boolConversionUpperBound` to determine whether the condition
        // might evaluate to `true`.
        boolConversionUpperBound(condExpr.getCondition().getFullyConverted()) = 1 and
        result = getFullyConvertedLowerBounds(condExpr.getThen())
      )
      or
      // ConditionalExpr (false branch)
      exists(ConditionalExpr condExpr |
        expr = condExpr and
        // Use `boolConversionLowerBound` to determine whether the condition
        // might evaluate to `false`.
        boolConversionLowerBound(condExpr.getCondition().getFullyConverted()) = 0 and
        result = getFullyConvertedLowerBounds(condExpr.getElse())
      )
      or
      exists(AddExpr addExpr, float xLow, float yLow |
        expr = addExpr and
        xLow = getFullyConvertedLowerBounds(addExpr.getLeftOperand()) and
        yLow = getFullyConvertedLowerBounds(addExpr.getRightOperand()) and
        result = addRoundingDown(xLow, yLow)
      )
      or
      exists(SubExpr subExpr, float xLow, float yHigh |
        expr = subExpr and
        xLow = getFullyConvertedLowerBounds(subExpr.getLeftOperand()) and
        yHigh = getFullyConvertedUpperBounds(subExpr.getRightOperand()) and
        result = addRoundingDown(xLow, -yHigh)
      )
      or
      exists(UnsignedMulExpr mulExpr, float xLow, float yLow |
        expr = mulExpr and
        xLow = getFullyConvertedLowerBounds(mulExpr.getLeftOperand()) and
        yLow = getFullyConvertedLowerBounds(mulExpr.getRightOperand()) and
        result = xLow * yLow
      )
      or
      exists(AssignExpr assign |
        expr = assign and
        result = getFullyConvertedLowerBounds(assign.getRValue())
      )
      or
      exists(AssignAddExpr addExpr, float xLow, float yLow |
        expr = addExpr and
        xLow = getFullyConvertedLowerBounds(addExpr.getLValue()) and
        yLow = getFullyConvertedLowerBounds(addExpr.getRValue()) and
        result = addRoundingDown(xLow, yLow)
      )
      or
      exists(AssignSubExpr subExpr, float xLow, float yHigh |
        expr = subExpr and
        xLow = getFullyConvertedLowerBounds(subExpr.getLValue()) and
        yHigh = getFullyConvertedUpperBounds(subExpr.getRValue()) and
        result = addRoundingDown(xLow, -yHigh)
      )
      or
      exists(UnsignedAssignMulExpr mulExpr, float xLow, float yLow |
        expr = mulExpr and
        xLow = getFullyConvertedLowerBounds(mulExpr.getLValue()) and
        yLow = getFullyConvertedLowerBounds(mulExpr.getRValue()) and
        result = xLow * yLow
      )
      or
      exists(AssignMulByPositiveConstantExpr mulExpr, float xLow |
        expr = mulExpr and
        xLow = getFullyConvertedLowerBounds(mulExpr.getLValue()) and
        result = xLow * mulExpr.getConstant()
      )
      or
      exists(AssignMulByNegativeConstantExpr mulExpr, float xHigh |
        expr = mulExpr and
        xHigh = getFullyConvertedUpperBounds(mulExpr.getLValue()) and
        result = xHigh * mulExpr.getConstant()
      )
      or
      exists(PrefixIncrExpr incrExpr, float xLow |
        expr = incrExpr and
        xLow = getFullyConvertedLowerBounds(incrExpr.getOperand()) and
        result = xLow + 1
      )
      or
      exists(PrefixDecrExpr decrExpr, float xLow |
        expr = decrExpr and
        xLow = getFullyConvertedLowerBounds(decrExpr.getOperand()) and
        result = addRoundingDownSmall(xLow, -1)
      )
      or
      // `PostfixIncrExpr` and `PostfixDecrExpr` return the value of their
      // operand. The incrementing/decrementing behavior is handled in
      // `getDefLowerBoundsImpl`.
      exists(PostfixIncrExpr incrExpr |
        expr = incrExpr and
        result = getFullyConvertedLowerBounds(incrExpr.getOperand())
      )
      or
      exists(PostfixDecrExpr decrExpr |
        expr = decrExpr and
        result = getFullyConvertedLowerBounds(decrExpr.getOperand())
      )
      or
      exists(RemExpr remExpr | expr = remExpr |
        // If both inputs are positive then the lower bound is zero.
        result = 0
        or
        // If either input could be negative then the output could be
        // negative. If so, the lower bound of `x%y` is `-abs(y) + 1`, which is
        // equal to `min(-y + 1,y - 1)`.
        exists(float childLB |
          childLB = getFullyConvertedLowerBounds(remExpr.getAnOperand()) and
          not childLB >= 0
        |
          result = getFullyConvertedLowerBounds(remExpr.getRightOperand()) - 1
          or
          exists(float rhsUB | rhsUB = getFullyConvertedUpperBounds(remExpr.getRightOperand()) |
            result = -rhsUB + 1
          )
        )
      )
      or
      // If the conversion is to an arithmetic type then we just return the
      // lower bound of the child. We do not need to handle truncation and
      // overflow here, because that is done in `getTruncatedLowerBounds`.
      // Conversions to `bool` need to be handled specially because they test
      // whether the value of the expression is equal to 0.
      exists(Conversion convExpr | expr = convExpr |
        if convExpr.getUnspecifiedType() instanceof BoolType
        then result = boolConversionLowerBound(convExpr.getExpr())
        else result = getTruncatedLowerBounds(convExpr.getExpr())
      )
      or
      // Use SSA to get the lower bounds for a variable use.
      exists(RangeSsaDefinition def, StackVariable v | expr = def.getAUse(v) |
        result = getDefLowerBounds(def, v)
      )
      or
      // unsigned `&` (tighter bounds may exist)
      exists(UnsignedBitwiseAndExpr andExpr |
        andExpr = expr and
        result = 0.0
      )
      or
      // `>>` by a constant
      exists(RShiftExpr rsExpr, float left, int right |
        rsExpr = expr and
        left = getFullyConvertedLowerBounds(rsExpr.getLeftOperand()) and
        right = getValue(rsExpr.getRightOperand().getFullyConverted()).toInt() and
        result = safeFloor(left / 2.pow(right))
      )
    )
  }

  /** Only to be called by `getTruncatedUpperBounds`. */
  private float getUpperBoundsImpl(Expr expr) {
    (
      exists(Expr operand, float operandHigh, float positive |
        effectivelyMultipliesByPositive(expr, operand, positive) and
        operandHigh = getFullyConvertedUpperBounds(operand) and
        result = positive * operandHigh
      )
      or
      exists(Expr operand, float operandLow, float negative |
        effectivelyMultipliesByNegative(expr, operand, negative) and
        operandLow = getFullyConvertedLowerBounds(operand) and
        result = negative * operandLow
      )
      or
      exists(Expr operand, float operandHigh, float positive |
        dividesByPositive(expr, operand, positive) and
        operandHigh = getFullyConvertedUpperBounds(operand) and
        result = operandHigh / positive
      )
      or
      exists(Expr operand, float operandHigh, float negative |
        dividesByNegative(expr, operand, negative) and
        operandHigh = getFullyConvertedLowerBounds(operand) and
        result = operandHigh / negative
      )
      or
      exists(DivExpr div | expr = div |
        dividesNonzeroByZero(expr) and
        result = getFullyConvertedUpperBounds(div.getLeftOperand()) / 0
      )
      or
      exists(SupportedFunctionCall sfc | sfc.getFunctionCall() = expr |
        result = sfc.getUpperBound()
      )
      or
      exists(MaxExpr maxExpr |
        expr = maxExpr and
        // Return the union of the upper bounds from both children.
        result = getFullyConvertedUpperBounds(maxExpr.getAnOperand())
      )
      or
      exists(MinExpr minExpr |
        expr = minExpr and
        // Compute the cross product of the bounds from both children.  We are
        // using this mathematical property:
        //
        //    min (maximum{X}, maximum{Y})
        //  = maximum { min(x,y) | x in X, y in Y }
        exists(float x, float y |
          x = getFullyConvertedUpperBounds(minExpr.getLeftOperand()) and
          y = getFullyConvertedUpperBounds(minExpr.getRightOperand()) and
          if x <= y then result = x else result = y
        )
      )
      or
      // ConditionalExpr (true branch)
      exists(ConditionalExpr condExpr |
        expr = condExpr and
        // Use `boolConversionUpperBound` to determine whether the condition
        // might evaluate to `true`.
        boolConversionUpperBound(condExpr.getCondition().getFullyConverted()) = 1 and
        result = getFullyConvertedUpperBounds(condExpr.getThen())
      )
      or
      // ConditionalExpr (false branch)
      exists(ConditionalExpr condExpr |
        expr = condExpr and
        // Use `boolConversionLowerBound` to determine whether the condition
        // might evaluate to `false`.
        boolConversionLowerBound(condExpr.getCondition().getFullyConverted()) = 0 and
        result = getFullyConvertedUpperBounds(condExpr.getElse())
      )
      or
      exists(AddExpr addExpr, float xHigh, float yHigh |
        expr = addExpr and
        xHigh = getFullyConvertedUpperBounds(addExpr.getLeftOperand()) and
        yHigh = getFullyConvertedUpperBounds(addExpr.getRightOperand()) and
        result = addRoundingUp(xHigh, yHigh)
      )
      or
      exists(SubExpr subExpr, float xHigh, float yLow |
        expr = subExpr and
        xHigh = getFullyConvertedUpperBounds(subExpr.getLeftOperand()) and
        yLow = getFullyConvertedLowerBounds(subExpr.getRightOperand()) and
        result = addRoundingUp(xHigh, -yLow)
      )
      or
      exists(UnsignedMulExpr mulExpr, float xHigh, float yHigh |
        expr = mulExpr and
        xHigh = getFullyConvertedUpperBounds(mulExpr.getLeftOperand()) and
        yHigh = getFullyConvertedUpperBounds(mulExpr.getRightOperand()) and
        result = xHigh * yHigh
      )
      or
      exists(AssignExpr assign |
        expr = assign and
        result = getFullyConvertedUpperBounds(assign.getRValue())
      )
      or
      exists(AssignAddExpr addExpr, float xHigh, float yHigh |
        expr = addExpr and
        xHigh = getFullyConvertedUpperBounds(addExpr.getLValue()) and
        yHigh = getFullyConvertedUpperBounds(addExpr.getRValue()) and
        result = addRoundingUp(xHigh, yHigh)
      )
      or
      exists(AssignSubExpr subExpr, float xHigh, float yLow |
        expr = subExpr and
        xHigh = getFullyConvertedUpperBounds(subExpr.getLValue()) and
        yLow = getFullyConvertedLowerBounds(subExpr.getRValue()) and
        result = addRoundingUp(xHigh, -yLow)
      )
      or
      exists(UnsignedAssignMulExpr mulExpr, float xHigh, float yHigh |
        expr = mulExpr and
        xHigh = getFullyConvertedUpperBounds(mulExpr.getLValue()) and
        yHigh = getFullyConvertedUpperBounds(mulExpr.getRValue()) and
        result = xHigh * yHigh
      )
      or
      exists(AssignMulByPositiveConstantExpr mulExpr, float xHigh |
        expr = mulExpr and
        xHigh = getFullyConvertedUpperBounds(mulExpr.getLValue()) and
        result = xHigh * mulExpr.getConstant()
      )
      or
      exists(AssignMulByNegativeConstantExpr mulExpr, float xLow |
        expr = mulExpr and
        xLow = getFullyConvertedLowerBounds(mulExpr.getLValue()) and
        result = xLow * mulExpr.getConstant()
      )
      or
      exists(PrefixIncrExpr incrExpr, float xHigh |
        expr = incrExpr and
        xHigh = getFullyConvertedUpperBounds(incrExpr.getOperand()) and
        result = addRoundingUpSmall(xHigh, 1)
      )
      or
      exists(PrefixDecrExpr decrExpr, float xHigh |
        expr = decrExpr and
        xHigh = getFullyConvertedUpperBounds(decrExpr.getOperand()) and
        result = xHigh - 1
      )
      or
      // `PostfixIncrExpr` and `PostfixDecrExpr` return the value of their operand.
      // The incrementing/decrementing behavior is handled in
      // `getDefUpperBoundsImpl`.
      exists(PostfixIncrExpr incrExpr |
        expr = incrExpr and
        result = getFullyConvertedUpperBounds(incrExpr.getOperand())
      )
      or
      exists(PostfixDecrExpr decrExpr |
        expr = decrExpr and
        result = getFullyConvertedUpperBounds(decrExpr.getOperand())
      )
      or
      exists(RemExpr remExpr, float rhsUB |
        expr = remExpr and
        rhsUB = getFullyConvertedUpperBounds(remExpr.getRightOperand())
      |
        result = rhsUB - 1
        or
        // If the right hand side could be negative then we need to take its
        // absolute value. Since `abs(x) = max(-x,x)` this is equivalent to
        // adding `-rhsLB` to the set of upper bounds.
        exists(float rhsLB |
          rhsLB = getFullyConvertedLowerBounds(remExpr.getRightOperand()) and
          not rhsLB >= 0
        |
          result = -rhsLB + 1
        )
      )
      or
      // If the conversion is to an arithmetic type then we just return the
      // upper bound of the child. We do not need to handle truncation and
      // overflow here, because that is done in `getTruncatedUpperBounds`.
      // Conversions to `bool` need to be handled specially because they test
      // whether the value of the expression is equal to 0.
      exists(Conversion convExpr | expr = convExpr |
        if convExpr.getUnspecifiedType() instanceof BoolType
        then result = boolConversionUpperBound(convExpr.getExpr())
        else result = getTruncatedUpperBounds(convExpr.getExpr())
      )
      or
      // Use SSA to get the upper bounds for a variable use.
      exists(RangeSsaDefinition def, StackVariable v | expr = def.getAUse(v) |
        result = getDefUpperBounds(def, v)
      )
      or
      // unsigned `&` (tighter bounds may exist)
      exists(UnsignedBitwiseAndExpr andExpr, float left, float right |
        andExpr = expr and
        left = getFullyConvertedUpperBounds(andExpr.getLeftOperand()) and
        right = getFullyConvertedUpperBounds(andExpr.getRightOperand()) and
        result = left.minimum(right)
      )
      or
      // `>>` by a constant
      exists(RShiftExpr rsExpr, float left, int right |
        rsExpr = expr and
        left = getFullyConvertedUpperBounds(rsExpr.getLeftOperand()) and
        right = getValue(rsExpr.getRightOperand().getFullyConverted()).toInt() and
        result = safeFloor(left / 2.pow(right))
      )
    )
  }

  /**
   * Holds if `expr` is converted to `bool` or if it is the child of a
   * logical operation.
   *
   * The purpose of this predicate is to optimize `boolConversionLowerBound`
   * and `boolConversionUpperBound` by preventing them from computing
   * unnecessary results. In other words, `exprIsUsedAsBool(expr)` holds if
   * `expr` is an expression that might be passed as an argument to
   * `boolConversionLowerBound` or `boolConversionUpperBound`.
   */
  private predicate exprIsUsedAsBool(Expr expr) {
    expr = any(BinaryLogicalOperation op).getAnOperand().getFullyConverted()
    or
    expr = any(UnaryLogicalOperation op).getOperand().getFullyConverted()
    or
    expr = any(ConditionalExpr c).getCondition().getFullyConverted()
    or
    exists(Conversion cast | cast.getUnspecifiedType() instanceof BoolType | expr = cast.getExpr())
  }

  /**
   * Gets the lower bound of the conversion `(bool)expr`. If we can prove that
   * the value of `expr` is never 0 then `lb = 1`. Otherwise `lb = 0`.
   */
  private float boolConversionLowerBound(Expr expr) {
    // Case 1: if the range for `expr` includes the value 0,
    // then `result = 0`.
    exprIsUsedAsBool(expr) and
    exists(float lb | lb = getTruncatedLowerBounds(expr) and not lb > 0) and
    exists(float ub | ub = getTruncatedUpperBounds(expr) and not ub < 0) and
    result = 0
    or
    // Case 2a: if the range for `expr` does not include the value 0,
    // then `result = 1`.
    exprIsUsedAsBool(expr) and getTruncatedLowerBounds(expr) > 0 and result = 1
    or
    // Case 2b: if the range for `expr` does not include the value 0,
    // then `result = 1`.
    exprIsUsedAsBool(expr) and getTruncatedUpperBounds(expr) < 0 and result = 1
    or
    // Case 3: the type of `expr` is not arithmetic. For example, it might
    // be a pointer.
    exprIsUsedAsBool(expr) and not exists(Util::exprMinVal(expr)) and result = 0
  }

  /**
   * Gets the upper bound of the conversion `(bool)expr`. If we can prove that
   * the value of `expr` is always 0 then `ub = 0`. Otherwise `ub = 1`.
   */
  private float boolConversionUpperBound(Expr expr) {
    // Case 1a: if the upper bound of the operand is <= 0, then the upper
    // bound might be 0.
    exprIsUsedAsBool(expr) and getTruncatedUpperBounds(expr) <= 0 and result = 0
    or
    // Case 1b: if the upper bound of the operand is not <= 0, then the upper
    // bound is 1.
    exprIsUsedAsBool(expr) and
    exists(float ub | ub = getTruncatedUpperBounds(expr) and not ub <= 0) and
    result = 1
    or
    // Case 2a: if the lower bound of the operand is >= 0, then the upper
    // bound might be 0.
    exprIsUsedAsBool(expr) and getTruncatedLowerBounds(expr) >= 0 and result = 0
    or
    // Case 2b: if the lower bound of the operand is not >= 0, then the upper
    // bound is 1.
    exprIsUsedAsBool(expr) and
    exists(float lb | lb = getTruncatedLowerBounds(expr) and not lb >= 0) and
    result = 1
    or
    // Case 3: the type of `expr` is not arithmetic. For example, it might
    // be a pointer.
    exprIsUsedAsBool(expr) and not exists(Util::exprMaxVal(expr)) and result = 1
  }

  /**
   * This predicate computes the lower bounds of a phi definition. If the
   * phi definition corresponds to a guard, then the guard is used to
   * deduce a better lower bound.
   * For example:
   *
   *     def:      x = y % 10;
   *     guard:    if (x >= 2) {
   *     block:      f(x)
   *               }
   *
   * In this example, the lower bound of x is 0, but we can
   * use the guard to deduce that the lower bound is 2 inside the block.
   */
  private float getPhiLowerBounds(StackVariable v, RangeSsaDefinition phi) {
    exists(VariableAccess access, Expr guard, boolean branch, float defLB, float guardLB |
      phi.isGuardPhi(v, access, guard, branch) and
      lowerBoundFromGuard(guard, access, guardLB, branch) and
      defLB = getFullyConvertedLowerBounds(access)
    |
      // Compute the maximum of `guardLB` and `defLB`.
      if guardLB > defLB then result = guardLB else result = defLB
    )
    or
    exists(VariableAccess access, float neConstant, float lower |
      isNEPhi(v, phi, access, neConstant) and
      lower = getTruncatedLowerBounds(access) and
      if lower = neConstant then result = lower + 1 else result = lower
    )
    or
    exists(VariableAccess access |
      isUnsupportedGuardPhi(v, phi, access) and
      result = getTruncatedLowerBounds(access)
    )
    or
    result = getDefLowerBounds(phi.getAPhiInput(v), v)
  }

  /** See comment for `getPhiLowerBounds`, above. */
  private float getPhiUpperBounds(StackVariable v, RangeSsaDefinition phi) {
    exists(VariableAccess access, Expr guard, boolean branch, float defUB, float guardUB |
      phi.isGuardPhi(v, access, guard, branch) and
      upperBoundFromGuard(guard, access, guardUB, branch) and
      defUB = getFullyConvertedUpperBounds(access)
    |
      // Compute the minimum of `guardUB` and `defUB`.
      if guardUB < defUB then result = guardUB else result = defUB
    )
    or
    exists(VariableAccess access, float neConstant, float upper |
      isNEPhi(v, phi, access, neConstant) and
      upper = getTruncatedUpperBounds(access) and
      if upper = neConstant then result = upper - 1 else result = upper
    )
    or
    exists(VariableAccess access |
      isUnsupportedGuardPhi(v, phi, access) and
      result = getTruncatedUpperBounds(access)
    )
    or
    result = getDefUpperBounds(phi.getAPhiInput(v), v)
  }

  /** Only to be called by `getDefLowerBounds`. */
  private float getDefLowerBoundsImpl(RangeSsaDefinition def, StackVariable v) {
    // Definitions with a defining value.
    exists(Expr expr | assignmentDef(def, v, expr) | result = getFullyConvertedLowerBounds(expr))
    or
    // Assignment operations with a defining value
    exists(AssignOperation assignOp |
      def = assignOp and
      assignOp.getLValue() = v.getAnAccess() and
      result = getTruncatedLowerBounds(assignOp)
    )
    or
    exists(IncrementOperation incr, float newLB |
      def = incr and
      incr.getOperand() = v.getAnAccess() and
      newLB = getFullyConvertedLowerBounds(incr.getOperand()) and
      result = newLB + 1
    )
    or
    exists(DecrementOperation decr, float newLB |
      def = decr and
      decr.getOperand() = v.getAnAccess() and
      newLB = getFullyConvertedLowerBounds(decr.getOperand()) and
      result = addRoundingDownSmall(newLB, -1)
    )
    or
    // Phi nodes.
    result = getPhiLowerBounds(v, def)
    or
    // Unanalyzable definitions.
    unanalyzableDefBounds(def, v, result, _)
  }

  /** Only to be called by `getDefUpperBounds`. */
  private float getDefUpperBoundsImpl(RangeSsaDefinition def, StackVariable v) {
    // Definitions with a defining value.
    exists(Expr expr | assignmentDef(def, v, expr) | result = getFullyConvertedUpperBounds(expr))
    or
    // Assignment operations with a defining value
    exists(AssignOperation assignOp |
      def = assignOp and
      assignOp.getLValue() = v.getAnAccess() and
      result = getTruncatedUpperBounds(assignOp)
    )
    or
    exists(IncrementOperation incr, float newUB |
      def = incr and
      incr.getOperand() = v.getAnAccess() and
      newUB = getFullyConvertedUpperBounds(incr.getOperand()) and
      result = addRoundingUpSmall(newUB, 1)
    )
    or
    exists(DecrementOperation decr, float newUB |
      def = decr and
      decr.getOperand() = v.getAnAccess() and
      newUB = getFullyConvertedUpperBounds(decr.getOperand()) and
      result = newUB - 1
    )
    or
    // Phi nodes.
    result = getPhiUpperBounds(v, def)
    or
    // Unanalyzable definitions.
    unanalyzableDefBounds(def, v, _, result)
  }

  /**
   * Helper for `getDefLowerBounds` and `getDefUpperBounds`. Find the set of
   * unanalyzable definitions (such as function parameters) and make their
   * bounds unknown.
   */
  private predicate unanalyzableDefBounds(
    RangeSsaDefinition def, StackVariable v, float lb, float ub
  ) {
    v = def.getAVariable() and
    not analyzableDef(def, v) and
    lb = varMinVal(v) and
    ub = varMaxVal(v)
  }

  /**
   * Holds if in the `branch` branch of a guard `guard` involving `v`,
   * we know that `v` is not NaN, and therefore it is safe to make range
   * inferences about `v`.
   */
  bindingset[guard, v, branch]
  predicate nonNanGuardedVariable(Expr guard, VariableAccess v, boolean branch) {
    Util::getVariableRangeType(v.getTarget()) instanceof IntegralType
    or
    Util::getVariableRangeType(v.getTarget()) instanceof FloatingPointType and
    v instanceof NonNanVariableAccess
    or
    // The reason the following case is here is to ensure that when we say
    // `if (x > 5) { ...then... } else { ...else... }`
    // it is ok to conclude that `x > 5` in the `then`, (though not safe
    // to conclude that x <= 5 in `else`) even if we had no prior
    // knowledge of `x` not being `NaN`.
    nanExcludingComparison(guard, branch)
  }

  /**
   * If the guard is a comparison of the form `p*v + q <CMP> r`, then this
   * predicate uses the bounds information for `r` to compute a lower bound
   * for `v`.
   */
  private predicate lowerBoundFromGuard(Expr guard, VariableAccess v, float lb, boolean branch) {
    exists(float childLB, Util::RelationStrictness strictness |
      boundFromGuard(guard, v, childLB, true, strictness, branch)
    |
      if nonNanGuardedVariable(guard, v, branch)
      then
        if
          strictness = Util::Nonstrict() or
          not Util::getVariableRangeType(v.getTarget()) instanceof IntegralType
        then lb = childLB
        else lb = childLB + 1
      else lb = varMinVal(v.getTarget())
    )
  }

  /**
   * If the guard is a comparison of the form `p*v + q <CMP> r`, then this
   * predicate uses the bounds information for `r` to compute a upper bound
   * for `v`.
   */
  private predicate upperBoundFromGuard(Expr guard, VariableAccess v, float ub, boolean branch) {
    exists(float childUB, Util::RelationStrictness strictness |
      boundFromGuard(guard, v, childUB, false, strictness, branch)
    |
      if nonNanGuardedVariable(guard, v, branch)
      then
        if
          strictness = Util::Nonstrict() or
          not Util::getVariableRangeType(v.getTarget()) instanceof IntegralType
        then ub = childUB
        else ub = childUB - 1
      else ub = varMaxVal(v.getTarget())
    )
  }

  /**
   * This predicate simplifies the results returned by
   * `linearBoundFromGuard`.
   */
  private predicate boundFromGuard(
    Expr guard, VariableAccess v, float boundValue, boolean isLowerBound,
    Util::RelationStrictness strictness, boolean branch
  ) {
    exists(float p, float q, float r, boolean isLB |
      linearBoundFromGuard(guard, v, p, q, r, isLB, strictness, branch) and
      boundValue = (r - q) / p
    |
      // If the multiplier is negative then the direction of the comparison
      // needs to be flipped.
      p > 0 and isLowerBound = isLB
      or
      p < 0 and isLowerBound = isLB.booleanNot()
    )
    or
    // When `!e` is true, we know that `0 <= e <= 0`
    exists(float p, float q, Expr e |
      Util::linearAccess(e, v, p, q) and
      Util::eqZeroWithNegate(guard, e, true, branch) and
      boundValue = (0.0 - q) / p and
      isLowerBound = [false, true] and
      strictness = Util::Nonstrict()
    )
  }

  /**
   * This predicate finds guards of the form `p*v + q < r or p*v + q == r`
   * and decomposes them into a tuple of values which can be used to deduce a
   * lower or upper bound for `v`.
   */
  private predicate linearBoundFromGuard(
    ComparisonOperation guard, VariableAccess v, float p, float q, float boundValue,
    boolean isLowerBound, // Is this a lower or an upper bound?
    Util::RelationStrictness strictness, boolean branch // Which control-flow branch is this bound valid on?
  ) {
    // For the comparison x < RHS, we create two bounds:
    //
    //   1. x < upperbound(RHS)
    //   2. x >= typeLowerBound(RHS.getUnspecifiedType())
    //
    exists(Expr lhs, Expr rhs, Util::RelationDirection dir, Util::RelationStrictness st |
      Util::linearAccess(lhs, v, p, q) and
      Util::relOpWithSwapAndNegate(guard, lhs, rhs, dir, st, branch)
    |
      isLowerBound = Util::directionIsGreater(dir) and
      strictness = st and
      getBounds(rhs, boundValue, isLowerBound)
      or
      isLowerBound = Util::directionIsLesser(dir) and
      strictness = Util::Nonstrict() and
      exprTypeBounds(rhs, boundValue, isLowerBound)
    )
    or
    // For x == RHS, we create the following bounds:
    //
    //   1. x <= upperbound(RHS)
    //   2. x >= lowerbound(RHS)
    //
    exists(Expr lhs, Expr rhs |
      Util::linearAccess(lhs, v, p, q) and
      Util::eqOpWithSwapAndNegate(guard, lhs, rhs, true, branch) and
      getBounds(rhs, boundValue, isLowerBound) and
      strictness = Util::Nonstrict()
    )
    // x != RHS and !x are handled elsewhere
  }

  /** Utility for `linearBoundFromGuard`. */
  private predicate getBounds(Expr expr, float boundValue, boolean isLowerBound) {
    isLowerBound = true and boundValue = getFullyConvertedLowerBounds(expr)
    or
    isLowerBound = false and boundValue = getFullyConvertedUpperBounds(expr)
  }

  /** Utility for `linearBoundFromGuard`. */
  private predicate exprTypeBounds(Expr expr, float boundValue, boolean isLowerBound) {
    isLowerBound = true and boundValue = exprMinVal(expr.getFullyConverted())
    or
    isLowerBound = false and boundValue = exprMaxVal(expr.getFullyConverted())
  }

  /**
   * Holds if `(v, phi)` ensures that `access` is not equal to `neConstant`. For
   * example, the condition `if (x + 1 != 3)` ensures that `x` is not equal to 2.
   * Only integral types are supported.
   */
  private predicate isNEPhi(
    Variable v, RangeSsaDefinition phi, VariableAccess access, float neConstant
  ) {
    exists(
      ComparisonOperation cmp, boolean branch, Expr linearExpr, Expr rExpr, float p, float q,
      float r
    |
      phi.isGuardPhi(v, access, cmp, branch) and
      Util::eqOpWithSwapAndNegate(cmp, linearExpr, rExpr, false, branch) and
      v.getUnspecifiedType() instanceof IntegralOrEnumType and // Float `!=` is too imprecise
      r = getValue(rExpr).toFloat() and
      Util::linearAccess(linearExpr, access, p, q) and
      neConstant = (r - q) / p
    )
    or
    exists(Expr op, boolean branch, Expr linearExpr, float p, float q |
      phi.isGuardPhi(v, access, op, branch) and
      Util::eqZeroWithNegate(op, linearExpr, false, branch) and
      v.getUnspecifiedType() instanceof IntegralOrEnumType and // Float `!` is too imprecise
      Util::linearAccess(linearExpr, access, p, q) and
      neConstant = (0.0 - q) / p
    )
  }

  /**
   * Holds if `(v, phi)` constrains the value of `access` but in a way that
   * doesn't allow this library to constrain the upper or lower bounds of
   * `access`. An example is `if (x != y)` if neither `x` nor `y` is a
   * compile-time constant.
   */
  private predicate isUnsupportedGuardPhi(Variable v, RangeSsaDefinition phi, VariableAccess access) {
    exists(Expr cmp, boolean branch |
      Util::eqOpWithSwapAndNegate(cmp, _, _, false, branch)
      or
      Util::eqZeroWithNegate(cmp, _, false, branch)
    |
      phi.isGuardPhi(v, access, cmp, branch) and
      not isNEPhi(v, phi, access, _)
    )
  }

  /**
   * Gets the upper bound of the expression, if the expression is guarded.
   * An upper bound can only be found, if a guard phi node can be found, and the
   * expression has only one immediate predecessor.
   */
  private float getGuardedUpperBound(VariableAccess guardedAccess) {
    exists(
      RangeSsaDefinition def, StackVariable v, VariableAccess guardVa, Expr guard, boolean branch
    |
      def.isGuardPhi(v, guardVa, guard, branch) and
      // If the basic block for the variable access being examined has
      // more than one predecessor, the guard phi node could originate
      // from one of the predecessors. This is because the guard phi
      // node is attached to the block at the end of the edge and not on
      // the actual edge. It is therefore not possible to determine which
      // edge the guard phi node belongs to. The predicate below ensures
      // that there is one predecessor, albeit somewhat conservative.
      exists(unique(BasicBlock b | b = def.(BasicBlock).getAPredecessor())) and
      guardedAccess = def.getAUse(v) and
      result = max(float ub | upperBoundFromGuard(guard, guardVa, ub, branch)) and
      not convertedExprMightOverflow(guard.getAChild+())
    )
  }

  cached
  private module SimpleRangeAnalysisCached {
    /**
     * Gets the lower bound of the expression.
     *
     * Note: expressions in C/C++ are often implicitly or explicitly cast to a
     * different result type. Such casts can cause the value of the expression
     * to overflow or to be truncated. This predicate computes the lower bound
     * of the expression without including the effect of the casts. To compute
     * the lower bound of the expression after all the casts have been applied,
     * call `lowerBound` like this:
     *
     *    `lowerBound(expr.getFullyConverted())`
     */
    cached
    float lowerBound(Expr expr) {
      // Combine the lower bounds returned by getTruncatedLowerBounds into a
      // single minimum value.
      result = min(float lb | lb = getTruncatedLowerBounds(expr) | lb)
    }

    /**
     * Gets the upper bound of the expression.
     *
     * Note: expressions in C/C++ are often implicitly or explicitly cast to a
     * different result type. Such casts can cause the value of the expression
     * to overflow or to be truncated. This predicate computes the upper bound
     * of the expression without including the effect of the casts. To compute
     * the upper bound of the expression after all the casts have been applied,
     * call `upperBound` like this:
     *
     *    `upperBound(expr.getFullyConverted())`
     */
    cached
    float upperBound(Expr expr) {
      // Combine the upper bounds returned by getTruncatedUpperBounds and
      // getGuardedUpperBound into a single maximum value
      result = min([max(getTruncatedUpperBounds(expr)), getGuardedUpperBound(expr)])
    }

    /** Holds if the upper bound of `expr` may have been widened. This means the upper bound is in practice likely to be overly wide. */
    cached
    predicate upperBoundMayBeWidened(Expr e) {
      isRecursiveExpr(e) and
      // Widening is not a problem if the post-analysis in `getGuardedUpperBound` has overridden the widening.
      // Note that the RHS of `<` may be multi-valued.
      not getGuardedUpperBound(e) < getTruncatedUpperBounds(e)
    }

    /**
     * Holds if `expr` has a provably empty range. For example:
     *
     *   10 < expr and expr < 5
     *
     * The range of an expression can only be empty if it can never be
     * executed. For example:
     *
     *   if (10 < x) {
     *     if (x < 5) {
     *       // Unreachable code
     *       return x; // x has an empty range: 10 < x && x < 5
     *     }
     *   }
     */
    cached
    predicate exprWithEmptyRange(Expr expr) {
      analyzableExpr(expr) and
      (
        not exists(lowerBound(expr)) or
        not exists(upperBound(expr)) or
        lowerBound(expr) > upperBound(expr)
      )
    }

    /** Holds if the definition might overflow negatively. */
    cached
    predicate defMightOverflowNegatively(RangeSsaDefinition def, StackVariable v) {
      getDefLowerBoundsImpl(def, v) < Util::varMinVal(v)
    }

    /** Holds if the definition might overflow positively. */
    cached
    predicate defMightOverflowPositively(RangeSsaDefinition def, StackVariable v) {
      getDefUpperBoundsImpl(def, v) > Util::varMaxVal(v)
    }

    /**
     * Holds if the definition might overflow (either positively or
     * negatively).
     */
    cached
    predicate defMightOverflow(RangeSsaDefinition def, StackVariable v) {
      defMightOverflowNegatively(def, v) or
      defMightOverflowPositively(def, v)
    }

    /**
     * Holds if `e` is an expression where the concept of overflow makes sense.
     * This predicate is used to filter out some of the unanalyzable expressions
     * from `exprMightOverflowPositively` and `exprMightOverflowNegatively`.
     */
    pragma[inline]
    private predicate exprThatCanOverflow(Expr e) {
      e instanceof UnaryArithmeticOperation or
      e instanceof BinaryArithmeticOperation or
      e instanceof AssignArithmeticOperation or
      e instanceof LShiftExpr or
      e instanceof AssignLShiftExpr
    }

    /**
     * Holds if the expression might overflow negatively. This predicate
     * does not consider the possibility that the expression might overflow
     * due to a conversion.
     */
    cached
    predicate exprMightOverflowNegatively(Expr expr) {
      getLowerBoundsImpl(expr) < Util::exprMinVal(expr)
      or
      // The lower bound of the expression `x--` is the same as the lower
      // bound of `x`, so the standard logic (above) does not work for
      // detecting whether it might overflow.
      getLowerBoundsImpl(expr.(PostfixDecrExpr)) = Util::exprMinVal(expr)
      or
      // We can't conclude that any unanalyzable expression might overflow. This
      // is because there are many expressions that the range analysis doesn't
      // handle, but where the concept of overflow doesn't make sense.
      exprThatCanOverflow(expr) and not analyzableExpr(expr)
    }

    /**
     * Holds if the expression might overflow negatively. Conversions
     * are also taken into account. For example the expression
     * `(int16)(x+y)` might overflow due to the `(int16)` cast, rather than
     * due to the addition.
     */
    cached
    predicate convertedExprMightOverflowNegatively(Expr expr) {
      exprMightOverflowNegatively(expr) or
      convertedExprMightOverflowNegatively(expr.getConversion())
    }

    /**
     * Holds if the expression might overflow positively. This predicate
     * does not consider the possibility that the expression might overflow
     * due to a conversion.
     */
    cached
    predicate exprMightOverflowPositively(Expr expr) {
      getUpperBoundsImpl(expr) > Util::exprMaxVal(expr)
      or
      // The upper bound of the expression `x++` is the same as the upper
      // bound of `x`, so the standard logic (above) does not work for
      // detecting whether it might overflow.
      getUpperBoundsImpl(expr.(PostfixIncrExpr)) = Util::exprMaxVal(expr)
    }

    /**
     * Holds if the expression might overflow positively. Conversions
     * are also taken into account. For example the expression
     * `(int16)(x+y)` might overflow due to the `(int16)` cast, rather than
     * due to the addition.
     */
    cached
    predicate convertedExprMightOverflowPositively(Expr expr) {
      exprMightOverflowPositively(expr) or
      convertedExprMightOverflowPositively(expr.getConversion())
    }

    /**
     * Holds if the expression might overflow (either positively or
     * negatively). The possibility that the expression might overflow
     * due to an implicit or explicit cast is also considered.
     */
    cached
    predicate convertedExprMightOverflow(Expr expr) {
      convertedExprMightOverflowNegatively(expr) or
      convertedExprMightOverflowPositively(expr)
    }
  }

  /**
   * Gets the truncated lower bounds of the fully converted expression.
   */
  float getFullyConvertedLowerBounds(Expr expr) {
    result = getTruncatedLowerBounds(expr.getFullyConverted())
  }

  /**
   * Gets the truncated upper bounds of the fully converted expression.
   */
  float getFullyConvertedUpperBounds(Expr expr) {
    result = getTruncatedUpperBounds(expr.getFullyConverted())
  }

  /**
   * Get the lower bounds for a `RangeSsaDefinition`. Most of the work is
   * done by `getDefLowerBoundsImpl`, but this is where widening is applied
   * to prevent the analysis from exploding due to a recursive definition.
   */
  float getDefLowerBounds(RangeSsaDefinition def, StackVariable v) {
    exists(float newLB, float truncatedLB |
      newLB = getDefLowerBoundsImpl(def, v) and
      if Util::varMinVal(v) <= newLB and newLB <= Util::varMaxVal(v)
      then truncatedLB = newLB
      else truncatedLB = Util::varMinVal(v)
    |
      // Widening: check whether the new lower bound is from a source which
      // depends recursively on the current definition.
      if isRecursiveDef(def, v)
      then
        // The new lower bound is from a recursive source, so we round
        // down to one of a limited set of values to prevent the
        // recursion from exploding.
        result =
          max(float widenLB |
            widenLB = wideningLowerBounds(Util::getVariableRangeType(v)) and
            not widenLB > truncatedLB
          |
            widenLB
          )
      else result = truncatedLB
    )
    or
    // The definition might overflow positively and wrap. If so, the lower
    // bound is `typeLowerBound`.
    defMightOverflowPositively(def, v) and result = Util::varMinVal(v)
  }

  /** See comment for `getDefLowerBounds`, above. */
  float getDefUpperBounds(RangeSsaDefinition def, StackVariable v) {
    exists(float newUB, float truncatedUB |
      newUB = getDefUpperBoundsImpl(def, v) and
      if Util::varMinVal(v) <= newUB and newUB <= Util::varMaxVal(v)
      then truncatedUB = newUB
      else truncatedUB = Util::varMaxVal(v)
    |
      // Widening: check whether the new upper bound is from a source which
      // depends recursively on the current definition.
      if isRecursiveDef(def, v)
      then
        // The new upper bound is from a recursive source, so we round
        // up to one of a fixed set of values to prevent the recursion
        // from exploding.
        result =
          min(float widenUB |
            widenUB = wideningUpperBounds(Util::getVariableRangeType(v)) and
            not widenUB < truncatedUB
          |
            widenUB
          )
      else result = truncatedUB
    )
    or
    // The definition might overflow negatively and wrap. If so, the upper
    // bound is `typeUpperBound`.
    defMightOverflowNegatively(def, v) and result = Util::varMaxVal(v)
  }
}
