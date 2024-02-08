//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype ConstQuery =
  TRemoveConstOrVolatileQualificationAutosarQuery() or
  TDeclarationUnmodifiedObjectMissingConstSpecifierQuery() or
  TVariableMissingConstexprQuery() or
  TFunctionMissingConstexprQuery() or
  TCvQualifiersNotPlacedOnTheRightHandSideQuery() or
  TOutputParametersUsedQuery() or
  TInOutParametersDeclaredAsTNotModifiedQuery() or
  TPointerOrReferenceParameterToConstQuery() or
  TConstMemberFunctionReturnsNonConstPointerQuery() or
  TMemberFunctionStaticIfPossibleQuery() or
  TMemberFunctionConstIfPossibleQuery() or
  TRemoveConstOrVolatileQualificationCertQuery()

predicate isConstQueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `removeConstOrVolatileQualificationAutosar` query
    ConstPackage::removeConstOrVolatileQualificationAutosarQuery() and
  queryId =
    // `@id` for the `removeConstOrVolatileQualificationAutosar` query
    "cpp/autosar/remove-const-or-volatile-qualification-autosar" and
  ruleId = "A5-2-3" and
  category = "required"
  or
  query =
    // `Query` instance for the `declarationUnmodifiedObjectMissingConstSpecifier` query
    ConstPackage::declarationUnmodifiedObjectMissingConstSpecifierQuery() and
  queryId =
    // `@id` for the `declarationUnmodifiedObjectMissingConstSpecifier` query
    "cpp/autosar/declaration-unmodified-object-missing-const-specifier" and
  ruleId = "A7-1-1" and
  category = "required"
  or
  query =
    // `Query` instance for the `variableMissingConstexpr` query
    ConstPackage::variableMissingConstexprQuery() and
  queryId =
    // `@id` for the `variableMissingConstexpr` query
    "cpp/autosar/variable-missing-constexpr" and
  ruleId = "A7-1-2" and
  category = "required"
  or
  query =
    // `Query` instance for the `functionMissingConstexpr` query
    ConstPackage::functionMissingConstexprQuery() and
  queryId =
    // `@id` for the `functionMissingConstexpr` query
    "cpp/autosar/function-missing-constexpr" and
  ruleId = "A7-1-2" and
  category = "required"
  or
  query =
    // `Query` instance for the `cvQualifiersNotPlacedOnTheRightHandSide` query
    ConstPackage::cvQualifiersNotPlacedOnTheRightHandSideQuery() and
  queryId =
    // `@id` for the `cvQualifiersNotPlacedOnTheRightHandSide` query
    "cpp/autosar/cv-qualifiers-not-placed-on-the-right-hand-side" and
  ruleId = "A7-1-3" and
  category = "required"
  or
  query =
    // `Query` instance for the `outputParametersUsed` query
    ConstPackage::outputParametersUsedQuery() and
  queryId =
    // `@id` for the `outputParametersUsed` query
    "cpp/autosar/output-parameters-used" and
  ruleId = "A8-4-8" and
  category = "required"
  or
  query =
    // `Query` instance for the `inOutParametersDeclaredAsTNotModified` query
    ConstPackage::inOutParametersDeclaredAsTNotModifiedQuery() and
  queryId =
    // `@id` for the `inOutParametersDeclaredAsTNotModified` query
    "cpp/autosar/in-out-parameters-declared-as-t-not-modified" and
  ruleId = "A8-4-9" and
  category = "required"
  or
  query =
    // `Query` instance for the `pointerOrReferenceParameterToConst` query
    ConstPackage::pointerOrReferenceParameterToConstQuery() and
  queryId =
    // `@id` for the `pointerOrReferenceParameterToConst` query
    "cpp/autosar/pointer-or-reference-parameter-to-const" and
  ruleId = "M7-1-2" and
  category = "required"
  or
  query =
    // `Query` instance for the `constMemberFunctionReturnsNonConstPointer` query
    ConstPackage::constMemberFunctionReturnsNonConstPointerQuery() and
  queryId =
    // `@id` for the `constMemberFunctionReturnsNonConstPointer` query
    "cpp/autosar/const-member-function-returns-non-const-pointer" and
  ruleId = "M9-3-1" and
  category = "required"
  or
  query =
    // `Query` instance for the `memberFunctionStaticIfPossible` query
    ConstPackage::memberFunctionStaticIfPossibleQuery() and
  queryId =
    // `@id` for the `memberFunctionStaticIfPossible` query
    "cpp/autosar/member-function-static-if-possible" and
  ruleId = "M9-3-3" and
  category = "required"
  or
  query =
    // `Query` instance for the `memberFunctionConstIfPossible` query
    ConstPackage::memberFunctionConstIfPossibleQuery() and
  queryId =
    // `@id` for the `memberFunctionConstIfPossible` query
    "cpp/autosar/member-function-const-if-possible" and
  ruleId = "M9-3-3" and
  category = "required"
  or
  query =
    // `Query` instance for the `removeConstOrVolatileQualificationCert` query
    ConstPackage::removeConstOrVolatileQualificationCertQuery() and
  queryId =
    // `@id` for the `removeConstOrVolatileQualificationCert` query
    "cpp/cert/remove-const-or-volatile-qualification-cert" and
  ruleId = "EXP55-CPP" and
  category = "rule"
}

