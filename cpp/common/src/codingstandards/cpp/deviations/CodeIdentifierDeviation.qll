/**
 * A module for identifying in code markers in code that trigger deviations.
 *
 * This module supports two different code identifier markers:
 *  - A C/C++ attribute based syntax
 *  - A comment-based format
 *
 * The C/C++ attribute based syntax uses the following format:
 * ```
 * [[codeql::<standard>_deviation("code-identifier")]]
 * ```
 * The deviation will be applied to the selected program element, and any syntactically nested children of that program element.
 *
 * For the comment format the marker consists of a `code-identifier` with some optional annotations. A deviation will be applied to
 * some range of lines in the file containing the comment based on the annotation. The supported marker annotation
 * formats are:
 *  - `<code-identifier>` - the deviation applies to results on the current line.
 *  - `codeql::<standard>_deviation(<code-identifier>)` - same as above.
 *  - `codeql::<standard>_deviation_next_line(<code-identifier>)` - this deviation applies to results on the next line.
 *  - `codeql::<standard>_deviation_begin(<code-identifier>)` - marks the beginning of a range of lines where the deviation applies.
 *  - `codeql::<standard>_deviation_end(<code-identifier>)` - marks the end of a range of lines where the deviation applies.
 *
 * The valid `code-identifier`s are specified in deviation records, which also specify the query whose results are
 * suppressed by the deviation.
 *
 * For begin/end, we maintain a stack of begin markers. When we encounter an end marker, we pop the stack to determine
 * the range of that begin/end marker. If the stack is empty, the end marker is considered unmatched and invalid. If
 * the stack is non-empty at the end of the file, all the begin markers are considered unmatched and invalid.
 *
 * Begin/end markers are not valid across include boundaries, as the stack is not maintained across files.
 */

import cpp
import Deviations
import codingstandards.cpp.Locations

string supportedStandard() { result = ["misra", "autosar", "cert"] }

/**
 * Holds if the given comment contains the code identifier.
 */
bindingset[codeIdentifier]
private predicate commentMatches(Comment comment, string codeIdentifier) {
  exists(string text |
    comment instanceof CppStyleComment and
    // strip the beginning slashes
    text = comment.getContents().suffix(2).trim()
    or
    comment instanceof CStyleComment and
    // strip both the beginning /* and the end */ the comment
    exists(string text0 |
      text0 = comment.getContents().suffix(2) and
      text = text0.prefix(text0.length() - 2).trim()
    ) and
    // The /* */ comment must be a single-line comment
    not text.matches("%\n%")
  |
    // Code identifier appears at the start of the comment (modulo whitespace)
    text.prefix(codeIdentifier.length()) = codeIdentifier
    or
    // Code identifier appears at the end of the comment (modulo whitespace)
    text.suffix(text.length() - codeIdentifier.length()) = codeIdentifier
  )
}

/**
 * A deviation marker in the code.
 */
abstract class CommentDeviationMarker extends Comment {
  DeviationRecord record;

  /**
   * Gets the deviation record associated with this deviation marker.
   */
  DeviationRecord getRecord() { result = record }
}

/**
 * A deviation marker in a comment that is not a valid deviation marker.
 */
class InvalidCommentDeviationMarker extends Comment {
  InvalidCommentDeviationMarker() {
    not this instanceof CommentDeviationMarker and
    commentMatches(this, "codeql::" + supportedStandard() + "_deviation")
  }
}

/**
 * A deviation marker for a deviation that applies to the current line.
 */
class DeviationEndOfLineMarker extends CommentDeviationMarker {
  DeviationEndOfLineMarker() {
    commentMatches(this,
      "codeql::" + supportedStandard() + "_deviation(" + record.getCodeIdentifier() + ")")
  }
}

/**
 * A deviation marker for a deviation that applies to the next line.
 */
class DeviationNextLineMarker extends CommentDeviationMarker {
  DeviationNextLineMarker() {
    commentMatches(this,
      "codeql::" + supportedStandard() + "_deviation_next_line(" + record.getCodeIdentifier() + ")")
  }
}

