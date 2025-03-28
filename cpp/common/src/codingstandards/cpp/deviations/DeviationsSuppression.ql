/**
 * @name Deviation suppression
 * @description Generates information about files and locations where certain alerts should be considered suppressed by deviations.
 * @kind alert-suppression
 * @id cpp/coding-standards/deviation-suppression
 */

import cpp
import Deviations

/** Holds if `lineNumber` is an indexed line number in file `f`. */
private predicate isLineNumber(File f, int lineNumber) {
  exists(Location l | l.getFile() = f |
    l.getStartLine() = lineNumber
    or
    l.getEndLine() = lineNumber
  )
}

/** Gets the last line number in `f`. */
private int getLastLineNumber(File f) { result = max(int lineNumber | isLineNumber(f, lineNumber)) }

/** Gets the last column number on the last line of `f`. */
int getLastColumnNumber(File f) {
  result =
    max(Location l |
      l.getFile() = f and
      l.getEndLine() = getLastLineNumber(f)
    |
      l.getEndColumn()
    )
}

newtype TDeviationScope =
  TDeviationRecordFileScope(DeviationRecord dr, File file) {
    exists(string deviationPath |
      dr.isDeviated(_, deviationPath) and
      file.getRelativePath().prefix(deviationPath.length()) = deviationPath
    )
  } or
  TDeviationRecordCommentScope(DeviationRecord dr, Comment c) { c = dr.getACodeIdentifierComment() }

/** A deviation scope. */
class DeviationScope extends TDeviationScope {
  /** Gets the location at which this deviation was defined. */
  abstract Locatable getDeviationDefinitionLocation();

  /** Gets the Query being deviated. */
  abstract Query getQuery();

  abstract string toString();

  abstract predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  );
}

/** A deviation scope derived from a "path" entry in a `DeviationRecord`. */
class DeviationRecordFileScope extends DeviationScope, TDeviationRecordFileScope {
  private DeviationRecord getDeviationRecord() { this = TDeviationRecordFileScope(result, _) }

  override Locatable getDeviationDefinitionLocation() { result = getDeviationRecord() }

  private File getFile() { this = TDeviationRecordFileScope(_, result) }

  override Query getQuery() { result = getDeviationRecord().getQuery() }

  override predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    // In an ideal world, we would produce a URL here that informed the AlertSuppression code that
    // the whole file was suppressed. However, experimentation suggestions the alert suppression
    // code only works with locations with lines and columns, so we generate a location that covers
    // the whole "indexed" file, by finding the location indexed in the database with the latest
    // line and column number.
    exists(File f | f = getFile() |
      f.getLocation().hasLocationInfo(filepath, _, _, _, _) and
      startline = 1 and
      startcolumn = 1 and
      endline = getLastLineNumber(f) and
      endcolumn = getLastColumnNumber(f)
    )
  }

  override string toString() {
    result = "Deviation of " + getDeviationRecord().getQuery() + " for " + getFile() + "."
  }
}

/**
 * A deviation scope derived from a comment corresponding to a "code-identifier" entry for a
 * `DeviationRecord`.
 */
class DeviationRecordCommentScope extends DeviationScope, TDeviationRecordCommentScope {
  private DeviationRecord getDeviationRecord() { this = TDeviationRecordCommentScope(result, _) }

  private Comment getComment() { this = TDeviationRecordCommentScope(_, result) }

  override Locatable getDeviationDefinitionLocation() { result = getDeviationRecord() }

  override Query getQuery() { result = getDeviationRecord().getQuery() }

  override predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    getComment().getLocation().hasLocationInfo(filepath, startline, _, endline, endcolumn) and
    startcolumn = 1
  }

  override string toString() {
    result =
      "Deviation of " + getDeviationRecord().getQuery() + " for comment " + getComment() + "."
  }
}

from DeviationScope deviationScope
select deviationScope.getDeviationDefinitionLocation(), // suppression comment
  "// lgtm[" + deviationScope.getQuery().getQueryId() + "]", // text of suppression comment (excluding delimiters)
  "lgtm[" + deviationScope.getQuery().getQueryId() + "]", // text of suppression annotation
  deviationScope // scope of suppression
