/**
 * @id c/cert/race-conditions-when-using-library-functions
 * @name CON33-C: Avoid race conditions when using library functions
 * @description Certain functions may cause race conditions when used from a threaded context.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con33-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Concurrency

from ThreadedCFN node
where
  not isExcluded(node, Concurrency1Package::raceConditionsWhenUsingLibraryFunctionsQuery()) and
  node.(FunctionCall).getTarget().getName() =
    [
      "rand", "srand", "getenv", "strtok", "strerror", "asctime", "ctime", "localtime", "gmtime",
      "setlocale", "atomic_init", "ATOMIC_VAR_INIT", "tmpnam", "mbrtoc16", "c16rtomb", "mbrtoc32",
      "c32rtomb"
    ]
select node,
  "Concurrent call to non-reeantrant function $@.", node.(FunctionCall).getTarget(), node.(FunctionCall).getTarget().getName()
