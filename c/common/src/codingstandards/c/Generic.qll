import cpp
import codingstandards.cpp.Macro
import codingstandards.cpp.MatchingParenthesis

string genericRegexp() { result = "\\b_Generic\\s*\\(\\s*(.+),.*" }

bindingset[input]
string deparenthesize(string input) {
  input = "(" + result + ")" and
  result = input.substring(1, input.length() - 1)
}

class GenericMacro extends Macro {
  string ctrlExpr;

  GenericMacro() { ctrlExpr = getBody().regexpCapture(genericRegexp(), 1).trim() }

  string getAParameter() { result = this.(FunctionLikeMacro).getAParameter() }

  string getControllingExprString() {
    if exists(string s | s = deparenthesize(ctrlExpr))
    then result = deparenthesize(ctrlExpr).trim()
    else result = ctrlExpr
  }

  /**
   * Whether the controlling expression of the `_Generic` expr in this macro's controlling
   * expression refers to one of this macro's parameters.
   */
  predicate hasControllingExprFromMacroParameter() {
    getControllingExprString().matches(getAParameter())
  }
}

class GenericMacroString extends string {
  GenericMacroString() { this = any(Macro m).getBody() and this.matches("%_Generic%") }
}

import MatchingParenthesis<GenericMacroString>

class ParsedGenericMacro extends Macro {
  ParsedRoot macroBody;
  Parsed genericBody;
  string beforeGenericBody;
  string afterGenericBody;

  ParsedGenericMacro() {
    macroBody.getInputString() = this.getBody() and
    exists(ParsedText genericText |
      genericText.getText().matches("%_Generic%") and
      genericBody = genericText.getParent().getChild(genericText.getChildIdx() + 1) and
      genericBody.getRoot() = macroBody
    ) and
    beforeGenericBody =
      textFrom(macroBody.getStartToken(), genericBody.getStartToken().getPrevious()) and
    (
      if exists(genericBody.getEndToken().getNext())
      then afterGenericBody = textFrom(genericBody.getEndToken().getNext(), macroBody.getEndToken())
      else afterGenericBody = ""
    )
  }

  string getAParameter() { result = this.(FunctionLikeMacro).getAParameter() }

  int getAParsedGenericCommaSeparatorOffset() {
    exists(ParsedText text |
      text.getParent() = genericBody and
      result = text.getStartToken().getStartPos() + text.getText().indexOf(",")
    )
  }

  int getAParsedGenericColonSeparatorOffset() {
    exists(ParsedText text |
      text.getParent() = genericBody and
      result = text.getStartToken().getStartPos() + text.getText().indexOf(":")
    )
  }

  int getParsedGenericCommaSeparatorOffset(int i) {
    result = rank[i](int index | index = getAParsedGenericCommaSeparatorOffset())
  }

  bindingset[start, end]
  int getParsedGenericColon(int start, int end) {
    result =
      min(int offset |
        offset = getAParsedGenericColonSeparatorOffset() and
        offset >= start and
        offset <= end
      )
  }

  predicate hasParsedFullSelectionRange(int idx, int start, int end) {
    idx = 1 and
    start = genericBody.getStartToken().getEndPos() and
    end = getParsedGenericCommaSeparatorOffset(idx)
    or
    not exists(getParsedGenericCommaSeparatorOffset(idx)) and
    start = getParsedGenericCommaSeparatorOffset(idx - 1) and
    end = genericBody.getEndToken().getStartPos()
    or
    start = getParsedGenericCommaSeparatorOffset(idx - 1) and
    end = getParsedGenericCommaSeparatorOffset(idx)
  }

  string getSelectionString(int idx) {
    exists(int start, int rawStart, int end |
      hasParsedFullSelectionRange(idx, rawStart, end) and
      (
        if exists(getParsedGenericColon(rawStart, end))
        then start = getParsedGenericColon(rawStart, end)
        else start = rawStart
      ) and
      result = genericBody.getInputString().substring(start, end)
    )
  }

  string getControllingExprString() { result = getSelectionString(1).trim() }

  bindingset[str, word]
  private int countWordInString(string word, string str) {
    result =
      max(int occurrence |
        exists(str.regexpFind("\\b" + word + "\\b", occurrence, _)) or occurrence = -1
      |
        occurrence + 1
      )
  }

  int expansionsOutsideExpr(string parameter) {
    parameter = getAParameter() and
    result =
      countWordInString(parameter, beforeGenericBody) +
        countWordInString(parameter, afterGenericBody)
  }

  int expansionsInsideSelection(string parameter, int idx) {
    parameter = getAParameter() and
    result = countWordInString(parameter, getSelectionString(idx))
  }

  int expansionsInsideControllingExpr(string parameter) {
    result = expansionsInsideSelection(parameter, 1)
  }

  int expansionsInsideAssociation(string parameter, int idx) {
    not idx = 0 and
    result = expansionsInsideSelection(parameter, idx + 1)
  }
}
