//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype Contracts2Query =
  TExitHandlersMustReturnNormallyQuery() or
  TDoNotStorePointersReturnedByCertainFunctionsQuery() or
  TValuesReturnedByLocaleSettingUsedAsPtrToConstQuery() or
  TSubsequentCallToSetlocaleInvalidatesOldPointersQuery()

predicate isContracts2QueryMetadata(Query query, string queryId, string ruleId) {
  query =
    // `Query` instance for the `exitHandlersMustReturnNormally` query
    Contracts2Package::exitHandlersMustReturnNormallyQuery() and
  queryId =
    // `@id` for the `exitHandlersMustReturnNormally` query
    "c/cert/exit-handlers-must-return-normally" and
  ruleId = "ENV32-C"
  or
  query =
    // `Query` instance for the `doNotStorePointersReturnedByCertainFunctions` query
    Contracts2Package::doNotStorePointersReturnedByCertainFunctionsQuery() and
  queryId =
    // `@id` for the `doNotStorePointersReturnedByCertainFunctions` query
    "c/cert/do-not-store-pointers-returned-by-certain-functions" and
  ruleId = "ENV34-C"
  or
  query =
    // `Query` instance for the `valuesReturnedByLocaleSettingUsedAsPtrToConst` query
    Contracts2Package::valuesReturnedByLocaleSettingUsedAsPtrToConstQuery() and
  queryId =
    // `@id` for the `valuesReturnedByLocaleSettingUsedAsPtrToConst` query
    "c/misra/values-returned-by-locale-setting-used-as-ptr-to-const" and
  ruleId = "RULE-21-19"
  or
  query =
    // `Query` instance for the `subsequentCallToSetlocaleInvalidatesOldPointers` query
    Contracts2Package::subsequentCallToSetlocaleInvalidatesOldPointersQuery() and
  queryId =
    // `@id` for the `subsequentCallToSetlocaleInvalidatesOldPointers` query
    "c/misra/subsequent-call-to-setlocale-invalidates-old-pointers" and
  ruleId = "RULE-21-20"
}

module Contracts2Package {
  Query exitHandlersMustReturnNormallyQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `exitHandlersMustReturnNormally` query
      TQueryC(TContracts2PackageQuery(TExitHandlersMustReturnNormallyQuery()))
  }

  Query doNotStorePointersReturnedByCertainFunctionsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `doNotStorePointersReturnedByCertainFunctions` query
      TQueryC(TContracts2PackageQuery(TDoNotStorePointersReturnedByCertainFunctionsQuery()))
  }

  Query valuesReturnedByLocaleSettingUsedAsPtrToConstQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `valuesReturnedByLocaleSettingUsedAsPtrToConst` query
      TQueryC(TContracts2PackageQuery(TValuesReturnedByLocaleSettingUsedAsPtrToConstQuery()))
  }

  Query subsequentCallToSetlocaleInvalidatesOldPointersQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `subsequentCallToSetlocaleInvalidatesOldPointers` query
      TQueryC(TContracts2PackageQuery(TSubsequentCallToSetlocaleInvalidatesOldPointersQuery()))
  }
}
