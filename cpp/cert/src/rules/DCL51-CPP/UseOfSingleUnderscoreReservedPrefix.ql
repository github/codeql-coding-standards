/**
 * @id cpp/cert/use-of-single-underscore-reserved-prefix
 * @name DCL51-CPP: Name uses reserved prefix
 * @description Each name prefixed with a double underscore, an underscore followed by an uppercase
 *              letter, or a single underscore and is defined in the global namespace is reserved.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/dcl51-cpp
 *       maintainability
 *       readability
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Naming

bindingset[s]
predicate prefixedWithSingleUnderscoreAndUppercase(string s) { s.regexpMatch("_[A-Z].*") }

bindingset[s]
predicate prefixedWithSingleUnderscore(string s) { s.regexpMatch("_[^_].*") }

predicate isReservedMacroPrefix(Macro m) { prefixedWithSingleUnderscoreAndUppercase(m.getName()) }

predicate isReservedPrefix(Declaration d) {
  d.hasGlobalName(_) and prefixedWithSingleUnderscore(d.getName())
  or
  prefixedWithSingleUnderscoreAndUppercase(d.getName())
}

predicate isGeneratedByUserMacro(Declaration d) {
  exists(MacroInvocation mi |
    mi.getAGeneratedElement() = d and
    not Naming::Cpp14::hasStandardLibraryMacroName(mi.getMacroName())
  )
}

from Locatable l, string s
where
  not isExcluded(l, NamingPackage::useOfDoubleUnderscoreReservedPrefixQuery()) and
  (
    exists(Macro m | l = m and isReservedMacroPrefix(m) and s = m.getName())
    or
    exists(Declaration d |
      l = d and
      isReservedPrefix(d) and
      s = d.getName() and
      (
        not d.isInMacroExpansion()
        or
        isGeneratedByUserMacro(d)
      )
    )
  ) and
  // Ignore compiler generated functions and variables
  not l.(Function).isCompilerGenerated() and
  not l.(Variable).isCompilerGenerated()
select l, "Name $@ uses the reserved prefix '_'.", l, s
