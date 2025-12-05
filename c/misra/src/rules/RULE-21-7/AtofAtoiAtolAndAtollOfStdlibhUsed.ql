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
 *       external/misra/c/2012/third-edition-first-revision
 *       coding-standards/baseline/safety
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.atofatoiatolandatollused.AtofAtoiAtolAndAtollUsed

class AtofAtoiAtolAndAtollOfStdlibhUsedQuery extends AtofAtoiAtolAndAtollUsedSharedQuery {
  AtofAtoiAtolAndAtollOfStdlibhUsedQuery() {
    this = BannedPackage::atofAtoiAtolAndAtollOfStdlibhUsedQuery()
  }
}
