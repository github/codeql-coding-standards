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
import codingstandards.cpp.Macro

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

/*
 * In theory this query should exclude casts using the "functional notation" syntax, e.g.
 * ```
 * int(x);
 * ```
 * This is because this is not a C-style cast, as it is not legitimate C code. However, our database
 * schema does not distinguish between C-style casts and functional casts, so we cannot exclude just
 * those.
 *
 * In addition, we do not get `CStyleCasts` in cases where the cast is converted to a `ConstructorCall`.
 * This holds for both the "functional notation" syntax and the "c-style" syntax, e.g. both of these
 * are represented in our model as `ConstructorCall`s only:
 * ```
 * class A { public: A(int); };
 * void create() {
 *   (A)1;
 *   A(1);
 * }
 * ```
 *
 * As a consequence this query:
 *  - Produces false positives when primitive types are cast using the "functional notation" syntax.
 *  - Produces false negatives when a C-style cast is converted to a `ConstructorCall` e.g. when the
 *    argument type is compatible with a single-argument constructor.
 */

from CStyleCast c, string extraMessage, Locatable l, string supplementary
where
  not isExcluded(c, BannedSyntaxPackage::traditionalCStyleCastsUsedQuery()) and
  not c.isImplicit() and
  not c.getType() instanceof UnknownType and
  // For casts in templates that occur on types related to a template parameter, the copy of th
  // cast in the uninstantiated template is represented as a `CStyleCast` even if in practice all
  // the instantiations represent it as a `ConstructorCall`. To avoid the common false positive case
  // of using the functional cast notation to call a constructor we exclude all `CStyleCast`s on
  // uninstantiated templates, and instead rely on reporting results within instantiations.
  not c.isFromUninstantiatedTemplate(_) and
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
