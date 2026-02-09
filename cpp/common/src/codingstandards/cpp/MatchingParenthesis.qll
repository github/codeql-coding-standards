/**
 * A library for parsing a string of parentheses and non-parentheses characters.
 *
 * Simply implement the signature class `InputString` for the set of strings that you wish to parse,
 * and then use the `MatchingParenthesis<T>` module which exposes the following classes/predicates:
 *  - `ParsedRoot`: The root of the parse tree.
 *  - `ParsedGroup`: Parenthesis groups. The root is also a group, even if not parenthesized.
 *  - `ParsedText`: All text that is not '(' or ')'.
 *  - `Tokenized`: A linked list of the tokens in the input string.
 *  - `textFrom(start, end)`: A function to get the text between two tokens.
 *
 * The parenthesis AST has functions `getChild(int i)` and `getParent()` to navigate the tree, as
 * well as `getRoot()` and `getText()` for `ParsedText` nodes. They also have methods
 * `getStartToken()`, `getEndToken()` which are especially useful with the method `textFrom(...)`.
 *
 * This module can allow for slightly more intelligent interpretation of macro strings, but it has
 * limitations.
 *  - It _only_ handles the parenthesis.
 *  - It assumes parentheses are matched.
 *  - It does not handle the case where a parenthesis is inside a string literal.
 *  - It does not handle the case where a parenthesis is inside a comment.
 *
 * This module has been moderately optimized, but still it is best to be selective with the set of
 * strings you attempt to parse with it.
 */

import codeql.util.Option

signature class InputString extends string;

module MatchingParenthesis<InputString Input> {
  newtype TTokenType =
    TOpenParen() or
    TCloseParen() or
    TNotParen()

  bindingset[char]
  private TTokenType tokenTypeOfChar(string char) {
    result = TOpenParen() and char = "("
    or
    result = TCloseParen() and char = ")"
  }

  private int inputId(Input i) { rank[result](Input inp) = i }

  private newtype TTokenized =
    TTokenizerStart(int iid) { iid = inputId(_) } or
    TToken(int iid, TTokenized prev, TTokenType token, int occurrence, int endPos) {
      exists(string inputStr, int prevEndPos, int prevOccurrence, string char |
        iid = inputId(inputStr) and
        (
          prev = TTokenizerStart(iid) and prevOccurrence = -1 and prevEndPos = 0
          or
          prev = TToken(iid, _, _, prevOccurrence, prevEndPos)
        ) and
        inputStr.charAt(prevEndPos) = char and
        if char = ["(", ")"]
        then (
          endPos = prevEndPos + 1 and
          token = tokenTypeOfChar(char) and
          occurrence = prevOccurrence + 1
        ) else (
          token = TNotParen() and
          exists(inputStr.regexpFind("\\(|\\)", prevOccurrence + 1, endPos)) and
          occurrence = prevOccurrence
        )
      )
    }

  class Tokenized extends TTokenized {
    string toString() {
      getTokenType() = TOpenParen() and result = "("
      or
      getTokenType() = TCloseParen() and result = ")"
      or
      getTokenType() = TNotParen() and result = "non-parenthesis"
    }

    int getInputId() { this = TToken(result, _, _, _, _) }

    TTokenType getTokenType() { this = TToken(_, _, result, _, _) }

    Tokenized getPrevious() { this = TToken(_, result, _, _, _) }

    string getInputString() {
      this = TToken(inputId(result), _, _, _, _) or this = TTokenizerStart(inputId(result))
    }

    int getStartPos() {
      if exists(getPrevious()) then result = getPrevious().getEndPos() else result = 0
    }

    int getEndPos() {
      this = TToken(_, _, _, _, result)
      or
      this = TTokenizerStart(_) and result = 0
    }

    string getText() { result = textFrom(this, this) }

    Tokenized getNext() { result.getPrevious() = this }

    Tokenized getLast() {
      if exists(getNext()) then result = getNext().getLast() else result = this
    }
  }

  /**
   * The root of the parse tree.
   */
  class ParsedRoot extends ParsedGroup {
    ParsedRoot() { not exists(getParent()) }

    override ParsedRoot getRoot() { result = this }

    override string getDebugText() { result = this.(Tokenized).getInputString() }
  }

