/**
 * @id cpp/autosar/avoid-auto-with-braced-initialization
 * @name A8-5-3: A variable of type auto shall not be initialized using {} or ={} braced-initialization
 * @description If auto is used with braced initialization then the deduced type will always be
 *              std::initializer_list, which may be contrary to developer expectations.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/autosar/id/a8-5-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Variable v
where
  not isExcluded(v, InitializationPackage::avoidAutoWithBracedInitializationQuery()) and
  v.getTypeWithAuto().getUnspecifiedType() instanceof AutoType and
  v.getInitializer().isBraced()
select v, "Variable " + v.getName() + " of type auto uses braced initialization."