/**
 * A deviation marker for a deviation that applies to a range of lines
 */
abstract class CommentDeviationRangeMarker extends CommentDeviationMarker { }

/**
 * A deviation marker for a deviation that begins on this line.
 */
class DeviationBegin extends CommentDeviationRangeMarker {
  DeviationBegin() {
    commentMatches(this,
      "codeql::" + supportedStandard() + "_deviation_begin(" + record.getCodeIdentifier() + ")")
  }
}

/**
 * A deviation marker for a deviation that ends on this line.
 */
class DeviationEnd extends CommentDeviationRangeMarker {
  DeviationEnd() {
    commentMatches(this,
      "codeql::" + supportedStandard() + "_deviation_end(" + record.getCodeIdentifier() + ")")
  }
}

private predicate hasDeviationCommentFileOrdering(
  DeviationRecord record, CommentDeviationRangeMarker comment, File file, int index
) {
  comment =
    rank[index](CommentDeviationRangeMarker c |
      c.getRecord() = record and
      file = c.getFile()
    |
      c order by c.getLocation().getStartLine(), c.getLocation().getStartColumn()
    )
}

/**
 * Calculate the stack of deviation begin markers related to the given deviation record, in the given file,
 * at the given `markerRecordFileIndex` into the list of deviation markers for that record in that file.
 */
private BeginStack calculateBeginStack(DeviationRecord record, File file, int markerRecordFileIndex) {
  // Stack is empty at the start
  markerRecordFileIndex = 0 and
  result = TEmptyBeginStack() and
  // Only initialize when there is at least one such comment marker for this file and record
  // pairing
  exists(CommentDeviationRangeMarker marker |
    marker.getRecord() = record and marker.getLocation().getFile() = file
  )
  or
  // Next token is begin, so push it to the stack
  exists(DeviationBegin begin, BeginStack prev |
    record = begin.getRecord() and
    hasDeviationCommentFileOrdering(record, begin, file, markerRecordFileIndex) and
    prev = calculateBeginStack(record, file, markerRecordFileIndex - 1) and
    result = TConsBeginStack(begin, prev)
  )
  or
  // Next token is end
  exists(DeviationEnd end, BeginStack prevStack |
    record = end.getRecord() and
    hasDeviationCommentFileOrdering(record, end, file, markerRecordFileIndex) and
    prevStack = calculateBeginStack(record, file, markerRecordFileIndex - 1)
  |
    // There is, so pop the most recent begin off the stack
    prevStack = TConsBeginStack(_, result)
    or
    // Error, no begin on the stack, ignore the end and continue
    prevStack = TEmptyBeginStack() and
    result = TEmptyBeginStack()
  )
}

newtype TBeginStack =
  TConsBeginStack(DeviationBegin begin, TBeginStack prev) {
    exists(File file, int index |
      hasDeviationCommentFileOrdering(begin.getRecord(), begin, file, index) and
      prev = calculateBeginStack(begin.getRecord(), file, index - 1)
    )
  } or
  TEmptyBeginStack()

/**
 * A stack of begin markers that occur in the same file, referring to the same record.
 */
private class BeginStack extends TBeginStack {
  /** Gets the top begin marker on the stack. */
  DeviationBegin peek() { this = TConsBeginStack(result, _) }

  string toString() {
    exists(DeviationBegin begin, BeginStack prev | this = TConsBeginStack(begin, prev) |
      result = "(" + begin + ", " + prev.toString() + ")"
    )
    or
    this = TEmptyBeginStack() and
    result = "()"
  }
}

predicate isDeviationRangePaired(DeviationRecord record, DeviationBegin begin, DeviationEnd end) {
  exists(File file, int index |
    record = end.getRecord() and
    hasDeviationCommentFileOrdering(record, end, file, index) and
    begin = calculateBeginStack(record, file, index - 1).peek()
  )
}

