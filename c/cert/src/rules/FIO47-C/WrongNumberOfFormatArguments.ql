/**
 * @id c/cert/wrong-number-of-format-arguments
 * @name FIO47-C: Use correct number of arguments
 * @description Incorrect number of format arguments leads to undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio47-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

/*
 * This is a copy of the `WrongNumberOfFormatArguments.ql` query from the standard set of
 * queries as of the `codeql-cli/2.6.3` tag in `github/codeql`.
 */

import cpp
import codingstandards.c.cert

from FormatLiteral fl, FormattingFunctionCall ffc, int expected, int given
where
  not isExcluded(ffc, IO4Package::wrongNumberOfFormatArgumentsQuery()) and
  ffc = fl.getUse() and
  expected = fl.getNumArgNeeded() and
  given = ffc.getNumFormatArgument() and
  expected > given and
  fl.specsAreKnown()
select ffc, "Format expects " + expected.toString() + " arguments but given " + given.toString()
