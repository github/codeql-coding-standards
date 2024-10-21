import cpp
import codingstandards.cpp.UndefinedBehavior

/**
 * Library for modeling undefined behavior.
 */
abstract class CUndefinedBehavior extends UndefinedBehavior { }

class PointerOrArrayType extends DerivedType {
  PointerOrArrayType() {
    this instanceof PointerType or
    this instanceof ArrayType
  }
}

Type get(Function main) {
  main.getName() = "main" and
  main.getNumberOfParameters() = 2 and
  main.getType().getUnderlyingType() instanceof IntType and
  main.getParameter(0).getType().getUnderlyingType() instanceof IntType and
  result = main.getParameter(1).getType().getUnderlyingType().(PointerOrArrayType).getBaseType()
}

/**
 * A function which has the signature - but not the name - of a main function.
 */
class C99MainFunction extends Function {
  C99MainFunction() {
    this.getNumberOfParameters() = 2 and
    this.getType().getUnderlyingType() instanceof IntType and
    this.getParameter(0).getType().getUnderlyingType() instanceof IntType and
    this.getParameter(1)
        .getType()
        .getUnderlyingType()
        .(PointerOrArrayType)
        .getBaseType()
        .(PointerOrArrayType)
        .getBaseType() instanceof CharType
    or
    this.getNumberOfParameters() = 0 and
    // Must be explicitly declared as `int main(void)`.
    this.getADeclarationEntry().hasVoidParamList() and
    this.getType().getUnderlyingType() instanceof IntType
  }
}

class CUndefinedMainDefinition extends CUndefinedBehavior, Function {
  CUndefinedMainDefinition() {
    // for testing purposes, we use the prefix ____codeql_coding_standards`
    (this.getName() = "main" or this.getName().indexOf("____codeql_coding_standards_main") = 0) and
    not this instanceof C99MainFunction
  }

  override string getReason() {
    result =
      "main function may trigger undefined behavior because it is not in one of the formats specified by the C standard."
  }
}
