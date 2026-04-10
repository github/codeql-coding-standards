/**
 * @id cpp/misra/compiler-language-extensions-used
 * @name RULE-4-1-1: A program shall conform to ISO/IEC 14882:2017 (C++17)
 * @description Language extensions are compiler-specific features that are not part of the C++17
 *              standard. Using these extensions reduces portability and may lead to unpredictable
 *              behavior when code is compiled with different compilers or compiler versions.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-1
 *       scope/system
 *       maintainability
 *       portability
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Extensions
import codingstandards.cpp.AlertReporting

from CPPCompilerExtension e
where not isExcluded(e, Toolchain2Package::compilerLanguageExtensionsUsedQuery())
select MacroUnwrapper<CPPCompilerExtension>::unwrapElement(e), e.getMessage()
