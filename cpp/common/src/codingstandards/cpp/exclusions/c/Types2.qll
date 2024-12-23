//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype Types2Query =
  TInvalidIntegerConstantMacroArgumentQuery() or
  TInvalidLiteralForIntegerConstantMacroArgumentQuery() or
  TIntegerConstantMacroArgumentUsesSuffixQuery() or
  TIncorrectlySizedIntegerConstantMacroArgumentQuery() or
  TUseOfBannedSmallIntegerConstantMacroQuery()

predicate isTypes2QueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `invalidIntegerConstantMacroArgument` query
    Types2Package::invalidIntegerConstantMacroArgumentQuery() and
  queryId =
    // `@id` for the `invalidIntegerConstantMacroArgument` query
    "c/misra/invalid-integer-constant-macro-argument" and
  ruleId = "RULE-7-5" and
  category = "required"
  or
  query =
    // `Query` instance for the `invalidLiteralForIntegerConstantMacroArgument` query
    Types2Package::invalidLiteralForIntegerConstantMacroArgumentQuery() and
  queryId =
    // `@id` for the `invalidLiteralForIntegerConstantMacroArgument` query
    "c/misra/invalid-literal-for-integer-constant-macro-argument" and
  ruleId = "RULE-7-5" and
  category = "required"
  or
  query =
    // `Query` instance for the `integerConstantMacroArgumentUsesSuffix` query
    Types2Package::integerConstantMacroArgumentUsesSuffixQuery() and
  queryId =
    // `@id` for the `integerConstantMacroArgumentUsesSuffix` query
    "c/misra/integer-constant-macro-argument-uses-suffix" and
  ruleId = "RULE-7-5" and
  category = "required"
  or
  query =
    // `Query` instance for the `incorrectlySizedIntegerConstantMacroArgument` query
    Types2Package::incorrectlySizedIntegerConstantMacroArgumentQuery() and
  queryId =
    // `@id` for the `incorrectlySizedIntegerConstantMacroArgument` query
    "c/misra/incorrectly-sized-integer-constant-macro-argument" and
  ruleId = "RULE-7-5" and
  category = "required"
  or
  query =
    // `Query` instance for the `useOfBannedSmallIntegerConstantMacro` query
    Types2Package::useOfBannedSmallIntegerConstantMacroQuery() and
  queryId =
    // `@id` for the `useOfBannedSmallIntegerConstantMacro` query
    "c/misra/use-of-banned-small-integer-constant-macro" and
  ruleId = "RULE-7-6" and
  category = "required"
}

module Types2Package {
  Query invalidIntegerConstantMacroArgumentQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `invalidIntegerConstantMacroArgument` query
      TQueryC(TTypes2PackageQuery(TInvalidIntegerConstantMacroArgumentQuery()))
  }

  Query invalidLiteralForIntegerConstantMacroArgumentQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `invalidLiteralForIntegerConstantMacroArgument` query
      TQueryC(TTypes2PackageQuery(TInvalidLiteralForIntegerConstantMacroArgumentQuery()))
  }

  Query integerConstantMacroArgumentUsesSuffixQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `integerConstantMacroArgumentUsesSuffix` query
      TQueryC(TTypes2PackageQuery(TIntegerConstantMacroArgumentUsesSuffixQuery()))
  }

  Query incorrectlySizedIntegerConstantMacroArgumentQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `incorrectlySizedIntegerConstantMacroArgument` query
      TQueryC(TTypes2PackageQuery(TIncorrectlySizedIntegerConstantMacroArgumentQuery()))
  }

  Query useOfBannedSmallIntegerConstantMacroQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `useOfBannedSmallIntegerConstantMacro` query
      TQueryC(TTypes2PackageQuery(TUseOfBannedSmallIntegerConstantMacroQuery()))
  }
}
