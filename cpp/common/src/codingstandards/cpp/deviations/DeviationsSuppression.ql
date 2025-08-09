/**
 * @name Deviation suppression
 * @description Generates information about files and locations where certain alerts should be considered suppressed by deviations.
 * @kind alert-suppression
 * @id cpp/coding-standards/deviation-suppression
 */

import cpp
import Deviations
import codingstandards.cpp.Locations

newtype TDeviationScope =
  TDeviationRecordFileScope(DeviationRecord dr, File file) {
    exists(string deviationPath |
      dr.isDeviated(_, deviationPath) and
      file.getRelativePath().prefix(deviationPath.length()) = deviationPath
    )
  } or
  TDeviationRecordCodeIdentiferDeviationScope(DeviationRecord dr, CodeIdentifierDeviation c) {
    c = dr.getACodeIdentifierDeviation()
  }

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
    // the whole file was suppressed. However, the alert suppression code only works with locations
    // with lines and columns, so we generate a location that covers the whole "indexed" file, by
    // finding the location indexed in the database with the latest line and column number.
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
class DeviationRecordCommentScope extends DeviationScope,
  TDeviationRecordCodeIdentiferDeviationScope
{
  private DeviationRecord getDeviationRecord() {
    this = TDeviationRecordCodeIdentiferDeviationScope(result, _)
  }

  private CodeIdentifierDeviation getCodeIdentifierDeviation() {
    this = TDeviationRecordCodeIdentiferDeviationScope(_, result)
  }

  override Locatable getDeviationDefinitionLocation() { result = getDeviationRecord() }

  override Query getQuery() { result = getDeviationRecord().getQuery() }

  override predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    getCodeIdentifierDeviation()
        .hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  override string toString() { result = getCodeIdentifierDeviation().toString() }
}

from DeviationScope deviationScope
select deviationScope.getDeviationDefinitionLocation(), // suppression comment
  "// lgtm[" + deviationScope.getQuery().getQueryId() + "]", // text of suppression comment (excluding delimiters)
  "lgtm[" + deviationScope.getQuery().getQueryId() + "]", // text of suppression annotation
  deviationScope // scope of suppression
