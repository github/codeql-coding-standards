import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class HashOperatorsUsedQuery extends Query { }

Query getQuery() { result instanceof HashOperatorsUsedQuery }

query predicate problems(Macro m, string message) {
  exists(string body |
    body =
      m.getBody()
          .regexpReplaceAll("\\\\\"", "")
          .regexpReplaceAll("\\\\'", "")
          .regexpReplaceAll("\"[^\"]+\"", "")
          .regexpReplaceAll("'[^']+'", "") and
    exists(int n | n = body.indexOf("#")) and
    not isExcluded(m, getQuery()) and
    message = "Macro definition uses the # or ## operator."
  )
}