  /**
   * A group of tokens that may be parenthesized.
   *
   * The `ParseRoot` is the only group that isn't parenthesized.
   */
  class ParsedGroup extends Parsed {
    ParsedGroup() { isGroup() }

    Parsed getChild(int i) {
      result.getParent() = this and
      result.getChildIdx() = i
    }
  }

  /**
   * Get the text from the `start` token to the `end` token (inclusive on both ends).
   */
  pragma[inline]
  string textFrom(Tokenized start, Tokenized end) {
    result = start.getInputString().substring(start.getStartPos(), end.getEndPos())
  }

  /**
   * All text that is not '(' or ')'.
   */
  class ParsedText extends Parsed {
    ParsedText() { not isGroup() }

    string getText() { result = textFrom(getStartToken(), getEndToken()) }
  }

  /**
   * The AST for the input string parsed with matching parenthesis.
   */
  class Parsed extends TTokenized {
    Option<ParsedGroup>::Option parent;
    int childIdx;
    boolean isGroup;

    Parsed() {
      this.(Tokenized).getTokenType() = TNotParen() and
      parseStepAppend(this, parent.asSome(), childIdx) and
      isGroup = false
      or
      this.(Tokenized).getTokenType() = TOpenParen() and
      parseStepOpen(this, parent.asSome(), childIdx) and
      isGroup = true
      or
      this = TTokenizerStart(_) and
      parent.isNone() and
      childIdx = 0 and
      isGroup = true
    }

    ParsedRoot getRoot() { result = getParent().getRoot() }

    string getInputString() { result = this.(Tokenized).getInputString() }

    /**
     * The token that starts this group.
     *
     * For `ParsedText`, this is the same as the end token.
     */
    Tokenized getStartToken() { result = this }

    /**
     * The token that endns this group.
     *
     * For `ParsedText`, this is the same as the start token. If parentheses are not matched, this
     * may not have a result.
     */
    Tokenized getEndToken() {
      this.(Tokenized).getTokenType() = TNotParen() and
      result = this
      or
      this.(Tokenized).getTokenType() = TOpenParen() and
      parseStepClose(result, this)
      or
      this = TTokenizerStart(_) and
      result = getStartToken().(Tokenized).getLast()
    }

    /**
     * The index of this child in the parent group.
     */
    int getChildIdx() { result = childIdx }

    ParsedGroup getParent() { result = parent.asSome() }

    predicate isGroup() { isGroup = true }

    string getDebugText() { result = textFrom(getStartToken(), getEndToken()) }

    string toString() { result = this.(Tokenized).toString() }
  }

  /**
   * Parse open parenthesis and add it to the open group or parse root. Parsing algorithm may not
   * behave reliably for mismatched parenthesis.
   */
  private predicate parseStepOpen(Tokenized consumeToken, ParsedGroup parent, int childIdx) {
    consumeToken.getTokenType() = TOpenParen() and
    (
      consumeToken.getPrevious() = parent.getStartToken() and
      childIdx = 0
      or
      exists(Parsed prevSibling |
        prevSibling.getEndToken() = consumeToken.getPrevious() and
        childIdx = prevSibling.getChildIdx() + 1 and
        parent = prevSibling.getParent()
      )
    )
  }

  /**
   * Parse raw text that isn't '(' or ')' and add it to the open group or parse root.
   */
  private predicate parseStepAppend(Tokenized consumeToken, ParsedGroup parent, int childIdx) {
    consumeToken.getTokenType() = TNotParen() and
    (
      consumeToken.getPrevious() = parent.getStartToken() and childIdx = 0
      or
      exists(Parsed prevSibling |
        prevSibling.getEndToken() = consumeToken.getPrevious() and
        childIdx = prevSibling.getChildIdx() + 1 and
        parent = prevSibling.getParent()
      )
    )
  }

  /**
   * Parse a close parenthesis to close the currently open group. Parsing algorithm may not behave
   * properly for mismatched parenthesis.
   */
  private predicate parseStepClose(Tokenized consumeToken, ParsedGroup closed) {
    consumeToken.getTokenType() = TCloseParen() and
    (
      closed.getStartToken() = consumeToken.getPrevious()
      or
      exists(Parsed finalChild |
        consumeToken.getPrevious() = finalChild.getEndToken() and
        finalChild.getParent() = closed
      )
    )
  }
}
