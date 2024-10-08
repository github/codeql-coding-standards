//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype NoReturnQuery =
  TNonVoidReturnTypeOfNoreturnFunctionQuery() or
  TFunctionWithNoReturningBranchShouldBeNoreturnQuery() or
  TReturnStatementInNoreturnFunctionQuery()

predicate isNoReturnQueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `nonVoidReturnTypeOfNoreturnFunction` query
    NoReturnPackage::nonVoidReturnTypeOfNoreturnFunctionQuery() and
  queryId =
    // `@id` for the `nonVoidReturnTypeOfNoreturnFunction` query
    "c/misra/non-void-return-type-of-noreturn-function" and
  ruleId = "RULE-17-10" and
  category = "required"
  or
  query =
    // `Query` instance for the `functionWithNoReturningBranchShouldBeNoreturn` query
    NoReturnPackage::functionWithNoReturningBranchShouldBeNoreturnQuery() and
  queryId =
    // `@id` for the `functionWithNoReturningBranchShouldBeNoreturn` query
    "c/misra/function-with-no-returning-branch-should-be-noreturn" and
  ruleId = "RULE-17-11" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `returnStatementInNoreturnFunction` query
    NoReturnPackage::returnStatementInNoreturnFunctionQuery() and
  queryId =
    // `@id` for the `returnStatementInNoreturnFunction` query
    "c/misra/return-statement-in-noreturn-function" and
  ruleId = "RULE-17-9" and
  category = "mandatory"
}

module NoReturnPackage {
  Query nonVoidReturnTypeOfNoreturnFunctionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `nonVoidReturnTypeOfNoreturnFunction` query
      TQueryC(TNoReturnPackageQuery(TNonVoidReturnTypeOfNoreturnFunctionQuery()))
  }

  Query functionWithNoReturningBranchShouldBeNoreturnQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `functionWithNoReturningBranchShouldBeNoreturn` query
      TQueryC(TNoReturnPackageQuery(TFunctionWithNoReturningBranchShouldBeNoreturnQuery()))
  }

  Query returnStatementInNoreturnFunctionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `returnStatementInNoreturnFunction` query
      TQueryC(TNoReturnPackageQuery(TReturnStatementInNoreturnFunctionQuery()))
  }
}
