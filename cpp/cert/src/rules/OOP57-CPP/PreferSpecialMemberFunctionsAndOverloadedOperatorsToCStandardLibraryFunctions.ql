/**
 * @id cpp/cert/prefer-special-member-functions-and-overloaded-operators-to-c-standard-library-functions
 * @name OOP57-CPP: Prefer special member functions and overloaded operators to C Standard Library functions
 * @description Prefer member functions and overloaded operators to C-Standard Library functions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/oop57-cpp
 *       correctness
 *       scope/single-translation-unit
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

predicate isStandardMemFunction(FunctionCall fc) {
  fc.getTarget()
      .hasGlobalOrStdName([
          "memset", "memcpy", "memmove", "memcmp", "strcpy", "strncpy", "stpncpy", "strcmp",
          "strncmp"
        ])
}

from FunctionCall fc, Class c
where
  not isExcluded(fc,
    BannedFunctionsPackage::preferSpecialMemberFunctionsAndOverloadedOperatorsToCStandardLibraryFunctionsQuery()) and
  isStandardMemFunction(fc) and
  c = fc.getArgument(0).getType().stripType() and
  not c.isStandardLayout()
select fc,
  "Non-standard layout class " + c.stripType().getName() + " is used as argument to " +
    fc.getTarget().getName() + "."
