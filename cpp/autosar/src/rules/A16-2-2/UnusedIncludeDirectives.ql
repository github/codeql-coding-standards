/**
 * @id cpp/autosar/unused-include-directives
 * @name A16-2-2: There shall be no unused include directives
 * @description Unused directives increase compilation time, increase code size and can introduce
 *              unnecessary dependencies.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a16-2-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import HeaderQueries

class AcceptableSource extends File {
  AcceptableSource() { this.getExtension().matches("c%") }
}

/**
 * Options that control the dependencies generated for
 * this query.
 */
class UselessIncludeDependencyOptions extends DependencyOptions {
  override predicate preferTemplateDeps() {
    // Turn off the 'prefer template dependencies' option, because
    // dependency generation performance is much better without it.
    //
    // This means when we have several overlapping dependencies from
    // both a template and one or more instantiations, the dependency
    // library won't choose the template one in favour of the others
    // - we'll get all of them.  For the purposes of this query we
    // only care which files depend on which other files (see
    // `isFileDependency`), so this makes no difference to results.
    none()
  }
}

/**
 * Holds if `de` is the `DeclarationEntry` for a `Declaration` `d`,
 * `d` is the target of a dependency, and `de` is in
 * `PreprocessorBlock` `ppb`.
 */
predicate enclosedDeclarationEntry(PreprocessorBlock ppb, DeclarationEntry de) {
  // Only consider `PreprocessorBlock`s at the top of the tree, or when this
  // predicate holds for their parent.  This is not needed for correctness,
  // but greatly reduces the number of nodes that are examined.
  exists(Declaration d |
    dependsOnSimple(_, d) and
    getDeclarationEntries(d, de) and
    de.getFile() = mkElement(ppb)
  )
  or
  enclosedDeclarationEntry(ppb.getParent(), de) and
  de.getLocation().getStartLine() >= ppb.getStartLine() and
  de.getLocation().getStartLine() <= ppb.getEndLine()
}

/**
 * Holds if `de` is the `DeclarationEntry` for a `Declaration` `d`,
 * `d` is the target of a dependency, and `ppb` is the tightest
 * `PreprocessorBlock` enclosing `de`.
 */
predicate candidateDeclarationEntry(PreprocessorBlock ppb, DeclarationEntry de) {
  enclosedDeclarationEntry(ppb, de) and
  not enclosedDeclarationEntry(ppb.getAChild(), de)
}

/**
 * Does the dependency from Element 'src' to Declaration 'd' have access to a
 * DeclarationEntry in the same file that's sufficient that it doesn't need to
 * see any others?
 */
pragma[noopt]
predicate hasLocalDef(Element src, File srcFile, Declaration d) {
  exists(PreprocessorBlock ppb, DeclarationEntry de |
    candidateDeclarationEntry(ppb, de) and
    getDeclarationEntries(d, de) and
    (
      (
        // the DeclarationEntry is a definition, or the dependency can
        // make do with a declaration.
        de.isDefinition() and
        dependsOnSimple(src, d)
        or
        dependsOnDeclOnly(src, d)
      ) and
      exists(Location loc1, Location loc2, int line1, int line2 |
        // the DeclarationEntry comes before the point of use.
        loc1 = de.getLocation() and
        loc2 = src.getLocation() and
        loc1.getFile() = srcFile and
        loc2.getFile() = srcFile and
        line1 = loc1.getStartLine() and
        line2 = loc2.getStartLine() and
        line1 <= line2
      )
    ) and
    alwaysTaken(ppb)
  )
}

/**
 * Gets the `File`s which include `DeclarationEntry`s for `d`.
 */
pragma[noinline, nomagic]
private File getDeclarationFiles(Declaration d) {
  exists(DeclarationEntry de |
    getDeclarationEntries(d, de) and
    result = de.getFile()
  )
}

/**
 * Gets a non-local dependency of `File` `f`.
 */
pragma[noinline, nomagic]
private Element getANonLocalDependency(File f) {
  exists(Element src |
    // src depends on mid
    dependsOnTransitive(src, result) and
    // and there isn't a sufficient definition in File f anyway
    not hasLocalDef(src, _, result) and
    // src is in file f
    src.getFile() = f
  )
}

/**
 * Does a dependency exist from file `f` to file `g`.
 */
cached
predicate isFileDependency(File f, File g) {
  exists(Element mid |
    // Find a non-local dependency (extracted to improve join order)
    mid = getANonLocalDependency(f) and
    (
      // report the file of the dependency `mid`
      g = mid.getFile()
      or
      // And, if `mid` is a `Declaration`, any files that include `DeclarationEntry`s for `mid`
      g = getDeclarationFiles(mid)
    )
  )
}

