/**
 * @id c/cert/exclude-user-input-from-format-strings
 * @name FIO30-C: Exclude user input from format strings
 * @description Never call a formatted I/O function with a format string containing user input.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio30-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.nonconstantformat.NonConstantFormat

class ExcludeUserInputFromFormatStringsQuery extends NonConstantFormatSharedQuery {
  ExcludeUserInputFromFormatStringsQuery() {
    this = IO1Package::excludeUserInputFromFormatStringsQuery()
  }
}
