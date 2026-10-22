/**
 * @id cpp/misra/type-aliases-declaration
 * @name RULE-6-9-1: The same type aliases shall be used in all declarations of the same entity
 * @description Using different type aliases on redeclarations can make code hard to understand and
 *              maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-6-9-1
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

/**
 * Holds if `decl1` and `decl2` refer to the same source location (same file,
 * line and column).
 */
predicate sameSourceLocation(DeclarationEntry decl1, DeclarationEntry decl2) {
  decl1.getLocation().getFile() = decl2.getLocation().getFile() and
  decl1.getLocation().getStartLine() = decl2.getLocation().getStartLine() and
  decl1.getLocation().getStartColumn() = decl2.getLocation().getStartColumn()
}

/**
 * Gets a line, in the file of declaration entry `decl`, that is part of the
 * source range in which the type used for the declared entity appears.
 *
 * This is the range spanned by the declaration entry itself, extended - for a
 * function definition - up to the start of the function body. The extension is
 * required because a function definition may use a trailing return type
 * (`auto f() -> T`), which appears after the function name and hence outside the
 * declaration entry's own (name-based) location.
 */
predicate declTypeUseLine(DeclarationEntry decl, File file, int line) {
  file = decl.getLocation().getFile() and
  (
    line in [decl.getLocation().getStartLine() .. decl.getLocation().getEndLine()]
    or
    exists(FunctionDeclarationEntry fde |
      fde = decl and
      fde.getBlock().getLocation().getFile() = file and
      line in [fde.getLocation().getStartLine() .. fde.getBlock().getLocation().getStartLine()]
    )
  )
}

/**
 * Holds if the type alias `t` is mentioned within the source lines spanned by
 * the declaration entry `decl`.
 *
 * `TypedefType.getATypeNameUse()` is documented to return a conservative
 * (incomplete) set of type name uses - in particular it omits uses on
 * prototypes and around template instantiations. As a result it frequently
 * fails to associate an alias with a redeclaration that genuinely uses it
 * (e.g. a function prototype in a header whose definition lives in a `.cpp`),
 * which produces false positives for this rule. `TypeMention` records every
 * syntactic mention of a type together with its location, so we use it to
 * confirm whether `decl` really does use the alias `t`.
 */
predicate typeAliasMentionedIn(TypedefType t, DeclarationEntry decl) {
  exists(TypeMention tm |
    // Match on the qualified name rather than object identity: a mention of a
    // type alias template (e.g. `Result`) resolves to the generic alias, while
    // `getATypeNameUse()` reports the instantiated alias (e.g. `Result<X>`).
    // These are distinct `TypedefType`s but the same alias spelling, which is
    // what this rule is concerned with.
    tm.getMentionedType().(TypedefType).getQualifiedName() = t.getQualifiedName() and
    tm.getLocation().getFile() = decl.getLocation().getFile() and
    declTypeUseLine(decl, tm.getLocation().getFile(), tm.getLocation().getStartLine())
  )
}

from DeclarationEntry decl1, DeclarationEntry decl2, TypedefType t
where
  not isExcluded(decl1, Declarations5Package::typeAliasesDeclarationQuery()) and
  not isExcluded(decl2, Declarations5Package::typeAliasesDeclarationQuery()) and
  not decl1 = decl2 and
  decl1.getDeclaration() = decl2.getDeclaration() and
  // Two declaration entries that share the exact same source location are the
  // same source declaration seen from different translation units, not two
  // redeclarations that could disagree on a type alias. Comparing them produces
  // false positives whenever `getATypeNameUse()` happens to associate the alias
  // with one copy but not the other.
  not sameSourceLocation(decl1, decl2) and
  // Declaration entries synthesised for template instantiations are not source
  // redeclarations and duplicate the entries of the uninstantiated template
  // (without recording their type name uses), so comparing them yields false
  // positives.
  not decl1.getDeclaration().isFromTemplateInstantiation(_) and
  not decl2.getDeclaration().isFromTemplateInstantiation(_) and
  t.getATypeNameUse() = decl1 and
  not t.getATypeNameUse() = decl2 and
  // `getATypeNameUse()` is incomplete, so it may report that `t` is not used on
  // `decl2` even when `decl2` uses exactly the same alias as `decl1`. Confirm via
  // `TypeMention` that `decl2` really does not mention `t` before reporting a
  // divergence, otherwise the same alias used on a prototype/definition pair is
  // wrongly flagged.
  not typeAliasMentionedIn(t, decl2) and
  //exception cases - we dont want to disallow struct typedef name use
  not t.getBaseType() instanceof Struct and
  not t.getBaseType() instanceof Enum
select decl1,
  "Declaration entry has a different type alias than $@ where the type alias used is '$@'.", decl2,
  decl2.getName(), t, t.getName()