/**
 * Something in useFile uses something defined in defFile, via another
 * declaration; thus defFile must be compiled (for that definition) if
 * useFile is compiled.
 */
predicate needsDefinitionFrom(File useFile, File defFile) {
  exists(Element use, DeclarationEntry decl, DeclarationEntry def, Declaration d, File declFile |
    dependsOnSimple(use, d) and
    // pointer use does not require a definition
    not dependency_pointerTypeUse(use, d) and
    decl.getDeclaration() = d and
    not decl.isDefinition() and
    def.getDeclaration() = d and
    def.isDefinition() and
    declFile = decl.getFile() and
    useFile = use.getFile() and
    defFile = def.getFile() and
    mayProvide(useFile, declFile)
  )
}

/*
 * File f may (transitively) provide an inclusion of File g.
 */

predicate mayProvide(File f, File g) { f.getAnIncludedFile*() = g }

/*
 * File f always (directly) includes File g through Include i
 */

predicate reliableIncludeBy(File f, File g, IncludeDepends i) {
  i.getFile() = f and
  i.getIncludedFile() = g and
  i.alwaysReached()
}

/*
 * File f always (directly) includes File g
 */

predicate reliableInclude(File f, File g) { reliableIncludeBy(f, g, _) }

/*
 * File f always (transitively) includes File g on a particular line
 */

cached
private predicate reliableProvideOnLine(File f, File g, int line) {
  exists(IncludeDepends i, File m |
    reliableIncludeBy(f, m, i) and
    i.getLocation().getStartLine() = line and
    reliableInclude*(m, g) and
    // if 'i' cycles back to 'f' it may hit the header guard of 'f' and
    // not actually include everything we've calculated.
    not mayProvide(m, f)
  )
}

/*
 * File f always (transitively) includes File g and 'line' is the first
 * place this reliably happens.
 */

private predicate firstReliableProvide(File f, File g, int line) {
  line = min(int l | reliableProvideOnLine(f, g, l))
}

/*
 * Include i may provide the first (transitive) inclusion of File g.
 */

cached
predicate mayProvideFirst(IncludeDepends i, File g) {
  // i may provide g and does not come after a reliable include of g.
  i.provides(g) and
  not exists(int line | firstReliableProvide(i.getFile(), g, line) |
    line < i.getLocation().getStartLine()
  )
}

/*
 * simpleUsefulInclude = include that might be useful because something in
 * i.getFile() uses something in a file g (common case)
 */

private predicate simpleUsefulInclude(IncludeDepends i) {
  // inclusive, i.e. 'could possibly be useful'
  exists(File g |
    (
      // i may be useful because it first provides file g
      mayProvideFirst(i, g)
      or
      // or i directly provides g, in which case:
      //  - it might be the first provider anyway
      //  - if not it's redundant and the redundantInclude query will
      //    flag it, so we consider it useful only to reduce overlap
      //    between the two queries.
      i.getIncludedFile() = g
    ) and
    // file i.getFile() requires file g
    isFileDependency(i.getFile(), g)
  )
}

/**
 * An `Include` that is not a `simpleUsefulInclude`.
 */
cached
predicate potentiallyUselessInclude(IncludeDepends i) { not simpleUsefulInclude(i) }

/*
 * Most of the actual logic for furtherUsefulInclude.
 */

pragma[nomagic]
cached
private predicate furtherUsefulIncludeInternal1(IncludeDepends i, File iFile, File f, File g) {
  // don't examine simple cases here
  potentiallyUselessInclude(i) and
  not contextInclude(i) and
  not protectedInclude(i) and
  not includeForDefinition(i) and
  iFile = i.getFile() and
  (
    // i may be useful because it provides file g
    mayProvideFirst(i, g)
    or
    // or i directly provides g, in which case:
    //  - it might be the first provider anyway
    //  - if not it's redundant and the redundantInclude query will
    //    flag it, so we consider it useful only to reduce overlap
    //    between the two queries.
    i.getIncludedFile() = g
  ) and
  // file f requires file g
  isFileDependency(f, g) and
  f != iFile and // case covered by simpleUsefulInclude
  // file f does not have its own independent inclusion of file g anyway
  // (note: technically this should ensure that the inclusion of
  // file g is before its use in file f)
  (
    not mayProvide(f, g) or
    mayProvide(f, iFile)
  )
}

pragma[nomagic]
cached
private predicate furtherUsefulIncludeInternal2(IncludeDepends i, File iFile, File f) {
  exists(File g |
    furtherUsefulIncludeInternal1(i, iFile, f, g) and
    // file f might still be included if i is removed
    (
      // f is outside i's include tree
      not mayProvide(i.getIncludedFile(), f)
      or
      exists(Include j, File jIncluded |
        // f is needed later in iFile than i (it may be inside i's
        // include tree as well)
        j.getFile() = iFile and
        startLineOfInclude(j) > startLineOfInclude(i) and
        jIncluded = j.getIncludedFile() and
        mayProvide(jIncluded, f) and
        not mayProvide(jIncluded, g)
      )
    )
  )
}

