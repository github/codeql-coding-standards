/**
 * @id cpp/autosar/c-standard-library-headers-are-deprecated
 * @name A1-1-1: C Standard Library headers are deprecated
 * @description C Standard Library headers are deprecated.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a1-1-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Include i, string filename
where
  not isExcluded(i, ToolchainPackage::cStandardLibraryHeadersAreDeprecatedQuery()) and
  not exists(i.getIncludedFile().getRelativePath()) and
  i.getIncludedFile().getBaseName() = filename and
  filename in [
      "assert.h", "complex.h", "ctype.h", "errno.h", "fenv.h", "float.h", "inttypes.h", "iso646.h",
      "limits.h", "locale.h", "math.h", "setjmp.h", "signal.h", "stdalign.h", "stdarg.h",
      "stdbool.h", "stddef.h", "stdint.h", "stdio.h", "stdlib.h", "string.h", "tgmath.h", "time.h",
      "uchar.h", "wchar.h", "wctype.h"
    ]
select i, "Use of C Standard Library header '" + filename + "' is deprecated."
