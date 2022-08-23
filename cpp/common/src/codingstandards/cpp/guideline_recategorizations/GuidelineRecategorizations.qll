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

newtype TEffectiveCategory =
  TInvalid(string reason) {
    exists(GuidelineRecategorization gr | reason = gr.getAnInvalidReason())
  } or
  TDisapplied() or
  TAdvisory() or
  TRequired() or
  TMandatory()

class EffectiveCategory extends TEffectiveCategory {
  string toString() {
    this instanceof TInvalid and result = "invalid"
    or
    this instanceof TDisapplied and result = "disapplied"
    or
    this instanceof TAdvisory and result = "advisory"
    or
    this instanceof TRequired and result = "required"
    or
    this instanceof TMandatory and result = "mandatory"
  }

  /** Holds if the effective category permits a deviation */
  predicate permitsDeviation() { not this instanceof TMandatory and not this instanceof TInvalid }
}

class GuidelineRecategorization extends XMLElement {
  GuidelineRecategorization() {
    getParent() instanceof GuidelineRecategorizations and
    hasName("guideline-recategorizations-entry")
  }

  string getRuleId() { result = getAChild("rule-id").getTextValue() }

  string getCategory() { result = getAChild("category").getTextValue() }

  /** Get a query for which a recategorization is specified. */
  Query getQuery() { result.getRuleId() = getRuleId() }

  private EffectiveCategory getValidEffectiveCategory() {
    exists(string category, string recategorization |
      category = getQuery().getCategory() and
      recategorization = getCategory()
    |
      result = TMandatory() and
      category = ["advisory", "required"] and
      recategorization = "mandatory"
      or
      result = TRequired() and
      category = "advisory" and
      recategorization = "required"
      or
      result = TDisapplied() and
      category = "advisory" and
      recategorization = "disapplied"
    )
  }

  private predicate isValidRecategorization(string category, string recategorization) {
    category = ["advisory", "required"] and
    recategorization = "mandatory"
    or
    category = "advisory" and
    recategorization = "required"
    or
    category = "advisory" and
    recategorization = "disapplied"
  }

  string getAnInvalidReason() {
    not isValidRecategorization(this.getQuery().getCategory(), this.getCategory()) and
    if exists(this.getQuery())
    then
      result =
        "Invalid recategorization from '" + this.getQuery().getCategory() + "' to '" +
          this.getCategory() + "'."
    else result = "Unknown rule id '" + this.getRuleId() + "'."
  }

  predicate isValid() { not isInvalid() }

  predicate isInvalid() { getEffectiveCategory() = TInvalid(_) }

  EffectiveCategory getEffectiveCategory() {
    (
      if exists(getValidEffectiveCategory())
      then result = getValidEffectiveCategory()
      else result = TInvalid(getAnInvalidReason())
    )
  }
}
