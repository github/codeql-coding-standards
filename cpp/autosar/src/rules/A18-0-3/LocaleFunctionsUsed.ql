/**
 * @id cpp/autosar/locale-functions-used
 * @name A18-0-3: The library <clocale> (locale.h) functions shall not be used
 * @description A call to the setlocale function introduces a data race with other calls to
 *              setlocale function. It may also introduce a data race with calls to functions that
 *              are affected by the current locale settings: fprintf, isprint, iswdigit, localeconv,
 *              tolower, fscanf, ispunct, iswgraph, mblen, toupper, isalnum, isspace, iswlower,
 *              mbstowcs, towlower, isalpha, isupper, iswprint, mbtowc, towupper, isblank, iswalnum,
 *              iswpunct, setlocale, wcscoll, iscntrl, iswalpha, iswspace, strcoll, wcstod, isdigit,
 *              iswblank, iswupper, strerror, wcstombs, isgraph, iswcntrl, iswxdigit, strtod,
 *              wcsxfrm, islower, iswctype, isxdigit, strxfrm, wctomb.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a18-0-3
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from FunctionCall fc, Function f
where
  not isExcluded(fc, BannedLibrariesPackage::localeFunctionsUsedQuery()) and
  f = fc.getTarget() and
  f.hasGlobalOrStdName(["setlocale", "localeconv"])
select fc, "Use of <clocale> function '" + f.getQualifiedName() + "'."
