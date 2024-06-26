/**
 * @id c/misra/atof-atoi-atol-and-atoll-of-stdlibh-used
 * @name RULE-21-7: The Standard Library functions 'atof', 'atoi', 'atol' and 'atoll' of 'stdlib.h' shall not be used
 * @description The use of Standard Library functions 'atof', 'atoi', 'atol' and 'atoll' of
 *              'stdlib.h' may result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-7
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.atofatoiatolandatollused_shared.AtofAtoiAtolAndAtollUsed_shared

class AtofAtoiAtolAndAtollOfStdlibhUsedQuery extends AtofAtoiAtolAndAtollUsed_sharedSharedQuery {
  AtofAtoiAtolAndAtollOfStdlibhUsedQuery() {
    this = BannedPackage::atofAtoiAtolAndAtollOfStdlibhUsedQuery()
  }
}