/**
 * A standard attribute that either deviates a result.
 */
class DeviationAttribute extends StdAttribute {
  DeviationRecord record;

  DeviationAttribute() {
    this.hasQualifiedName("codeql", supportedStandard() + "_deviation") and
    // Support multiple argument deviations
    "\"" + record.getCodeIdentifier() + "\"" = this.getAnArgument().getValueText()
  }

  DeviationRecord getADeviationRecord() { result = record }

  /** Gets the element to which this attribute was applied. */
  Element getPrimarySuppressedElement() {
    result.(Type).getAnAttribute() = this
    or
    result.(Stmt).getAnAttribute() = this
    or
    result.(Variable).getAnAttribute() = this
    or
    result.(Function).getAnAttribute() = this
  }

  pragma[nomagic]
  Element getASuppressedElement() {
    result = this.getPrimarySuppressedElement()
    or
    result.(Expr).getEnclosingStmt() = this.getASuppressedElement()
    or
    result.(Stmt).getParentStmt() = this.getASuppressedElement()
    or
    result.(Stmt).getEnclosingFunction() = this.getASuppressedElement()
    or
    result.(LocalVariable) = this.getASuppressedElement().(DeclStmt).getADeclaration()
    or
    result.(Function).getDeclaringType() = this.getASuppressedElement()
    or
    result.(Variable).getDeclaringType() = this.getASuppressedElement()
    or
    exists(LambdaExpression expr |
      expr = this.getASuppressedElement() and
      result = expr.getLambdaFunction()
    )
    or
    exists(Function f |
      f = this.getASuppressedElement() and
      // A suppression on the function should apply to the noexcept expression
      result = f.getADeclarationEntry().getNoExceptExpr()
    )
  }
}

/**
 * A deviation attribute that is not associated with any deviation record.
 */
class InvalidDeviationAttribute extends StdAttribute {
  string unknownCodeIdentifier;

  InvalidDeviationAttribute() {
    this.hasQualifiedName("codeql", supportedStandard() + "_deviation") and
    "\"" + unknownCodeIdentifier + "\"" = this.getAnArgument().getValueText() and
    not exists(DeviationRecord record | record.getCodeIdentifier() = unknownCodeIdentifier)
  }

  string getAnUnknownCodeIdentifier() { result = unknownCodeIdentifier }
}

newtype TCodeIndentifierDeviation =
  TSingleLineDeviation(DeviationRecord record, Comment comment, string filepath, int suppressedLine) {
    (
      commentMatches(comment, record.getCodeIdentifier()) or
      comment.(DeviationEndOfLineMarker).getRecord() = record
    ) and
    comment.getLocation().hasLocationInfo(filepath, suppressedLine, _, _, _)
    or
    comment.(DeviationNextLineMarker).getRecord() = record and
    comment.getLocation().hasLocationInfo(filepath, suppressedLine - 1, _, _, _)
  } or
  TMultiLineDeviation(
    DeviationRecord record, DeviationBegin beginComment, DeviationEnd endComment, string filepath,
    int suppressedStartLine, int suppressedStartColumn, int suppressedEndLine,
    int suppressedEndColumn
  ) {
    isDeviationRangePaired(record, beginComment, endComment) and
    beginComment
        .getLocation()
        .hasLocationInfo(filepath, suppressedStartLine, suppressedStartColumn, _, _) and
    endComment.getLocation().hasLocationInfo(filepath, _, _, suppressedEndLine, suppressedEndColumn)
  } or
  TCodeIdentifierDeviation(DeviationRecord record, DeviationAttribute attribute) {
    attribute.getADeviationRecord() = record
  }

class CodeIdentifierDeviation extends TCodeIndentifierDeviation {
  /** The deviation record associated with the deviation comment. */
  DeviationRecord getADeviationRecord() {
    this = TSingleLineDeviation(result, _, _, _)
    or
    this = TMultiLineDeviation(result, _, _, _, _, _, _, _)
    or
    this = TCodeIdentifierDeviation(result, _)
  }

