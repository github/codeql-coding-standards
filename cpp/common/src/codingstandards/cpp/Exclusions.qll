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

/** Holds if the element should be excluded. */
predicate isExcluded(Element e) {
  e instanceof ExcludedElement
  or
  e.getFile() instanceof ExcludedFile
  or
  // Compiler generated
  not exists(e.getFile())
}

bindingset[e, query]
predicate isExcluded(Element e, Query query) {
  e instanceof ExcludedElement
  or
  e.getFile() instanceof ExcludedFile
  or
  not exists(e.getFile())
  or
  // There exists a `DeviationRecord` that applies to this element and query, and the query's effective category permits deviation.
  query.getEffectiveCategory().permitsDeviation() and
  exists(DeviationRecord dr | applyDeviationsAtQueryLevel() |
    // The element is in a file which has a deviation for this query
    exists(string path |
      dr.isDeviated(query, path) and
      e.getFile().getRelativePath().prefix(path.length()) = path
    )
    or
    // The element is on the same line as a suppression comment
    exists(Comment c |
      c = dr.getACodeIdentifierComment() and
      query = dr.getQuery()
    |
      exists(string filepath, int endLine |
        // Comment occurs on the same line as the end line of the element
        e.getLocation().hasLocationInfo(filepath, _, _, endLine, _) and
        c.getLocation().hasLocationInfo(filepath, endLine, _, _, _)
      )
    )
  )
}
