/**
 * @id c/cert/do-not-copy-a-file-object
 * @name FIO38-C: Do not copy a FILE object
 * @description Using a copy of a FILE object may result in program failure.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/fio38-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/**
 * An object being copied as part of an Initialization, Assignment or Function Call
 */
class CopiedObject extends Expr {
  CopiedObject() {
    this = any(Initializer i).getExpr() or
    this = any(Assignment a).getRValue() or
    this = any(FunctionCall fc).getAnArgument()
  }
}

from CopiedObject o
where
  not isExcluded(o, IO2Package::doNotCopyAFileObjectQuery()) and
  o.getType().hasName("FILE")
select o, "A FILE object is being copied."
