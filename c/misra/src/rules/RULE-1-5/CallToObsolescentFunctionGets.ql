/**
 * @id c/misra/call-to-obsolescent-function-gets
 * @name RULE-1-5: Disallowed usage of obsolescent function 'gets'
 * @description The function 'gets' is an obsolescent language feature which was removed in C11.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-1-5
 *       external/misra/c/2012/amendment3
 *       security
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from FunctionCall fc
where
  not isExcluded(fc, Language4Package::callToObsolescentFunctionGetsQuery()) and
  fc.getTarget().hasGlobalOrStdName("gets")
select fc, "Call to obsolescent function 'gets'."
