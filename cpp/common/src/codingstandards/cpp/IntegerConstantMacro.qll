import cpp

/**
 * The family of macros `xINTsize_C(arg)` (e.g. `UINT16_C(123)`) which are used
 * to create an integer constant of type `Xint_leastSIZE_t` (e.g.
 * `uint_least16_t).
 */
class IntegerConstantMacro extends Macro {
  boolean signed;
  int size;

  IntegerConstantMacro() {
    signed = true and size = getName().regexpCapture("INT(8|16|32|64)_C", 1).toInt()
    or
    signed = false and size = getName().regexpCapture("UINT(8|16|32|64)_C", 1).toInt()
  }

  predicate isSmall() { size < any(IntType it | it.isSigned()).getSize() * 8 }

  int getSize() { result = size }

  predicate isSigned() { signed = true }

  float maxValue() {
    signed = true and result = 2.pow(size - 1 * 1.0) - 1
    or
    signed = false and result = 2.pow(size) - 1
  }

  float minValue() {
    signed = true and result = -2.pow(size - 1)
    or
    signed = false and result = 0
  }

  string getRangeString() { result = minValue().toString() + ".." + maxValue().toString() }
}
