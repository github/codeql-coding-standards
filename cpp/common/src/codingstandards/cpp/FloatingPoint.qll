import codeql.util.Boolean
import codingstandards.cpp.RestrictedRangeAnalysis

predicate exprMayEqualZero(Expr e) {
  RestrictedRangeAnalysis::upperBound(e) >= 0 and
  RestrictedRangeAnalysis::lowerBound(e) <= 0 and
  not guardedNotEqualZero(e)
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

predicate guardedNotInfinite(Expr e) {
  /* Note Boolean cmpEq, false means cmpNeq */
  exists(Expr c, GuardCondition guard, boolean cmpEq |
    hashCons(c) = hashCons(e) and
    guard.controls(e, cmpEq) and
    guard.comparesEq(c, 0, cmpEq.booleanNot(), _)
  )
}

predicate test(Expr e, Expr v, int k, boolean areEqual, Boolean value, Expr gce, BasicBlock bb) {
  exists(GuardCondition gc | gce = gc |
    gc.controls(bb, _) and
    gc.comparesEq(e, v, k, areEqual, value) and
    (
      //gc.getAChild+().toString().matches("%dfYRes%") or
      e.getAChild*().toString().matches("%dfPseudoPanchro%") or
      v.getAChild*().toString().matches("%dfPseudoPanchro%")
    )
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
  )
}