//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  */
import cpp
import RuleMetadata

newtype FunctionsQuery =
  TCStandardLibraryFunctionCallsQuery() or
  TTrivialAccessorAndMutatorFunctionsNotInlinedQuery() or
  TInvalidFunctionReturnTypeQuery() or
  TRecursiveFunctionsQuery() or
  TFunctionNoReturnAttributeConditionAutosarQuery() or
  TNonVoidFunctionDoesNotReturnAutosarQuery() or
  TFunctionReturnMultipleValueConditionQuery() or
  TAssmemblerInstructionsConditionQuery() or
  TAssemblyLanguageConditionQuery() or
  TFunctionReturnAutomaticVarConditionQuery() or
  TFunctionIdentifierConditionQuery() or
  TFunctionWithMismatchedLanguageLinkageQuery() or
  TNonVoidFunctionDoesNotReturnCertQuery() or
  TFunctionNoReturnAttributeConditionCertQuery()

predicate isFunctionsQueryMetadata(Query query, string queryId, string ruleId) {
  query =
    // `Query` instance for the `cStandardLibraryFunctionCalls` query
    FunctionsPackage::cStandardLibraryFunctionCallsQuery() and
  queryId =
    // `@id` for the `cStandardLibraryFunctionCalls` query
    "cpp/autosar/c-standard-library-function-calls" and
  ruleId = "A17-1-1"
  or
  query =
    // `Query` instance for the `trivialAccessorAndMutatorFunctionsNotInlined` query
    FunctionsPackage::trivialAccessorAndMutatorFunctionsNotInlinedQuery() and
  queryId =
    // `@id` for the `trivialAccessorAndMutatorFunctionsNotInlined` query
    "cpp/autosar/trivial-accessor-and-mutator-functions-not-inlined" and
  ruleId = "A3-1-6"
  or
  query =
    // `Query` instance for the `invalidFunctionReturnType` query
    FunctionsPackage::invalidFunctionReturnTypeQuery() and
  queryId =
    // `@id` for the `invalidFunctionReturnType` query
    "cpp/autosar/invalid-function-return-type" and
  ruleId = "A7-5-1"
  or
  query =
    // `Query` instance for the `recursiveFunctions` query
    FunctionsPackage::recursiveFunctionsQuery() and
  queryId =
    // `@id` for the `recursiveFunctions` query
    "cpp/autosar/recursive-functions" and
  ruleId = "A7-5-2"
  or
  query =
    // `Query` instance for the `functionNoReturnAttributeConditionAutosar` query
    FunctionsPackage::functionNoReturnAttributeConditionAutosarQuery() and
  queryId =
    // `@id` for the `functionNoReturnAttributeConditionAutosar` query
    "cpp/autosar/function-no-return-attribute-condition-autosar" and
  ruleId = "A7-6-1"
  or
  query =
    // `Query` instance for the `nonVoidFunctionDoesNotReturnAutosar` query
    FunctionsPackage::nonVoidFunctionDoesNotReturnAutosarQuery() and
  queryId =
    // `@id` for the `nonVoidFunctionDoesNotReturnAutosar` query
    "cpp/autosar/non-void-function-does-not-return-autosar" and
  ruleId = "A8-4-2"
  or
  query =
    // `Query` instance for the `functionReturnMultipleValueCondition` query
    FunctionsPackage::functionReturnMultipleValueConditionQuery() and
  queryId =
    // `@id` for the `functionReturnMultipleValueCondition` query
    "cpp/autosar/function-return-multiple-value-condition" and
  ruleId = "A8-4-4"
  or
  query =
    // `Query` instance for the `assmemblerInstructionsCondition` query
    FunctionsPackage::assmemblerInstructionsConditionQuery() and
  queryId =
    // `@id` for the `assmemblerInstructionsCondition` query
    "cpp/autosar/assmembler-instructions-condition" and
  ruleId = "M7-4-2"
  or
  query =
    // `Query` instance for the `assemblyLanguageCondition` query
    FunctionsPackage::assemblyLanguageConditionQuery() and
  queryId =
    // `@id` for the `assemblyLanguageCondition` query
    "cpp/autosar/assembly-language-condition" and
  ruleId = "M7-4-3"
  or
  query =
    // `Query` instance for the `functionReturnAutomaticVarCondition` query
    FunctionsPackage::functionReturnAutomaticVarConditionQuery() and
  queryId =
    // `@id` for the `functionReturnAutomaticVarCondition` query
    "cpp/autosar/function-return-automatic-var-condition" and
  ruleId = "M7-5-1"
  or
  query =
    // `Query` instance for the `functionIdentifierCondition` query
    FunctionsPackage::functionIdentifierConditionQuery() and
  queryId =
    // `@id` for the `functionIdentifierCondition` query
    "cpp/autosar/function-identifier-condition" and
  ruleId = "M8-4-4"
  or
  query =
    // `Query` instance for the `functionWithMismatchedLanguageLinkage` query
    FunctionsPackage::functionWithMismatchedLanguageLinkageQuery() and
  queryId =
    // `@id` for the `functionWithMismatchedLanguageLinkage` query
    "cpp/cert/function-with-mismatched-language-linkage" and
  ruleId = "EXP56-CPP"
  or
  query =
    // `Query` instance for the `nonVoidFunctionDoesNotReturnCert` query
    FunctionsPackage::nonVoidFunctionDoesNotReturnCertQuery() and
  queryId =
    // `@id` for the `nonVoidFunctionDoesNotReturnCert` query
    "cpp/cert/non-void-function-does-not-return-cert" and
  ruleId = "MSC52-CPP"
  or
  query =
    // `Query` instance for the `functionNoReturnAttributeConditionCert` query
    FunctionsPackage::functionNoReturnAttributeConditionCertQuery() and
  queryId =
    // `@id` for the `functionNoReturnAttributeConditionCert` query
    "cpp/cert/function-no-return-attribute-condition-cert" and
  ruleId = "MSC53-CPP"
}

