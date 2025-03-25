//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype GenericsQuery =
  TGenericSelectionNotExpandedFromAMacroQuery() or
  TGenericSelectionDoesntDependOnMacroArgumentQuery() or
  TGenericSelectionNotFromMacroWithSideEffectsQuery() or
  TGenericWithoutNonDefaultAssociationQuery() or
  TGenericAssociationWithUnselectableTypeQuery() or
  TDangerousDefaultSelectionForPointerInGenericQuery() or
  TGenericExpressionWithIncorrectEssentialTypeQuery() or
  TInvalidGenericMacroArgumentEvaluationQuery() or
  TDefaultGenericSelectionNotFirstOrLastQuery()

predicate isGenericsQueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `genericSelectionNotExpandedFromAMacro` query
    GenericsPackage::genericSelectionNotExpandedFromAMacroQuery() and
  queryId =
    // `@id` for the `genericSelectionNotExpandedFromAMacro` query
    "c/misra/generic-selection-not-expanded-from-a-macro" and
  ruleId = "RULE-23-1" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `genericSelectionDoesntDependOnMacroArgument` query
    GenericsPackage::genericSelectionDoesntDependOnMacroArgumentQuery() and
  queryId =
    // `@id` for the `genericSelectionDoesntDependOnMacroArgument` query
    "c/misra/generic-selection-doesnt-depend-on-macro-argument" and
  ruleId = "RULE-23-1" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `genericSelectionNotFromMacroWithSideEffects` query
    GenericsPackage::genericSelectionNotFromMacroWithSideEffectsQuery() and
  queryId =
    // `@id` for the `genericSelectionNotFromMacroWithSideEffects` query
    "c/misra/generic-selection-not-from-macro-with-side-effects" and
  ruleId = "RULE-23-2" and
  category = "required"
  or
  query =
    // `Query` instance for the `genericWithoutNonDefaultAssociation` query
    GenericsPackage::genericWithoutNonDefaultAssociationQuery() and
  queryId =
    // `@id` for the `genericWithoutNonDefaultAssociation` query
    "c/misra/generic-without-non-default-association" and
  ruleId = "RULE-23-3" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `genericAssociationWithUnselectableType` query
    GenericsPackage::genericAssociationWithUnselectableTypeQuery() and
  queryId =
    // `@id` for the `genericAssociationWithUnselectableType` query
    "c/misra/generic-association-with-unselectable-type" and
  ruleId = "RULE-23-4" and
  category = "required"
  or
  query =
    // `Query` instance for the `dangerousDefaultSelectionForPointerInGeneric` query
    GenericsPackage::dangerousDefaultSelectionForPointerInGenericQuery() and
  queryId =
    // `@id` for the `dangerousDefaultSelectionForPointerInGeneric` query
    "c/misra/dangerous-default-selection-for-pointer-in-generic" and
  ruleId = "RULE-23-5" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `genericExpressionWithIncorrectEssentialType` query
    GenericsPackage::genericExpressionWithIncorrectEssentialTypeQuery() and
  queryId =
    // `@id` for the `genericExpressionWithIncorrectEssentialType` query
    "c/misra/generic-expression-with-incorrect-essential-type" and
  ruleId = "RULE-23-6" and
  category = "required"
  or
  query =
    // `Query` instance for the `invalidGenericMacroArgumentEvaluation` query
    GenericsPackage::invalidGenericMacroArgumentEvaluationQuery() and
  queryId =
    // `@id` for the `invalidGenericMacroArgumentEvaluation` query
    "c/misra/invalid-generic-macro-argument-evaluation" and
  ruleId = "RULE-23-7" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `defaultGenericSelectionNotFirstOrLast` query
    GenericsPackage::defaultGenericSelectionNotFirstOrLastQuery() and
  queryId =
    // `@id` for the `defaultGenericSelectionNotFirstOrLast` query
    "c/misra/default-generic-selection-not-first-or-last" and
  ruleId = "RULE-23-8" and
  category = "required"
}

module GenericsPackage {
  Query genericSelectionNotExpandedFromAMacroQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `genericSelectionNotExpandedFromAMacro` query
      TQueryC(TGenericsPackageQuery(TGenericSelectionNotExpandedFromAMacroQuery()))
  }

  Query genericSelectionDoesntDependOnMacroArgumentQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `genericSelectionDoesntDependOnMacroArgument` query
      TQueryC(TGenericsPackageQuery(TGenericSelectionDoesntDependOnMacroArgumentQuery()))
  }

  Query genericSelectionNotFromMacroWithSideEffectsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `genericSelectionNotFromMacroWithSideEffects` query
      TQueryC(TGenericsPackageQuery(TGenericSelectionNotFromMacroWithSideEffectsQuery()))
  }

  Query genericWithoutNonDefaultAssociationQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `genericWithoutNonDefaultAssociation` query
      TQueryC(TGenericsPackageQuery(TGenericWithoutNonDefaultAssociationQuery()))
  }

  Query genericAssociationWithUnselectableTypeQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `genericAssociationWithUnselectableType` query
      TQueryC(TGenericsPackageQuery(TGenericAssociationWithUnselectableTypeQuery()))
  }

  Query dangerousDefaultSelectionForPointerInGenericQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `dangerousDefaultSelectionForPointerInGeneric` query
      TQueryC(TGenericsPackageQuery(TDangerousDefaultSelectionForPointerInGenericQuery()))
  }

  Query genericExpressionWithIncorrectEssentialTypeQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `genericExpressionWithIncorrectEssentialType` query
      TQueryC(TGenericsPackageQuery(TGenericExpressionWithIncorrectEssentialTypeQuery()))
  }

  Query invalidGenericMacroArgumentEvaluationQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `invalidGenericMacroArgumentEvaluation` query
      TQueryC(TGenericsPackageQuery(TInvalidGenericMacroArgumentEvaluationQuery()))
  }

  Query defaultGenericSelectionNotFirstOrLastQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `defaultGenericSelectionNotFirstOrLast` query
      TQueryC(TGenericsPackageQuery(TDefaultGenericSelectionNotFirstOrLastQuery()))
  }
}
