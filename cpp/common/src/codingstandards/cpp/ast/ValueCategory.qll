import cpp

/**
 * Get an expression's value category as a ValueCategory object.
 *
 * Note that the standard cpp library exposes `is{_}ValueCategory` predicates, but they do not
 * correctly work with conversions. This function is intended to give the correct answer in the
 * presence of conversions such as lvalue-to-rvalue conversion.
 */
ValueCategory getValueCategory(Expr e) {
  not exists(e.getConversion()) and
  result = getDirectValueCategory(e)
  or
  if e.getConversion() instanceof ReferenceToExpr
  then result = getDirectValueCategory(e)
  else result = getDirectValueCategory(e.getConversion())
}

private ValueCategory getDirectValueCategory(Expr e) {
  if e.isLValueCategory()
  then result = LValue(e.getValueCategoryString())
  else
    if e.isPRValueCategory()
    then result = PRValue(e.getValueCategoryString())
    else
      if e.isXValueCategory()
      then result = XValue(e.getValueCategoryString())
      else none()
}

newtype TValueCategory =
  LValue(string descr) {
    exists(Expr e | e.isLValueCategory() and descr = e.getValueCategoryString())
  } or
  PRValue(string descr) {
    exists(Expr e | e.isPRValueCategory() and descr = e.getValueCategoryString())
  } or
  XValue(string descr) {
    exists(Expr e | e.isXValueCategory() and descr = e.getValueCategoryString())
  }

class ValueCategory extends TValueCategory {
  string description;

  ValueCategory() {
    this = LValue(description) or this = PRValue(description) or this = XValue(description)
  }

  predicate isLValue() { this instanceof LValue }

  predicate isPRValue() { this instanceof PRValue }

  predicate isXValue() { this instanceof XValue }

  predicate isRValue() { this instanceof PRValue or this instanceof XValue }

  predicate isGlvalue() { this instanceof LValue or this instanceof XValue }

  string toString() { result = description }
}
