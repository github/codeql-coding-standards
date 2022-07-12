/**
 * @id c/cert/distinguish-between-char-read-from-a-file-and-eof-or-weof
 * @name FIO34-C: Distinguish between characters read from a file and EOF or WEOF
 * @description File read should be followed by a check for read errors and end of file.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio34-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.ReadErrorsAndEOF

from InBandErrorReadFunctionCall read
where
  not isExcluded(read, IO1Package::distinguishBetweenCharReadFromAFileAndEofOrWeofQuery()) and
  missingFeofFerrorChecks(read) and
  missingEOFWEOFChecks(read)
select read, "The file read is not checked for errors and end of file."
