import cpp
import codingstandards.cpp.EncapsulatingFunctions

class BuiltInIntegerType extends BuiltInType {
  BuiltInIntegerType() {
    this instanceof ShortType
    or
    this instanceof IntType
    or
    this instanceof LongType
    or
    this instanceof LongLongType
  }
}

/**
 * any `Parameter` in a main function like:
 * int main(int argc, char *argv[])
 */
class ExcludedVariable extends Parameter {
  ExcludedVariable() { getFunction() instanceof MainFunction }
}
