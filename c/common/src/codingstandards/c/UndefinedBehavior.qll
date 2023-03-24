import cpp
import codingstandards.cpp.UndefinedBehavior

/**
 * Library for modeling undefined behavior.
 */
abstract class CUndefinedBehavior extends UndefinedBehavior { }

class C99MainFunction extends Function {
  C99MainFunction() {
    this.getNumberOfParameters() = 2 and
    this.getType() instanceof IntType and
    this.getParameter(0).getType() instanceof IntType and
    this.getParameter(1).getType().(PointerType).getBaseType().(PointerType).getBaseType()
      instanceof CharType
    or
    this.getNumberOfParameters() = 0 and
    this.getType() instanceof VoidType
  }
}

class CUndefinedMainDefinition extends CUndefinedBehavior, Function {
  CUndefinedMainDefinition() {
    // for testing purposes, we use the prefix ____codeql_coding_standards`
    (this.getName() = "main" or this.getName().indexOf("____codeql_coding_standards") = 0) and
    not this instanceof C99MainFunction
  }
}
