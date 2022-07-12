import cpp
import codingstandards.cpp.exceptions.ExceptionSpecifications

/**
 * A function with an inconsistent noexcept specification across different declarations.
 */
class InconsistentNoExceptFunction extends Function {
  InconsistentNoExceptFunction() {
    not isCompilerGenerated() and
    isFDENoExceptTrue(getADeclarationEntry()) and
    exists(FunctionDeclarationEntry fde |
      fde = getADeclarationEntry() and
      not isFDENoExceptTrue(fde)
    )
  }

  FunctionDeclarationEntry getANoExceptTrueDeclEntry() {
    result = getADeclarationEntry() and
    isFDENoExceptTrue(result)
  }

  FunctionDeclarationEntry getANoExceptFalseDeclEntry() {
    result = getADeclarationEntry() and
    not isFDENoExceptTrue(result)
  }
}
