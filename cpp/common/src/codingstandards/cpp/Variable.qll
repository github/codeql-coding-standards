import cpp
import semmle.code.cpp.PODType03

/** A variable of type scalar. */
class ScalarVariable extends Variable {
  ScalarVariable() { isScalarType03(this.getType()) }
}
