/**
 * Provides a library with a `problems` predicate for the following issue:
 * Placing the definitions of functions or objects that are non-inline and have
 * external linkage can lead to violations of the ODR and can lead to undefined
 * behaviour.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.AcceptableHeader
import codingstandards.cpp.Linkage

predicate isInline(Function decl) {
  exists(Specifier spec |
    spec = decl.getASpecifier() and
    (
      spec.hasName("inline") or
      spec.hasName("constexpr")
    )
  )
}

abstract class ViolationsOfOneDefinitionRuleSharedQuery extends Query { }

Query getQuery() { result instanceof ViolationsOfOneDefinitionRuleSharedQuery }

query predicate problems(DeclarationEntry decl, string message, File declFile, string secondmessage) {
  exists(string case |
    not isExcluded(decl, getQuery()) and
    declFile = decl.getFile() and
    secondmessage = decl.getFile().getBaseName() and
    message =
      "Header file $@ contains " + case + " " + decl.getName() +
        " that lead to One Definition Rule violation." and
    hasExternalLinkage(decl.getDeclaration()) and
    (
      //a non-inline/non-extern function defined in a header
      exists(FunctionDeclarationEntry fn |
        fn.isDefinition() and
        not (
          isInline(fn.getDeclaration())
          or
          //any (defined) templates do not violate the ODR
          fn.isFromUninstantiatedTemplate(_)
          or
          fn.isFromTemplateInstantiation(_) and
          //except for specializations, those do violate ODR
          not fn.isSpecialization()
          or
          //static/nonstatic member functions should still not be defined (so do not exclude here)
          fn.getDeclaration().isStatic() and not fn.getFunction() instanceof MemberFunction
        ) and
        decl = fn and
        case = "function"
      )
      or
      //an non-const object defined in a header
      exists(Variable object |
        not (
          object.isConstexpr()
          or
          object.isConst()
          or
          object.isStatic()
        ) and
        decl = object.getDefinition() and
        case = "object"
      )
    ) and
    not decl.getDeclaration().getNamespace().isAnonymous() and
    decl.getFile() instanceof AcceptableHeader
  )
}
