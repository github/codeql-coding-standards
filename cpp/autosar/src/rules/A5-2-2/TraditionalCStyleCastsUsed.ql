/**
 * @id cpp/autosar/traditional-c-style-casts-used
 * @name A5-2-2: Traditional C-style casts shall not be used
 * @description Traditional C-style casts shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-2-2
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * Gets the macro (if any) that generated the given `CStyleCast`.
 *
 * If there are nested macro invocations, we identify the most specific macro that generated the
 * cast.
 */
Macro getGeneratedFrom(CStyleCast c) {
  exists(MacroInvocation mi |
    mi = result.getAnInvocation() and
    mi.getAGeneratedElement() = c and
    mi.getLocation().getStartColumn() = c.getLocation().getStartColumn() and
    not exists(MacroInvocation child |
      child.getParentInvocation() = mi and
      child.getAGeneratedElement() = c
    )
  )
}

/** A macro within the source location of this project. */
class UserProvidedMacro extends Macro {
  UserProvidedMacro() { exists(this.getFile().getRelativePath()) }
}

/** A macro defined within a library used by this project. */
class LibraryMacro extends Macro {
  LibraryMacro() { not this instanceof UserProvidedMacro }
}

from CStyleCast c, string extraMessage, Locatable l, string supplementary
where
  not isExcluded(c, BannedSyntaxPackage::traditionalCStyleCastsUsedQuery()) and
  not c.isImplicit() and
  not c.getType() instanceof UnknownType and
  // Exclude casts created from macro invocations of macros defined by third parties
  not getGeneratedFrom(c) instanceof LibraryMacro and
  // If the cast was generated from a user-provided macro, then report the macro that generated the
  // cast, as the macro itself may have generated the cast
  if getGeneratedFrom(c) instanceof UserProvidedMacro
  then
    extraMessage = " generated from macro $@" and
    // Add macro as explanatory link
    l = getGeneratedFrom(c) and
    supplementary = getGeneratedFrom(c).getName()
  else (
    // No extra message required
    extraMessage = "" and
    // No explanatory link required, but we still need to set these to valid values
    l = c and
    supplementary = ""
  )
select c, "Use of explicit c-style cast to " + c.getType().getName() + extraMessage + ".", l,
  supplementary
