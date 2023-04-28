//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype StaticQuery = TUseOfArrayStaticQuery()

predicate isStaticQueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `useOfArrayStatic` query
    StaticPackage::useOfArrayStaticQuery() and
  queryId =
    // `@id` for the `useOfArrayStatic` query
    "c/misra/use-of-array-static" and
  ruleId = "RULE-17-6" and
  category = "mandatory"
}

module StaticPackage {
  Query useOfArrayStaticQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `useOfArrayStatic` query
      TQueryC(TStaticPackageQuery(TUseOfArrayStaticQuery()))
  }
}