/**
 * @id c/misra/occurrence-of-undefined-behavior
 * @name RULE-1-3: There shall be no occurrence of undefined or critical unspecified behavior
 * @description Relying on undefined or unspecified behavior can result in unreliable programs.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-1-3
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/cwe/cwe-119
 *       external/cwe/cwe-120
 *       external/cwe/cwe-121
 *       external/cwe/cwe-122
 *       external/cwe/cwe-123
 *       external/cwe/cwe-124
 *       external/cwe/cwe-125
 *       external/cwe/cwe-126
 *       external/cwe/cwe-127
 *       external/cwe/cwe-129
 *       external/cwe/cwe-131
 *       external/cwe/cwe-244
 *       external/cwe/cwe-401
 *       external/cwe/cwe-415
 *       external/cwe/cwe-416
 *       external/cwe/cwe-680
 *       external/cwe/cwe-789
 *       external/cwe/cwe-825
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.UndefinedBehavior

from CUndefinedBehavior c
where not isExcluded(c, Language3Package::occurrenceOfUndefinedBehaviorQuery())
select c, c.getReason()
