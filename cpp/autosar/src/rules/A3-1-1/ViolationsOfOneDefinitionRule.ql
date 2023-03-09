/**
 * @id cpp/autosar/violations-of-one-definition-rule
 * @name A3-1-1: It shall be possible to include any header file in multiple translation units without violating the One Definition Rule
 * @description Defining externally linked objects or functions in header files can result in
 *              violations of the One Definition Rule (i.e., linkage failure or undefined behaviour
 *              can result).
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-1-1
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.AcceptableHeader

predicate isInline(Function decl) {
  exists(Specifier spec |
    spec = decl.getASpecifier() and
    (
      spec.hasName("inline") or
      spec.hasName("constexpr")
    )
  )
}

predicate isExtern(FunctionDeclarationEntry decl) {
  exists(string spec |
    spec = decl.getASpecifier() and
    spec = "extern"
  )
}

from DeclarationEntry decl, string case, string name
where
  (
    //a non-inline/non-extern function defined in a header
    exists(FunctionDeclarationEntry fn |
      fn.isDefinition() and
      not (
        isInline(fn.getDeclaration())
        or
        isExtern(fn)
        or
        //any (defined) templates do not violate the ODR
        fn.isFromUninstantiatedTemplate(_)
        or
        fn.isFromTemplateInstantiation(_) and
        //except for specializations, those do violate ODR
        not fn.isSpecialization()
        or
        fn.getDeclaration().isStatic()
      ) and
      decl = fn and
      case = "function"
    )
    or
    //an non-const object defined in a header
    exists(GlobalOrNamespaceVariable object |
      object.hasDefinition() and
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
  decl.getFile() instanceof AcceptableHeader and
  not isExcluded(decl, IncludesPackage::violationsOfOneDefinitionRuleQuery()) and
  name = decl.getName()
select decl,
  "Header file $@ contains " + case + " " + name + " that lead to One Defintion Rule violation.",
  decl.getFile(), decl.getFile().getBaseName()
