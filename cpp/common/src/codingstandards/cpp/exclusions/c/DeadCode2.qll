//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype DeadCode2Query =
  TUnusedObjectDefinitionQuery() or
  TUnusedObjectDefinitionInMacroQuery() or
  TUnusedObjectDefinitionStrictQuery() or
  TUnusedObjectDefinitionInMacroStrictQuery()

predicate isDeadCode2QueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `unusedObjectDefinition` query
    DeadCode2Package::unusedObjectDefinitionQuery() and
  queryId =
    // `@id` for the `unusedObjectDefinition` query
    "c/misra/unused-object-definition" and
  ruleId = "RULE-2-8" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `unusedObjectDefinitionInMacro` query
    DeadCode2Package::unusedObjectDefinitionInMacroQuery() and
  queryId =
    // `@id` for the `unusedObjectDefinitionInMacro` query
    "c/misra/unused-object-definition-in-macro" and
  ruleId = "RULE-2-8" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `unusedObjectDefinitionStrict` query
    DeadCode2Package::unusedObjectDefinitionStrictQuery() and
  queryId =
    // `@id` for the `unusedObjectDefinitionStrict` query
    "c/misra/unused-object-definition-strict" and
  ruleId = "RULE-2-8" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `unusedObjectDefinitionInMacroStrict` query
    DeadCode2Package::unusedObjectDefinitionInMacroStrictQuery() and
  queryId =
    // `@id` for the `unusedObjectDefinitionInMacroStrict` query
    "c/misra/unused-object-definition-in-macro-strict" and
  ruleId = "RULE-2-8" and
  category = "advisory"
}

module DeadCode2Package {
  Query unusedObjectDefinitionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `unusedObjectDefinition` query
      TQueryC(TDeadCode2PackageQuery(TUnusedObjectDefinitionQuery()))
  }

  Query unusedObjectDefinitionInMacroQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `unusedObjectDefinitionInMacro` query
      TQueryC(TDeadCode2PackageQuery(TUnusedObjectDefinitionInMacroQuery()))
  }

  Query unusedObjectDefinitionStrictQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `unusedObjectDefinitionStrict` query
      TQueryC(TDeadCode2PackageQuery(TUnusedObjectDefinitionStrictQuery()))
  }

  Query unusedObjectDefinitionInMacroStrictQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `unusedObjectDefinitionInMacroStrict` query
      TQueryC(TDeadCode2PackageQuery(TUnusedObjectDefinitionInMacroStrictQuery()))
  }
}
