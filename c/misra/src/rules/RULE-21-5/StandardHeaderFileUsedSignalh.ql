/**
 * @id c/misra/standard-header-file-used-signalh
 * @name RULE-21-5: The standard header file shall not be used 'signal.h'
 * @description The use of features of 'signal.h' may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-5
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from Function f, FunctionCall fc
where
  not isExcluded(fc, BannedPackage::standardHeaderFileUsedSignalhQuery()) and
  fc.getTarget() = f and
  f.getFile().getBaseName() = "signal.h"
select fc, "Call to banned function " + f.getName() + "."