module FunctionsPackage {
  Query cStandardLibraryFunctionCallsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `cStandardLibraryFunctionCalls` query
      TFunctionsPackageQuery(TCStandardLibraryFunctionCallsQuery())
  }

  Query trivialAccessorAndMutatorFunctionsNotInlinedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `trivialAccessorAndMutatorFunctionsNotInlined` query
      TFunctionsPackageQuery(TTrivialAccessorAndMutatorFunctionsNotInlinedQuery())
  }

  Query invalidFunctionReturnTypeQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `invalidFunctionReturnType` query
      TFunctionsPackageQuery(TInvalidFunctionReturnTypeQuery())
  }

  Query recursiveFunctionsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `recursiveFunctions` query
      TFunctionsPackageQuery(TRecursiveFunctionsQuery())
  }

  Query functionNoReturnAttributeConditionAutosarQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `functionNoReturnAttributeConditionAutosar` query
      TFunctionsPackageQuery(TFunctionNoReturnAttributeConditionAutosarQuery())
  }

  Query nonVoidFunctionDoesNotReturnAutosarQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `nonVoidFunctionDoesNotReturnAutosar` query
      TFunctionsPackageQuery(TNonVoidFunctionDoesNotReturnAutosarQuery())
  }

  Query functionReturnMultipleValueConditionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `functionReturnMultipleValueCondition` query
      TFunctionsPackageQuery(TFunctionReturnMultipleValueConditionQuery())
  }

  Query assmemblerInstructionsConditionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `assmemblerInstructionsCondition` query
      TFunctionsPackageQuery(TAssmemblerInstructionsConditionQuery())
  }

  Query assemblyLanguageConditionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `assemblyLanguageCondition` query
      TFunctionsPackageQuery(TAssemblyLanguageConditionQuery())
  }

  Query functionReturnAutomaticVarConditionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `functionReturnAutomaticVarCondition` query
      TFunctionsPackageQuery(TFunctionReturnAutomaticVarConditionQuery())
  }

  Query functionIdentifierConditionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `functionIdentifierCondition` query
      TFunctionsPackageQuery(TFunctionIdentifierConditionQuery())
  }

  Query functionWithMismatchedLanguageLinkageQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `functionWithMismatchedLanguageLinkage` query
      TFunctionsPackageQuery(TFunctionWithMismatchedLanguageLinkageQuery())
  }

  Query nonVoidFunctionDoesNotReturnCertQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `nonVoidFunctionDoesNotReturnCert` query
      TFunctionsPackageQuery(TNonVoidFunctionDoesNotReturnCertQuery())
  }

  Query functionNoReturnAttributeConditionCertQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `functionNoReturnAttributeConditionCert` query
      TFunctionsPackageQuery(TFunctionNoReturnAttributeConditionCertQuery())
  }
}
