/** Tests promotions from the Disapplied category using existing configuration fixtures. */

import cpp
import codingstandards.cpp.exclusions.RuleMetadata
import codingstandards.cpp.guideline_recategorizations.GuidelineRecategorizations

/** A query with a disapplied default category for recategorization tests. */
class DisappliedDefaultQuery extends Query {
  DisappliedDefaultQuery() { getRuleId() = ["A0-1-1", "A10-4-1"] }

  override string getCategory() { result = "disapplied" }
}

from GuidelineRecategorization recategorization, DisappliedDefaultQuery query
where recategorization.getQuery() = query
select query.getCategory(), recategorization.getCategory(),
  recategorization.getEffectiveCategory().toString(),
  count(string reason | reason = recategorization.getAnInvalidReason())