/*
 * furtherUsefulInclude = include that might be useful because something
 * in file f uses something in file g, where g may only be available to
 * f by the include i.
 * This covers more cases than simpleUsefulInclude which only analyses
 * includes that occur in the using file f (i.e. where f = i.getFile()).
 */

predicate furtherUsefulInclude(IncludeDepends i) {
  exists(File iFile, File f, TranslationUnit tu |
    // most of the logic
    furtherUsefulIncludeInternal2(i, iFile, f) and
    // i is in the same translation unit as f
    // TODO: this restriction is a bit weak.
    tu.getAFileInTranslationUnit() = iFile and
    tu.getAFileInTranslationUnit() = f
  )
}

pragma[nomagic]
int nestedLineWithinContext(File f) {
  exists(Element e | e instanceof Initializer or e instanceof BlockStmt |
    e.getFile() = f and
    result in [e.getLocation().getStartLine() + 1 .. e.getLocation().getEndLine() - 1]
  )
}

pragma[noinline]
int startLineOfInclude(Include i) { result = i.getLocation().getStartLine() }

/**
 * An include that is inside some context (a code block or
 * initializer) rather than being at the top level for the file.
 */
predicate contextInclude(Include i) { startLineOfInclude(i) = nestedLineWithinContext(i.getFile()) }

/*
 * A protected include is one that includes a definition that is used
 * outside of the include.  It's possible that removing the include will
 * mean the definition is no longer compiled, which will cause a link
 * error.
 */

predicate protectedInclude(IncludeDepends i) {
  potentiallyUselessInclude(i) and
  (
    exists(File useFile, File defFile, File included |
      // the included file has a definition that's used elsewhere
      included = i.getIncludedFile() and
      mayProvide(included, defFile) and
      needsDefinitionFrom(useFile, defFile) and
      not mayProvide(included, useFile)
    )
    or
    exists(DeclarationEntry de, File deFile, Declaration d, Attribute a |
      deFile = de.getFile() and
      // d is a declaration that is dllexported
      (
        a = d.(Function).getAnAttribute() or
        a = d.(Variable).getAnAttribute() or
        a = d.(Type).getAnAttribute()
      ) and
      a.getName() = "dllexport" and
      // d has a definition (something to dllexport)
      d.hasDefinition() and
      // de is declarationentry that might affect the dllexport...
      de.getDeclaration() = d and
      (
        // de is the definition of d
        de.isDefinition()
        or
        // de might specify the 'dllexport' attribute a
        deFile = a.getFile()
      ) and
      // include i may provide de
      mayProvide(i.getIncludedFile(), deFile)
    )
  )
}

/**
 * Is a pair of `FunctionDeclarationEntry` instances for the same `Function` where the `def`
 * represents a definition entry and the `decl` represents a declaration (non-definition) entry.
 */
pragma[noinline]
private predicate isDeclDefPair(FunctionDeclarationEntry def, FunctionDeclarationEntry decl) {
  exists(Function f |
    def.getFunction() = f and
    decl.getFunction() = f and
    def.isDefinition() and
    not decl.isDefinition()
  )
}

/**
 * Is a pair of `File`s where there exists some `Function` such that the `defFile` includes a
 * definition entry and the `declFile` includes a declaration (non-definition) entry for the same
 * function.
 */
pragma[noinline]
private predicate isDeclDefFilePair(File defFile, File declFile) {
  exists(FunctionDeclarationEntry def, FunctionDeclarationEntry decl |
    isDeclDefPair(def, decl) and
    def.getFile() = defFile and
    decl.getFile() = declFile
  )
}

/**
 * Holds if include `i` makes a definition of something defined in this
 * file visible.  This is not required to compile or link the program,
 * but is crucial for maintainability since it allows the compiler to
 * check that the declaration and definition match.
 */
predicate includeForDefinition(Include i) {
  exists(File defFile, File declFile |
    // improve join ordering by using a predicate that reports pairs of def/decl files
    isDeclDefFilePair(defFile, declFile) and
    defFile.getAnIncludedFile*() = i.getFile() and
    i.getIncludedFile().getAnIncludedFile*() = declFile
  )
}

from Include i, AcceptableSource src
where
  not isExcluded(i, IncludesPackage::unusedIncludeDirectivesQuery()) and
  i.getFile() = src and
  potentiallyUselessInclude(i) and
  not furtherUsefulInclude(i) and
  not contextInclude(i) and
  not protectedInclude(i) and
  not includeForDefinition(i)
select i, "Nothing in this file uses anything from " + i.getIncludeText()
