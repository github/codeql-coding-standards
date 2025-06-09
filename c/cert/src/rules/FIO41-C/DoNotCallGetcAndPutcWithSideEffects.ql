/**
 * @id c/cert/do-not-call-getc-and-putc-with-side-effects
 * @name FIO41-C: Do not call getc(), putc(), getwc(), or putwc() with a stream argument that has side effects
 * @description Using an expression that has side effects as the stream argument to `getc()` or
 *              `putc()` can result in unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/fio41-c
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.standardlibrary.FileAccess

from FileAccess fa
where
  not isExcluded(fa.getFileExpr(), IO2Package::doNotCallGetcAndPutcWithSideEffectsQuery()) and
  fa.getTarget().hasGlobalName(["getc", "putc", "getwc", "putwc"]) and
  not fa.getFileExpr().isPure()
select fa.getFileExpr(),
  "The stream argument has side effects and might be evaluated more then once."
