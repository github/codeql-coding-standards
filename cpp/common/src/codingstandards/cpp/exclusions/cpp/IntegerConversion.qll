//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype IntegerConversionQuery =
  TIntegerExpressionLeadToDataLossQuery() or
  TIntMultToLongQuery() or
  TImplicitChangeOfTheSignednessOfTheUnderlyingTypeQuery() or
  TImplicitNonConstFloatingIntegralConversionQuery() or
  TImplicitConstFloatingIntegralConversionQuery() or
  TImplicitNonConstConversionToSmallerUnderlyingTypeQuery() or
  TImplicitConstConversionToSmallerUnderlyingTypeQuery() or
  TExplicitFloatingIntegralConversionOfACValueExprQuery() or
  TExplicitWideningConversionOfACValueExprQuery() or
  TExplicitSignednessConversionOfCValueQuery()

predicate isIntegerConversionQueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `integerExpressionLeadToDataLoss` query
    IntegerConversionPackage::integerExpressionLeadToDataLossQuery() and
  queryId =
    // `@id` for the `integerExpressionLeadToDataLoss` query
    "cpp/autosar/integer-expression-lead-to-data-loss" and
  ruleId = "A4-7-1" and
  category = "required"
  or
  query =
    // `Query` instance for the `intMultToLong` query
    IntegerConversionPackage::intMultToLongQuery() and
  queryId =
    // `@id` for the `intMultToLong` query
    "cpp/autosar/int-mult-to-long" and
  ruleId = "A4-7-1" and
  category = "required"
  or
  query =
    // `Query` instance for the `implicitChangeOfTheSignednessOfTheUnderlyingType` query
    IntegerConversionPackage::implicitChangeOfTheSignednessOfTheUnderlyingTypeQuery() and
  queryId =
    // `@id` for the `implicitChangeOfTheSignednessOfTheUnderlyingType` query
    "cpp/autosar/implicit-change-of-the-signedness-of-the-underlying-type" and
  ruleId = "M5-0-4" and
  category = "required"
  or
  query =
    // `Query` instance for the `implicitNonConstFloatingIntegralConversion` query
    IntegerConversionPackage::implicitNonConstFloatingIntegralConversionQuery() and
  queryId =
    // `@id` for the `implicitNonConstFloatingIntegralConversion` query
    "cpp/autosar/implicit-non-const-floating-integral-conversion" and
  ruleId = "M5-0-5" and
  category = "required"
  or
  query =
    // `Query` instance for the `implicitConstFloatingIntegralConversion` query
    IntegerConversionPackage::implicitConstFloatingIntegralConversionQuery() and
  queryId =
    // `@id` for the `implicitConstFloatingIntegralConversion` query
    "cpp/autosar/implicit-const-floating-integral-conversion" and
  ruleId = "M5-0-5" and
  category = "required"
  or
  query =
    // `Query` instance for the `implicitNonConstConversionToSmallerUnderlyingType` query
    IntegerConversionPackage::implicitNonConstConversionToSmallerUnderlyingTypeQuery() and
  queryId =
    // `@id` for the `implicitNonConstConversionToSmallerUnderlyingType` query
    "cpp/autosar/implicit-non-const-conversion-to-smaller-underlying-type" and
  ruleId = "M5-0-6" and
  category = "required"
  or
  query =
    // `Query` instance for the `implicitConstConversionToSmallerUnderlyingType` query
    IntegerConversionPackage::implicitConstConversionToSmallerUnderlyingTypeQuery() and
  queryId =
    // `@id` for the `implicitConstConversionToSmallerUnderlyingType` query
    "cpp/autosar/implicit-const-conversion-to-smaller-underlying-type" and
  ruleId = "M5-0-6" and
  category = "required"
  or
  query =
    // `Query` instance for the `explicitFloatingIntegralConversionOfACValueExpr` query
    IntegerConversionPackage::explicitFloatingIntegralConversionOfACValueExprQuery() and
  queryId =
    // `@id` for the `explicitFloatingIntegralConversionOfACValueExpr` query
    "cpp/autosar/explicit-floating-integral-conversion-of-ac-value-expr" and
  ruleId = "M5-0-7" and
  category = "required"
  or
  query =
    // `Query` instance for the `explicitWideningConversionOfACValueExpr` query
    IntegerConversionPackage::explicitWideningConversionOfACValueExprQuery() and
  queryId =
    // `@id` for the `explicitWideningConversionOfACValueExpr` query
    "cpp/autosar/explicit-widening-conversion-of-ac-value-expr" and
  ruleId = "M5-0-8" and
  category = "required"
  or
  query =
    // `Query` instance for the `explicitSignednessConversionOfCValue` query
    IntegerConversionPackage::explicitSignednessConversionOfCValueQuery() and
  queryId =
    // `@id` for the `explicitSignednessConversionOfCValue` query
    "cpp/autosar/explicit-signedness-conversion-of-c-value" and
  ruleId = "M5-0-9" and
  category = "required"
}

module IntegerConversionPackage {
  Query integerExpressionLeadToDataLossQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `integerExpressionLeadToDataLoss` query
      TQueryCPP(TIntegerConversionPackageQuery(TIntegerExpressionLeadToDataLossQuery()))
  }

  Query intMultToLongQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `intMultToLong` query
      TQueryCPP(TIntegerConversionPackageQuery(TIntMultToLongQuery()))
  }

  Query implicitChangeOfTheSignednessOfTheUnderlyingTypeQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `implicitChangeOfTheSignednessOfTheUnderlyingType` query
      TQueryCPP(TIntegerConversionPackageQuery(TImplicitChangeOfTheSignednessOfTheUnderlyingTypeQuery()))
  }

  Query implicitNonConstFloatingIntegralConversionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `implicitNonConstFloatingIntegralConversion` query
      TQueryCPP(TIntegerConversionPackageQuery(TImplicitNonConstFloatingIntegralConversionQuery()))
  }

  Query implicitConstFloatingIntegralConversionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `implicitConstFloatingIntegralConversion` query
      TQueryCPP(TIntegerConversionPackageQuery(TImplicitConstFloatingIntegralConversionQuery()))
  }

  Query implicitNonConstConversionToSmallerUnderlyingTypeQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `implicitNonConstConversionToSmallerUnderlyingType` query
      TQueryCPP(TIntegerConversionPackageQuery(TImplicitNonConstConversionToSmallerUnderlyingTypeQuery()))
  }

  Query implicitConstConversionToSmallerUnderlyingTypeQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `implicitConstConversionToSmallerUnderlyingType` query
      TQueryCPP(TIntegerConversionPackageQuery(TImplicitConstConversionToSmallerUnderlyingTypeQuery()))
  }

  Query explicitFloatingIntegralConversionOfACValueExprQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `explicitFloatingIntegralConversionOfACValueExpr` query
      TQueryCPP(TIntegerConversionPackageQuery(TExplicitFloatingIntegralConversionOfACValueExprQuery()))
  }

  Query explicitWideningConversionOfACValueExprQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `explicitWideningConversionOfACValueExpr` query
      TQueryCPP(TIntegerConversionPackageQuery(TExplicitWideningConversionOfACValueExprQuery()))
  }

  Query explicitSignednessConversionOfCValueQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `explicitSignednessConversionOfCValue` query
      TQueryCPP(TIntegerConversionPackageQuery(TExplicitSignednessConversionOfCValueQuery()))
  }
}
