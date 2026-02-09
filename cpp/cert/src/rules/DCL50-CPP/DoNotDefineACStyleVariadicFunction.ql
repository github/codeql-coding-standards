/**
 * @id cpp/cert/do-not-define-ac-style-variadic-function
 * @name DCL50-CPP: Do not define a C-style variadic function
 * @description Do not define a C-style variadic function.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl50-cpp
 *       correctness
 *       security
 *       scope/single-translation-unit
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p12
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

from Function f
where
  not isExcluded(f, BannedSyntaxPackage::doNotDefineACStyleVariadicFunctionQuery()) and
  f.isVarargs() and
  not f.getADeclarationEntry().hasCLinkage()
select f, "Function " + f.getName() + " declared as c-style variadic function."
