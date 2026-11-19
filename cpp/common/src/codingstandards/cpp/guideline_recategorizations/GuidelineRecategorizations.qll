/**
 * A module for identifying guideline recategorizations specified in a `conding-standards.yml` file.
 */

import cpp
import semmle.code.cpp.XML
import codingstandards.cpp.exclusions.RuleMetadata
import codingstandards.cpp.Config

/** A container of guideline recategorizations. */
class GuidelineRecategorizations extends CodingStandardsConfigSection {
  GuidelineRecategorizations() { hasName("guideline-recategorizations") }
}

class GuidelineRecategorization extends XmlElement {
  GuidelineRecategorization() {
    getParent() instanceof GuidelineRecategorizations and
    hasName("guideline-recategorizations-entry")
  }

  string getRuleId() { result = getAChild("rule-id").getTextValue() }

  string getCategory() { result = getAChild("category").getTextValue() }

  /** Get a query for which a recategorization is specified. */
  Query getQuery() { result.getRuleId() = getRuleId() }

  /** Gets a matching query whose default category permits this recategorization. */
  Query getApplicableQuery() {
    result = getQuery() and isValidRecategorization(result.getCategory(), getCategory())
  }

  private predicate isValidRecategorization(string category, string recategorization) {
    category = ["disapplied", "advisory", "required"] and
    recategorization = "mandatory"
    or
    category = ["disapplied", "advisory"] and
    recategorization = "required"
    or
    category = "disapplied" and
    recategorization = "advisory"
    or
    category = "advisory" and
    recategorization = "disapplied"
  }

  /** Gets the reason why this recategorization is invalid for all matching queries. */
  string getAnInvalidReason() {
    not exists(getApplicableQuery()) and
    if exists(this.getQuery())
    then
      result =
        "Invalid recategorization from '" + strictconcat(getQuery().getCategory(), "' or '") +
          "' to '" + this.getCategory() + "'."
    else result = "Unknown rule id '" + this.getRuleId() + "'."
  }

  /** Gets the original category (or categories) of queries matched by this recategorization. */
  string getMatchingOriginalCategory() {
    if exists(getApplicableQuery())
    then result = strictconcat(getApplicableQuery().getCategory(), "/")
    else result = strictconcat(getQuery().getCategory(), "/")
  }

  predicate isValid() { not isInvalid() }

  predicate isInvalid() { getEffectiveCategory() = TInvalid(_) }

  EffectiveCategory getEffectiveCategory() {
    if exists(getApplicableQuery())
    then result.toString() = getCategory()
    else result = TInvalid(getAnInvalidReason())
  }
}
