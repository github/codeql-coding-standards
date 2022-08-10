/**
 * @id c/cert/use-int-argument-for-width-and-precision
 * @name FIO47-C: Use `int` arguments for `width` and `precision`
 * @description Use `int` arguments for `width` and `precision`
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio47-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from FormatLiteral fl, Expr expr, string element
where
  not isExcluded(expr, IO4Package::useIntArgumentForWidthAndPrecisionQuery()) and
  (
    element = "minimum field width" and expr = fl.getUse().getMinFieldWidthArgument(_)
    or
    element = "precision" and expr = fl.getUse().getPrecisionArgument(_)
  ) and
  not expr.getType() instanceof IntType
select expr, "The coversion specification argument for '" + element + "' must be of type `int`."
