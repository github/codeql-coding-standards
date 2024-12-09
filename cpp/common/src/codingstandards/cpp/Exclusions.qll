import cpp
import Customizations
import codingstandards.cpp.exclusions.RuleMetadata
import codingstandards.cpp.deviations.Deviations

/** An element which should be excluded from all Coding Standard results. */
abstract class ExcludedElement extends Element { }

/** A file which should be excluded from all Coding Standard results. */
abstract class ExcludedFile extends File { }

/** Exclude all files outside the source location. */
private class ExcludeOutsideSourceLocation extends ExcludedFile {
  ExcludeOutsideSourceLocation() { not exists(getRelativePath()) }
}

bindingset[e, query]
predicate isExcluded(Element e, Query query) { isExcluded(e, query, _) }

bindingset[e, query]
predicate isExcluded(Element e, Query query, string reason) {
  e instanceof ExcludedElement and reason = "Element is an excluded element."
  or
  e.getFile() instanceof ExcludedFile and reason = "Element is part of an excluded file."
  or
  not exists(e.getFile()) and reason = "Element is not part of the source repository."
  or
  // There exists a `DeviationRecord` that applies to this element and query, and the query's effective category permits deviation.
  query.getEffectiveCategory().permitsDeviation() and
  exists(DeviationRecord dr | applyDeviationsAtQueryLevel() |
    // The element is in a file which has a deviation for this query
    exists(string path |
      dr.isDeviated(query, path) and
      e.getFile().getRelativePath().prefix(path.length()) = path
    ) and
    reason = "Query has an associated deviation record for the element's file."
    or
    // The element is annotated by a code identifier that deviates this rule
    exists(CodeIdentifierDeviation deviationInCode |
      dr.getQuery() = query and
      deviationInCode = dr.getACodeIdentifierDeviation() and
      deviationInCode.isElementMatching(e) and
      reason =
        "Query has an associated deviation record with a code identifier that is applied to the element."
    )
  )
  or
  // The effective category of the query is 'Disapplied'.
  // This can occur when a Guideline Recategorization Plan is applied.
  query.getEffectiveCategory().isDisapplied() and
  reason = "The query is disapplied."
}
