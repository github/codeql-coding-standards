/**
 * @id cpp/autosar/non-member-generic-operator-condition
 * @name A14-5-3: A non-member generic operator shall only be declared in a namespace that does not contain class
 * @description A non-member generic operator shall only be declared in a namespace that does not
 *              contain class (struct) type, enum type or union type declarations.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a14-5-3
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

class NonMemberGenericOperator extends TemplateFunction {
  NonMemberGenericOperator() {
    this instanceof Operator and
    exists(TemplateParameter tp, Type pType |
      pType = getAParameter().getType().getUnspecifiedType() //Parameter Type
    |
      pType = tp or
      tp = pType.(ReferenceType).getBaseType() or //T&
      tp = pType.(RValueReferenceType).getBaseType() //T&&
    ) and
    not this.isMember()
  }
}

from NonMemberGenericOperator op, Namespace ns
where
  not isExcluded(op, OperatorsPackage::nonMemberGenericOperatorConditionQuery()) and
  op.getNamespace() = ns and
  exists(UserType ut | ut.getNamespace() = ns)
select op,
  "A non-member generic operator shall only be declared in a namespace that does not contain class (struct) type, enum type or union type declarations."
