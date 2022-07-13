/**
 * @id cpp/autosar/copy-assignment-operator-not-declared
 * @name M14-5-3: A copy assignment operator shall be declared when there is a template assignment operator with a parameter that is generic
 * @description A copy assignment operator shall be declared when there is a template assignment
 *              operator with a parameter that is a generic parameter otherwise assignment involving
 *              types with pointer members may not behave as a developer expects.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m14-5-3
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

/**
 * CopyOperator look alike
 * aka allowed to be template
 * therefore does not check return type and whether that is same as class
 */
class TemplateAssignmentOperatorMember extends MemberFunction {
  TemplateAssignmentOperatorMember() {
    this instanceof TemplateFunction and
    this instanceof Operator and
    this.getName() = "operator=" and
    this.hasDefinition() and
    this.getNumberOfParameters() = 1
  }

  /**
   * is a copy assigment operator candidate if it has only one param and form in [T, T&, const T&, volatile T&, const volatile T&]
   */
  predicate hasGenericCopyCompatibleParameter() {
    exists(TemplateParameter tp, Type pType |
      pType = this.getAParameter().getType().getUnspecifiedType() and //Parameter Type
      (
        tp = pType //T
        or
        tp = pType.(LValueReferenceType).getBaseType() //T&
      )
    )
  }
}

from Class c, TemplateAssignmentOperatorMember template
where
  not isExcluded(c, TemplatesPackage::copyAssignmentOperatorNotDeclaredQuery()) and
  template.getDeclaringType() = c and
  template.hasGenericCopyCompatibleParameter() and
  not exists(UserCopyOperator explicit |
    not template = explicit and
    explicit.getDeclaringType() = c and
    not explicit.isDeleted()
  )
select c, "Class does not explicitly define a copy assignment operator."
