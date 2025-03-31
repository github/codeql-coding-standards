/**
 * @id c/cert/fopen-with-non-exclusive-file-creation-mode
 * @name FIO03-C: Do not make assumptions about fopen() and file creation
 * @description Usage of fopen() without the proper exclusion mode can lead to a program overwriting
 *              over accessing an unintended file.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio03-c
 *       correctness
 *       security
 *       external/cert/obligation/recommendation
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.alertreporting.PrintExpr
import codingstandards.cpp.standardlibrary.FileAccess

class PrettyPrintExpr extends Expr {
  PrettyPrintExpr() {
    this instanceof BinaryOperation
    or
    this instanceof Literal
  }
}

string prettyPrint(Expr e) {
  result = PrintExpr<PrettyPrintExpr>::print(e)
}

from FOpenCall fopen
where
  not isExcluded(fopen, IO5Package::fopenWithNonExclusiveFileCreationModeQuery()) and
  fopen.mayCreate() and
  not fopen.isExclusiveMode()
select fopen,
  "Call to create file with non-exclusive creation mode '" + prettyPrint(fopen.getMode()) + "'."
