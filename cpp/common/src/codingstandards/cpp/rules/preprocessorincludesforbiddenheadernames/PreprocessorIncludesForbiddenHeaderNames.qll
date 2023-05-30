import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class PreprocessorIncludesForbiddenHeaderNamesSharedQuery extends Query { }

Query getQuery() { result instanceof PreprocessorIncludesForbiddenHeaderNamesSharedQuery }

class InvalidInclude extends Include {
  InvalidInclude() { this.getIncludeText().regexpMatch("[\"<].*(['\"\\\\]|\\/\\*|\\/\\/).*[\">]") }
}

query predicate problems(Include i, string message) {
  not isExcluded(i, getQuery()) and
  i instanceof InvalidInclude and
  message =
    "The #include of " + i.getIncludeText() +
      " contains a character sequence with implementation-defined behavior."
}
