/**
 * @id cpp/autosar/hash-specializations-have-a-noexcept-function-call-operator
 * @name A18-1-6: All std::hash specializations for user-defined types shall have a noexcept function call operator
 * @description Some standard library containers use std::hash indirectly.  Having a no-except
 *              function call operator prevents container access from throwing an exception.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-1-6
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

from ClassTemplateSpecialization s, FunctionCallOperator o
where
  not isExcluded(s,
    OperatorInvariantsPackage::hashSpecializationsHaveANoexceptFunctionCallOperatorQuery()) and
  s.getPrimaryTemplate().hasQualifiedName("std", "hash") and
  o.getDeclaringType() = s and
  not o.isNoExcept()
select s, "Hash specialization $@ does not implement a no-except function call operator.", s,
  "Hash specialization"
