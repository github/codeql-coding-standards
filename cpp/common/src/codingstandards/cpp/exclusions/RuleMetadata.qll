import cpp
private import cpp.RuleMetadata as CPPRuleMetadata
private import c.RuleMetadata as CRuleMetadata

newtype TQuery =
  TQueryCPP(CPPRuleMetadata::TCPPQuery t) or
  TQueryC(CRuleMetadata::TCQuery t)

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

  string toString() { result = getQueryId() }
}