  /**
   * Holds if the given element is matched by this code identifier deviation.
   */
  bindingset[e]
  pragma[inline_late]
  predicate isElementMatching(Element e) {
    exists(string filepath, int elementLocationStart, int elementLocationColumnStart |
      e.getLocation()
          .hasLocationInfo(filepath, elementLocationStart, elementLocationColumnStart, _, _)
    |
      exists(int suppressedLine |
        this = TSingleLineDeviation(_, _, filepath, suppressedLine) and
        suppressedLine = elementLocationStart
      )
      or
      exists(
        int suppressedStartLine, int suppressedStartColumn, int suppressedEndLine,
        int suppressedEndColumn
      |
        this =
          TMultiLineDeviation(_, _, _, filepath, suppressedStartLine, suppressedStartColumn,
            suppressedEndLine, suppressedEndColumn) and
        (
          // Element starts on a line after the begin marker of the suppression
          suppressedStartLine < elementLocationStart
          or
          // Element exists on the same line as the begin marker, and occurs after it
          suppressedStartLine = elementLocationStart and
          suppressedStartColumn < elementLocationColumnStart
        ) and
        (
          // Element starts on a line before the end marker of the suppression
          suppressedEndLine > elementLocationStart
          or
          // Element exists on the same line as the end marker of the suppression, and occurs before it
          suppressedEndLine = elementLocationStart and
          elementLocationColumnStart < suppressedEndColumn
        )
      )
    )
    or
    exists(DeviationAttribute attribute |
      this = TCodeIdentifierDeviation(_, attribute) and
      attribute.getASuppressedElement() = e
    )
  }

  /**
   * Holds for the region matched by this code identifier deviation.
   *
   * Note: this is not the location of the marker itself.
   */
  predicate hasLocationInfo(
    string filepath, int suppressedLine, int suppressedColumn, int endline, int endcolumn
  ) {
    exists(Comment commentMarker |
      this = TSingleLineDeviation(_, commentMarker, filepath, suppressedLine) and
      suppressedColumn = 1 and
      endline = suppressedLine
    |
      if commentMarker instanceof DeviationEndOfLineMarker
      then endcolumn = commentMarker.(DeviationEndOfLineMarker).getLocation().getEndColumn()
      else
        // Find the last column for a location on the next line
        endcolumn = getLastColumnNumber(filepath, suppressedLine)
    )
    or
    this =
      TMultiLineDeviation(_, _, _, filepath, suppressedLine, suppressedColumn, endline, endcolumn)
    or
    exists(DeviationAttribute attribute |
      this = TCodeIdentifierDeviation(_, attribute) and
      attribute
          .getPrimarySuppressedElement()
          .getLocation()
          .hasLocationInfo(filepath, suppressedLine, suppressedColumn, endline, endcolumn)
    )
  }

  string toString() {
    exists(string filepath |
      exists(int suppressedLine |
        this = TSingleLineDeviation(_, _, filepath, suppressedLine) and
        result =
          "Deviation of " + getADeviationRecord().getQuery() + " applied to " + filepath + " Line " +
            suppressedLine
      )
      or
      exists(
        int suppressedStartLine, int suppressedStartColumn, int suppressedEndLine,
        int suppressedEndColumn
      |
        this =
          TMultiLineDeviation(_, _, _, filepath, suppressedStartLine, suppressedStartColumn,
            suppressedEndLine, suppressedEndColumn) and
        result =
          "Deviation of " + getADeviationRecord().getQuery() + " applied to " + filepath + " Line " +
            suppressedStartLine + ":" + suppressedStartColumn + ":" + suppressedEndLine + ":" +
            suppressedEndColumn
      )
    )
    or
    exists(DeviationAttribute attribute |
      this = TCodeIdentifierDeviation(_, attribute) and
      result = "Deviation of " + getADeviationRecord().getQuery() + " applied to " + attribute
    )
  }
}
