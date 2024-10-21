/**
 * @id c/misra/macro-identifiers-not-distinct
 * @name RULE-5-4: Macro identifiers shall be distinct
 * @description Declaring multiple macros with the same name leads to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-5-4
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Macro
import codingstandards.cpp.Includes
import codingstandards.cpp.PreprocessorDirective

/**
 * Gets a top level element that this macro is expanded to, e.g. an element which does not also have
 * an enclosing element in the macro.
 */
Element getATopLevelElement(MacroInvocation mi) {
  result = mi.getAnExpandedElement() and
  not result.getEnclosingElement() = mi.getAnExpandedElement() and
  not result instanceof Conversion
}

/**
 * Gets a link target that this macro is expanded in.
 */
LinkTarget getALinkTarget(Macro m) {
  exists(MacroInvocation mi, Element e |
    mi = m.getAnInvocation() and
    e = getATopLevelElement(mi)
  |
    result = e.(Expr).getEnclosingFunction().getALinkTarget()
    or
    result = e.(Stmt).getEnclosingFunction().getALinkTarget()
    or
    exists(GlobalOrNamespaceVariable g |
      result = g.getALinkTarget() and
      g = e.(Expr).getEnclosingDeclaration()
    )
  )
}

/**
 * Holds if the m1 and m2 are unconditionally included from a common file.
 *
 * Extracted out for performance reasons - otherwise the call to determine the file path for the
 * message was specializing the calls to `getAnUnconditionallyIncludedFile*(..)` and causing
 * slow performance.
 */
bindingset[m1, m2]
pragma[inline_late]
private predicate isIncludedUnconditionallyFromCommonFile(Macro m1, Macro m2) {
  exists(File f |
    getAnUnconditionallyIncludedFile*(f) = m1.getFile() and
    getAnUnconditionallyIncludedFile*(f) = m2.getFile()
  )
}

from Macro m, Macro m2, string message
where
  not isExcluded(m, Declarations1Package::macroIdentifiersNotDistinctQuery()) and
  not m = m2 and
  (
    //C99 states the first 63 characters of macro identifiers are significant
    //C90 states the first 31 characters of macro identifiers are significant and is not currently considered by this rule
    //ie an identifier differing on the 32nd character would be indistinct for C90 but distinct for C99
    //and is currently not reported by this rule
    if m.getName().length() >= 64 and not m.getName() = m2.getName()
    then (
      m.getName().prefix(63) = m2.getName().prefix(63) and
      message =
        "Macro identifer " + m.getName() + " is nondistinct in first 63 characters, compared to $@."
    ) else (
      m.getName() = m2.getName() and
      message =
        "Definition of macro " + m.getName() +
          " is not distinct from alternative definition of $@ in " +
          m2.getLocation().getFile().getRelativePath() + "."
    )
  ) and
  //reduce double report since both macros are in alert, arbitrary ordering
  m.getLocation().getStartLine() >= m2.getLocation().getStartLine() and
  // Not within an #ifndef MACRO_NAME
  not exists(PreprocessorIfndef ifBranch |
    m.getAGuard() = ifBranch or
    m2.getAGuard() = ifBranch
  |
    ifBranch.getHead() = m.getName()
  ) and
  // Must be included unconditionally from the same file, otherwise m1 may not be defined
  // when m2 is defined
  isIncludedUnconditionallyFromCommonFile(m, m2) and
  // Macros can't be mutually exclusive
  not mutuallyExclusiveMacros(m, m2) and
  not mutuallyExclusiveMacros(m2, m) and
  // If at least one invocation exists for at least one of the macros, then they must share a link
  // target - i.e. must both be expanded in the same context
  (
    (exists(m.getAnInvocation()) and exists(m2.getAnInvocation()))
    implies
    // Must share a link target - e.g. must both be expanded in the same context
    getALinkTarget(m) = getALinkTarget(m2)
  )
select m, message, m2, m2.getName()
