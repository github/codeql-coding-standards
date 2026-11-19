/** Tests promotions and invalid transitions for Disapplied and multi-edition recategorizations. */

import cpp
import codingstandards.cpp.exclusions.RuleMetadata
import codingstandards.cpp.guideline_recategorizations.GuidelineRecategorizations

/** A query with a disapplied default category for recategorization tests. */
class DisappliedDefaultQuery extends Query {
  DisappliedDefaultQuery() { getRuleId() = ["A0-1-1", "A0-1-6", "A10-4-1"] }

  override string getCategory() { result = "disapplied" }
}

/** A synthetic sibling query sharing `A0-1-2` with an `advisory` default category. */
class AdvisorySiblingQuery extends TestQuery {
  override string getRuleId() { result = "A0-1-2" }

  override string getCategory() { result = "advisory" }
}

from GuidelineRecategorization recategorization, Query query
where
  recategorization.getQuery() = query and
  (query instanceof DisappliedDefaultQuery or query.getRuleId() = "A0-1-2")
select query.getRuleId(), query.getCategory(), recategorization.getCategory(),
  recategorization.getMatchingOriginalCategory(),
  strictconcat(query.getEffectiveCategory().toString(), "/"),
  count(recategorization.getAnInvalidReason())