module ConstPackage {
  Query removeConstOrVolatileQualificationAutosarQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `removeConstOrVolatileQualificationAutosar` query
      TQueryCPP(TConstPackageQuery(TRemoveConstOrVolatileQualificationAutosarQuery()))
  }

  Query declarationUnmodifiedObjectMissingConstSpecifierQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `declarationUnmodifiedObjectMissingConstSpecifier` query
      TQueryCPP(TConstPackageQuery(TDeclarationUnmodifiedObjectMissingConstSpecifierQuery()))
  }

  Query variableMissingConstexprQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `variableMissingConstexpr` query
      TQueryCPP(TConstPackageQuery(TVariableMissingConstexprQuery()))
  }

  Query functionMissingConstexprQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `functionMissingConstexpr` query
      TQueryCPP(TConstPackageQuery(TFunctionMissingConstexprQuery()))
  }

  Query cvQualifiersNotPlacedOnTheRightHandSideQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `cvQualifiersNotPlacedOnTheRightHandSide` query
      TQueryCPP(TConstPackageQuery(TCvQualifiersNotPlacedOnTheRightHandSideQuery()))
  }

  Query outputParametersUsedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `outputParametersUsed` query
      TQueryCPP(TConstPackageQuery(TOutputParametersUsedQuery()))
  }

  Query inOutParametersDeclaredAsTNotModifiedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `inOutParametersDeclaredAsTNotModified` query
      TQueryCPP(TConstPackageQuery(TInOutParametersDeclaredAsTNotModifiedQuery()))
  }

  Query pointerOrReferenceParameterToConstQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `pointerOrReferenceParameterToConst` query
      TQueryCPP(TConstPackageQuery(TPointerOrReferenceParameterToConstQuery()))
  }

  Query constMemberFunctionReturnsNonConstPointerQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `constMemberFunctionReturnsNonConstPointer` query
      TQueryCPP(TConstPackageQuery(TConstMemberFunctionReturnsNonConstPointerQuery()))
  }

  Query memberFunctionStaticIfPossibleQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `memberFunctionStaticIfPossible` query
      TQueryCPP(TConstPackageQuery(TMemberFunctionStaticIfPossibleQuery()))
  }

  Query memberFunctionConstIfPossibleQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `memberFunctionConstIfPossible` query
      TQueryCPP(TConstPackageQuery(TMemberFunctionConstIfPossibleQuery()))
  }

  Query removeConstOrVolatileQualificationCertQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `removeConstOrVolatileQualificationCert` query
      TQueryCPP(TConstPackageQuery(TRemoveConstOrVolatileQualificationCertQuery()))
  }
}
