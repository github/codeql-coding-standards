import cpp
import semmle.code.cpp.headers.MultipleInclusion
import TranslationUnit
import PreprocBlock

/**
 * A `Symbol` with additional functionality related to which files
 * provide it, and which files require it.
 */
class SymbolEx extends Symbol {
  /**
   * Holds if file `provider` contains a declaration entry (or similar)
   * for this symbol, with preference `preference`.
   *
   * Symbols can be provided by multiple files, at which point the
   * preference becomes useful: the smaller the value, the more the
   * file should be preferred as the provider of the symbol.
   *
   * Note that we can't provide just the file(s) with the smallest
   * preference, as callers may impose further constraints on which
   * files they want to consider, and these constraints may exclude the
   * file with smallest preference.
   */
  cached
  predicate providedBy(File provider, int preference) {
    provider = this.getFile() and
    if this.(DeclarationEntry).isDefinition() then preference = 1 else preference = 2
  }

  /**
   * Gets a file which depends upon this symbol with weight `weight`.
   *
   * This is a simple aggregation of dependent elements; a file depends
   * upon this symbol if it contains at least one element which depends
   * upon this symbol, and the weight of the dependency is the number of
   * elements in the file which depend upon this symbol.
   */
  cached
  File getADependentFile(int weight) {
    weight =
      strictcount(Element e |
        e = getADependentElement(_) and
        e.getFile() = result
      )
  }
}

/**
 * Holds if `b` is always taken when the containing file is compiled
 * (based on all translation units in the snapshot).
 *
 * As a special case, a multiple inclusion guard, such as
 * ```
 * #ifndef __SOME_H__
 * #define __SOME_H__
 * ... contents of header ...
 * #endif
 * ```
 * is considered to be always taken.
 */
predicate alwaysTaken(PreprocessorBlock b) {
  // b is a file
  mkElement(b) instanceof File
  or
  exists(CorrectIncludeGuard guard |
    // b is a multiple inclusion guard (which is *effectively* always taken)
    guard.getIfndef() = mkElement(b)
  )
  or
  // b is a preprocessor branch directive
  mkElement(b) instanceof PreprocessorBranchDirective and
  // b's parent is always taken
  alwaysTaken(b.getParent()) and
  // b itself is always taken (if it is conditional)
  not mkElement(b).(PreprocessorBranch).wasNotTaken() and
  // b's predecessors are never taken
  forall(PreprocessorBranch pred | pred.getNext+() = mkElement(b) | not pred.wasTaken())
}

/**
 * A file extended with functionality for the header cleanup queries.
 */
class FileDepends extends File {
  /**
   * Holds if this file depends upon `destination` with weight `weight`.
   *
   * This file depends upon a particular destination file if this file
   * transitively includes the destination file, and there exists at
   * least one element in this file which depends upon at least one
   * symbol provided by the destination file.
   *
   * The weight of a dependency is the number of elements in this file
   * which refer to symbols provided by the destination file.
   */
  cached
  predicate dependsUpon(File destination, int weight) {
    weight =
      strictsum(SymbolEx s, int w |
        this = s.getADependentFile(w) and
        dependsUponFor(destination, s)
      |
        w
      ) and
    destination != this
  }

  /**
   * Holds if this file depends upon `destination` for providing
   * symbol `s`.
   *
   * Where multiple files provide `s`, only those with lowest
   * preference are considered.
   *
   * For most symbols, there will be a single destination file which
   * provides the symbol. However, in some cases there can be multiple
   * files which provide the same symbol.
   */
  cached
  predicate dependsUponFor(File destination, SymbolEx s) {
    dependsUponForInternal(s, min(int preference | dependsUponForInternal(s, preference, _)),
      destination)
  }

  pragma[noopt]
  private predicate dependsUponForInternal(SymbolEx s, int preference, FileDepends destination) {
    s.getADependentFile(_) = this and
    s.providedBy(destination, preference) and
    this.transitivelyIncludesOnLine(destination, _)
  }

  /**
   * Holds if this file transitively includes `included`, via a
   * '#include' directive on line `line` in this file.
   */
  predicate transitivelyIncludesOnLine(FileDepends included, int line) {
    exists(Include i |
      i.getFile() = this and
      i.getLocation().getStartLine() = line and
      i.provides(included)
    ) and
    /*
     * If `a.h` and `b.h` both include `h.h`, then it may be that `h.h`
     *       only includes `i.h` when it has been included by `a.h`. The above
     *       general-case logic thinks that `b.h` provides `i.h`, but we can
     *       do better in the case where this is a `TranslationUnit`, as then
     *       we know exactly what it included.
     */

    (
      this instanceof TranslationUnit
      implies
      included = this.(TranslationUnit).getAFileInTranslationUnit()
    )
  }
}

/*
 * Holds if file `source` (transitively) includes file `target` first
 * on line `line`.
 */

pragma[noopt]
private predicate firstInclude(FileDepends source, int line, FileDepends target) {
  line = min(int l | source.transitivelyIncludesOnLine(target, l))
}

/**
 * An include extended with functionality for the header cleanup queries.
 */
class IncludeDepends extends Include {
  /**
   * Holds if this might transitively include `f`, and is the first
   * include in this file that might do so.
   *
   * Under the assumption that all header files have multiple-inclusion
   * guards, this provides a good approximation for the actual
   * compile-time effect of `#includes` in source files (the situation is
   * somewhat murkier for `#includes` in header files, as their
   * compile-time effect is also curtailed by `#include` directives in
   * previously included files).
   */
  cached
  predicate effectivelyProvides(File f) {
    exists(Location loc | loc = getLocation() | firstInclude(loc.getFile(), loc.getStartLine(), f))
  }

  /**
   * Holds if this include is always reached when the containing `File`
   * is compiled.
   */
  predicate alwaysReached() {
    exists(PreprocessorBlock b | b.getAnInclude() = this | alwaysTaken(b))
  }
}
