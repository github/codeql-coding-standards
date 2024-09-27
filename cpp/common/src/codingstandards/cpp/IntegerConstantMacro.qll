import cpp

class IntegerConstantMacro extends Macro {
  boolean signed;
  int size;
  IntegerConstantMacro() {
    (
    signed = true and size = getName().regexpCapture("INT(8|16|32|64)_C", 1).toInt()
    ) or (
    signed = false and size = getName().regexpCapture("UINT(8|16|32|64)_C", 1).toInt()
    )
  }

  predicate isSmall() {
    size < 32
  }

  int getSize() {
    result = size
  }

  predicate isSigned() {
    signed = true
  }

  int maxValue() {
    (signed = true and result = 2.pow(getSize() - 1) - 1) or
    (signed = false and result = 2.pow(getSize()) - 1)
  }

  int minValue() {
    (signed = true and result = -(2.0.pow(getSize() - 1))) or
    (signed = false and result = 0)
  }
}