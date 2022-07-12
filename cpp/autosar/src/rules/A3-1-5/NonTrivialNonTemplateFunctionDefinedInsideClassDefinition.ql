/**
 * @id cpp/autosar/non-trivial-non-template-function-defined-inside-class-definition
 * @name A3-1-5: A function shall be defined with a class body if and only if it is intended to be inlined
 * @description A function that is not either trivial, a template function, or a member of a
 *              template class may not be defined within a class body.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a3-1-5
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class
import codingstandards.cpp.EncapsulatingFunctions

/*
 * Find instances of `MemberFunction` where the `MemberFunction` is not trivial
 * yet it is inlined.
 */

from MemberFunction mf
where
  not isExcluded(mf,
    ClassesPackage::nonTrivialNonTemplateFunctionDefinedInsideClassDefinitionQuery()) and
  // The member function has a definition in the class body.
  exists(FunctionDeclarationEntry fde |
    fde = mf.getClassBodyDeclarationEntry() and
    fde.isDefinition()
  ) and
  // Exclude compiler generated member functions.
  not mf.isCompilerGenerated() and
  // Exclude deleted member functions.
  not mf.isDeleted() and
  // Report functions that are inline if they are not either trivial or
  // either a template member or part of a template class
  not (
    mf instanceof TrivialMemberFunction
    or
    mf instanceof TemplateOrTemplateClassMemberFunction
  )
select mf,
  "Non-Trivial or non-template function " + mf.getName() + " is defined in the class body of $@.",
  mf.getDeclaringType(), mf.getDeclaringType().getName()
