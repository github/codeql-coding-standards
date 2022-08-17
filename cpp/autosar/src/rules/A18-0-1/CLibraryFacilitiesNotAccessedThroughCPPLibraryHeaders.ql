/**
 * @id cpp/autosar/c-library-facilities-not-accessed-through-cpp-library-headers
 * @name A18-0-1: The C library facilities shall only be accessed through C++ library headers
 * @description C libraries (e.g. <stdio.h>) also have corresponding C++ libraries (e.g. <cstdio>).
 *              This rule requires that the C++ version is used.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a18-0-1
 *       correctness
 *       readability
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Include i, string filename
where
  not isExcluded(i,
    BannedLibrariesPackage::cLibraryFacilitiesNotAccessedThroughCPPLibraryHeadersQuery()) and
  /*
   *    NOTE: This query uses the presence ('#include') of discouraged header files as "evidence" that C libraries
   *    are used. It is a weak form of evidence, as it is possible for source code to '#include <signal.h>' and
   *    not use any of 'signal.h's facilities, for example.
   */

  filename = i.getIncludedFile().getBaseName() and
  filename in [
      "assert.h", "ctype.h", "errno.h", "fenv.h", "float.h", "inttypes.h", "limits.h", "locale.h",
      "math.h", "setjmp.h", "signal.h", "stdarg.h", "stddef.h", "stdint.h", "stdio.h", "stdlib.h",
      "string.h", "time.h", "uchar.h", "wchar.h", "wctype.h"
    ]
select i,
  "C library \"" + filename + "\" is included instead of the corresponding C++ library <c" +
    filename.prefix(filename.length() - 2) + ">."
