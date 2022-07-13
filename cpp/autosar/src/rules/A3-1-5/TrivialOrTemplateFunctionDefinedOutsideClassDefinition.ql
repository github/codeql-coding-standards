/**
 * @id cpp/autosar/trivial-or-template-function-defined-outside-class-definition
 * @name A3-1-5: A function shall be defined with a class body if and only if it is intended to be inlined
 * @description A function that is either trivial, a template function, or a member of a template
 *              class may not be defined outside of a class body.
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

/*
 * Find instances of `MemberFunction` where the `MemberFunction` is trivial
 * and it is not inlined within the class.
 */

from MemberFunction mf, string kind
where
  not isExcluded(mf, ClassesPackage::trivialOrTemplateFunctionDefinedOutsideClassDefinitionQuery()) and
  // The member function `mf` is not defined in the class body.
  exists(FunctionDeclarationEntry fde |
    fde = mf.getClassBodyDeclarationEntry() and not fde.isDefinition()
  ) and
  //ignore destructors
  not mf instanceof Destructor and
  // Report functions that are NOT defined in the class body if they are either trivial or
  // either a template member or part of a template class (i.e., they should
  // be defined in the class body)
  (
    if
      mf instanceof TemplateOrTemplateClassMemberFunction and
      mf instanceof TrivialMemberFunction
    then kind = "template"
    else
      if mf instanceof TrivialMemberFunction
      then kind = "trivial"
      else
        if mf instanceof TemplateOrTemplateClassMemberFunction
        then kind = "template"
        else none()
  )
select mf,
  "The " + kind + " member function " + mf.getName() + " is not defined in the class body of $@.",
  mf.getDeclaringType(), mf.getDeclaringType().getName()
