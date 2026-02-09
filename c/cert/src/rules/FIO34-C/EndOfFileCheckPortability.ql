/**
 * @id c/cert/end-of-file-check-portability
 * @name FIO34-C: Checks against EOF and WEOF are not portable
 * @description Checks against EOF are only portable to platforms where type `char` is less wide
 *              than type `int`.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/fio34-c
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p12
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.ReadErrorsAndEOF

from EqualityOperation eq
where
  not isExcluded(eq, IO1Package::endOfFileCheckPortabilityQuery()) and
  isMacroCheck(eq, _)
select eq,
  "This check is only portable to platforms where type `char` is less wide than type `int`."
