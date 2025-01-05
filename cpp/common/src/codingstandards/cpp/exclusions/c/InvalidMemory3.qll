//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype InvalidMemory3Query =
  TPointersToVariablyModifiedArrayTypesUsedQuery() or
  TArrayToPointerConversionOfTemporaryObjectQuery() or
  TModifiableLValueSubscriptedWithTemporaryLifetimeQuery()

predicate isInvalidMemory3QueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `pointersToVariablyModifiedArrayTypesUsed` query
    InvalidMemory3Package::pointersToVariablyModifiedArrayTypesUsedQuery() and
  queryId =
    // `@id` for the `pointersToVariablyModifiedArrayTypesUsed` query
    "c/misra/pointers-to-variably-modified-array-types-used" and
  ruleId = "RULE-18-10" and
  category = "mandatory"
  or
  query =
    // `Query` instance for the `arrayToPointerConversionOfTemporaryObject` query
    InvalidMemory3Package::arrayToPointerConversionOfTemporaryObjectQuery() and
  queryId =
    // `@id` for the `arrayToPointerConversionOfTemporaryObject` query
    "c/misra/array-to-pointer-conversion-of-temporary-object" and
  ruleId = "RULE-18-9" and
  category = "required"
  or
  query =
    // `Query` instance for the `modifiableLValueSubscriptedWithTemporaryLifetime` query
    InvalidMemory3Package::modifiableLValueSubscriptedWithTemporaryLifetimeQuery() and
  queryId =
    // `@id` for the `modifiableLValueSubscriptedWithTemporaryLifetime` query
    "c/misra/modifiable-l-value-subscripted-with-temporary-lifetime" and
  ruleId = "RULE-18-9" and
  category = "required"
}

module InvalidMemory3Package {
  Query pointersToVariablyModifiedArrayTypesUsedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `pointersToVariablyModifiedArrayTypesUsed` query
      TQueryC(TInvalidMemory3PackageQuery(TPointersToVariablyModifiedArrayTypesUsedQuery()))
  }

  Query arrayToPointerConversionOfTemporaryObjectQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `arrayToPointerConversionOfTemporaryObject` query
      TQueryC(TInvalidMemory3PackageQuery(TArrayToPointerConversionOfTemporaryObjectQuery()))
  }

  Query modifiableLValueSubscriptedWithTemporaryLifetimeQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `modifiableLValueSubscriptedWithTemporaryLifetime` query
      TQueryC(TInvalidMemory3PackageQuery(TModifiableLValueSubscriptedWithTemporaryLifetimeQuery()))
  }
}
