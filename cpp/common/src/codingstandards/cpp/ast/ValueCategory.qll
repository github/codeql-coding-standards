import cpp

/**
 * Get an expression's value category as a ValueCategory object.
 *
 * Note that the standard cpp library exposes `is{_}ValueCategory` predicates, but they do not
 * necessarily work as expected due to how CodeQL handles reference adjustment and binding, which
 * this predicate attempts to handle. There are additional unhandled cases involving
 * lvalue-to-rvalue conversions as well.
 *
 * In C++17, an expression of type "reference to T" is adjusted to type T as stated in [expr]/5.
 * This is not a conversion, but in CodeQL this is handled by `ReferenceDereferenceExpr`, a type of
 * `Conversion`. Similarly, the binding of references to values is described in [dcl.init.ref],
 * which is not a conversion, but in CodeQL this is handled by `ReferenceToExpr`, another type of
 * `Conversion`.
 *
 * Furthermore, the `Expr` predicate `hasLValueToRValueConversion()` uses a different dbscheme table
 * than the `Conversion` table, and it is possible to have expressions such that
 * `hasLValueToRValueConversion()` holds, but there is no corresponding `Conversion` entry.
 *
 * Therefore, the value categories of expressions before `ReferenceDereferenceExpr` and after
 * `ReferenceToExpr` conversions are therefore essentially unspecified, and the `is{_}ValueCategory`
 * predicate results should not be relied upon. And types that are missing a
 * `LvalueToRValueConversion` will also return incorrect value categories.
 *
 * For example, in CodeQL 2.21.4:
 *
 * ```cpp
 * int &i = ...;
 * auto r = std::move(i); // 1.) i is a `prvalue(load)` in CodeQL, not an lvalue.
 *                        // 2.) i has a `ReferenceDereferenceExpr` conversion of lvalue category
 *                        // 3.) the conversion from 2 has a `ReferenceToExpr` conversion of prvalue
 *                        //     category.
 * int i2 = ...;
 * f(i2); // 1.) i2 is an lvalue.
 *        // 2.) i2 undergoes lvalue-to-rvalue conversion, but there is no corresponding `Conversion`.
 *        // 3.) i2 is treated at a prvalue by CodeQL, but `hasLValueToRValueConversion()` holds.
 *
 * int get_int();
 * auto r2 = std::move(get_int()); // 1.) get_int() itself is treated as a prvalue by CodeQL.
 *                                 // 2.) get_int() has a `TemporaryObjectExpr` conversion of lvalue
 *                                 //     category.
 *                                 // 3.) the conversion from 2 has a `ReferenceToExpr` conversion
 *                                 //     of prvalue category.
 * std::string get_str();
 * auto r3 = std::move(get_str()); // 1.) get_str() is treated as a prvalue by CodeQL.
 *                                 // 2.) get_str() has a `TemporaryObjectExpr` conversion of xvalue
 *                                 // 3.) the conversion from 2 has a `ReferenceToExpr` conversion
 *                                 //     of prvalue category.
 * std::string &str_ref();
 * auto r3 = std::move(str_ref()); // 1.) str_ref() is treated as a prvalue by CodeQL.
 *                                 // 2.) str_ref() has a `ReferenceDereferenceExpr` conversion of
 *                                 //     lvalue.
 *                                 // 3.) the conversion from 2 has a `ReferenceToExpr` conversion
 *                                 //     of prvalue category.
 * ```
 *
 * As can be seen above, the value categories of expressions are correct between the
 * `ReferenceDereferenceExpr` and `ReferenceToExpr`, but not necessarily before or after.
 *
 * We must also check for `hasLValueToRValueConversion()` and handle that appropriately.
 */
ValueCategory getValueCategory(Expr e) {
  // If `e` is adjusted from a reference to a value (C++17 [expr]/5) then we want the value category
  // of the expression after `ReferenceDereferenceExpr`.
  if e.getConversion() instanceof ReferenceDereferenceExpr
  then result = getValueCategory(e.getConversion())
  else (
    // If `hasLValueToRValueConversion()` holds, then ensure we have an lvalue category.
    if e.hasLValueToRValueConversion()
    then result.isLValue()
    else
      // Otherwise, get the value category from `is{_}ValueCategory` predicates as normal.
      result = getDirectValueCategory(e)
  )
}

/**
 * Gets the value category of an expression using `is{_}ValueCategory` predicates, without looking
 * through conversions.
 */
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

/**
 * A value category, which can be an lvalue, prvalue, or xvalue.
 *
 * Note that prvalue has two possible forms: `prvalue` and `prvalue(load)`.
 */
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
