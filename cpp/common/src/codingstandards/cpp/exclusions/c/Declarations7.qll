//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype Declarations7Query =
  TInformationLeakageAcrossTrustBoundariesCQuery() or
  TVariableLengthArrayTypesUsedQuery() or
  TValueImplicitEnumerationConstantNotUniqueQuery()

predicate isDeclarations7QueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `informationLeakageAcrossTrustBoundariesC` query
    Declarations7Package::informationLeakageAcrossTrustBoundariesCQuery() and
  queryId =
    // `@id` for the `informationLeakageAcrossTrustBoundariesC` query
    "c/cert/information-leakage-across-trust-boundaries-c" and
  ruleId = "DCL39-C" and
  category = "rule"
  or
  query =
    // `Query` instance for the `variableLengthArrayTypesUsed` query
    Declarations7Package::variableLengthArrayTypesUsedQuery() and
  queryId =
    // `@id` for the `variableLengthArrayTypesUsed` query
    "c/misra/variable-length-array-types-used" and
  ruleId = "RULE-18-8" and
  category = "required"
  or
  query =
    // `Query` instance for the `valueImplicitEnumerationConstantNotUnique` query
    Declarations7Package::valueImplicitEnumerationConstantNotUniqueQuery() and
  queryId =
    // `@id` for the `valueImplicitEnumerationConstantNotUnique` query
    "c/misra/value-implicit-enumeration-constant-not-unique" and
  ruleId = "RULE-8-12" and
  category = "required"
}

module Declarations7Package {
  Query informationLeakageAcrossTrustBoundariesCQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `informationLeakageAcrossTrustBoundariesC` query
      TQueryC(TDeclarations7PackageQuery(TInformationLeakageAcrossTrustBoundariesCQuery()))
  }

  Query variableLengthArrayTypesUsedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `variableLengthArrayTypesUsed` query
      TQueryC(TDeclarations7PackageQuery(TVariableLengthArrayTypesUsedQuery()))
  }

  Query valueImplicitEnumerationConstantNotUniqueQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `valueImplicitEnumerationConstantNotUnique` query
      TQueryC(TDeclarations7PackageQuery(TValueImplicitEnumerationConstantNotUniqueQuery()))
  }
}
