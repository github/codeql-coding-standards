import cpp
private import cpp.RuleMetadata as CPPRuleMetadata
private import c.RuleMetadata as CRuleMetadata
private import codingstandards.cpp.guideline_recategorizations.GuidelineRecategorizations

newtype TQuery =
  TQueryCPP(CPPRuleMetadata::TCPPQuery t) or
  TQueryC(CRuleMetadata::TCQuery t)

private predicate isMisraRuleCategory(string category) {
  category = ["disapplied", "advisory", "required", "mandatory"]
}

newtype TEffectiveCategory =
  TInvalid(string reason) {
    exists(GuidelineRecategorization gr | reason = gr.getAnInvalidReason())
  } or
  TDisapplied() or
  TAdvisory() or
  TRequired() or
  TMandatory() or
  TNonMisraRuleCategory(string category) {
    exists(Query q | q.getCategory() = category | not isMisraRuleCategory(category))
  }

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
    or
    this = TNonMisraRuleCategory(result)
  }

  /** Holds if the effective category permits a deviation */
  predicate permitsDeviation() { not this instanceof TMandatory and not this instanceof TInvalid }
}

class Query extends TQuery {
  string getQueryId() {
    CPPRuleMetadata::isQueryMetadata(this, result, _, _) or
    CRuleMetadata::isQueryMetadata(this, result, _, _)
  }

  string getRuleId() {
    CPPRuleMetadata::isQueryMetadata(this, _, result, _) or
    CRuleMetadata::isQueryMetadata(this, _, result, _)
  }

  string getCategory() {
    CPPRuleMetadata::isQueryMetadata(this, _, _, result) or
    CRuleMetadata::isQueryMetadata(this, _, _, result)
  }

  EffectiveCategory getEffectiveCategory() {
    if exists(GuidelineRecategorization gr | gr.getQuery() = this)
    then
      exists(GuidelineRecategorization gr | gr.getQuery() = this |
        result = gr.getEffectiveCategory()
      )
    else result.toString() = this.getCategory()
  }

  string toString() { result = getQueryId() }
}
