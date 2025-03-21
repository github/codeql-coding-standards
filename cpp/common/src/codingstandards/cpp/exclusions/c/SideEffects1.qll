//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype SideEffects1Query =
  TDependenceOnOrderOfScalarEvaluationForSideEffectsQuery() or
  TDependenceOnOrderOfFunctionArgumentsForSideEffectsQuery() or
  TUnevaluatedOperandWithSideEffectQuery() or
  TAssignmentsInSelectionStatementsQuery() or
  TUnenclosedSizeofOperandQuery() or
  TImplicitPrecedenceOfOperatorsInExpressionQuery() or
  TInitializerListsContainPersistentSideEffectsQuery() or
  TResultOfAnAssignmentOperatorShouldNotBeUsedQuery() or
  TPossibleSuppressedSideEffectInLogicOperatorOperandQuery() or
  TSizeofOperandWithSideEffectQuery()

predicate isSideEffects1QueryMetadata(Query query, string queryId, string ruleId, string category) {
  query =
    // `Query` instance for the `dependenceOnOrderOfScalarEvaluationForSideEffects` query
    SideEffects1Package::dependenceOnOrderOfScalarEvaluationForSideEffectsQuery() and
  queryId =
    // `@id` for the `dependenceOnOrderOfScalarEvaluationForSideEffects` query
    "c/cert/dependence-on-order-of-scalar-evaluation-for-side-effects" and
  ruleId = "EXP30-C" and
  category = "rule"
  or
  query =
    // `Query` instance for the `dependenceOnOrderOfFunctionArgumentsForSideEffects` query
    SideEffects1Package::dependenceOnOrderOfFunctionArgumentsForSideEffectsQuery() and
  queryId =
    // `@id` for the `dependenceOnOrderOfFunctionArgumentsForSideEffects` query
    "c/cert/dependence-on-order-of-function-arguments-for-side-effects" and
  ruleId = "EXP30-C" and
  category = "rule"
  or
  query =
    // `Query` instance for the `unevaluatedOperandWithSideEffect` query
    SideEffects1Package::unevaluatedOperandWithSideEffectQuery() and
  queryId =
    // `@id` for the `unevaluatedOperandWithSideEffect` query
    "c/cert/unevaluated-operand-with-side-effect" and
  ruleId = "EXP44-C" and
  category = "rule"
  or
  query =
    // `Query` instance for the `assignmentsInSelectionStatements` query
    SideEffects1Package::assignmentsInSelectionStatementsQuery() and
  queryId =
    // `@id` for the `assignmentsInSelectionStatements` query
    "c/cert/assignments-in-selection-statements" and
  ruleId = "EXP45-C" and
  category = "rule"
  or
  query =
    // `Query` instance for the `unenclosedSizeofOperand` query
    SideEffects1Package::unenclosedSizeofOperandQuery() and
  queryId =
    // `@id` for the `unenclosedSizeofOperand` query
    "c/misra/unenclosed-sizeof-operand" and
  ruleId = "RULE-12-1" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `implicitPrecedenceOfOperatorsInExpression` query
    SideEffects1Package::implicitPrecedenceOfOperatorsInExpressionQuery() and
  queryId =
    // `@id` for the `implicitPrecedenceOfOperatorsInExpression` query
    "c/misra/implicit-precedence-of-operators-in-expression" and
  ruleId = "RULE-12-1" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `initializerListsContainPersistentSideEffects` query
    SideEffects1Package::initializerListsContainPersistentSideEffectsQuery() and
  queryId =
    // `@id` for the `initializerListsContainPersistentSideEffects` query
    "c/misra/initializer-lists-contain-persistent-side-effects" and
  ruleId = "RULE-13-1" and
  category = "required"
  or
  query =
    // `Query` instance for the `resultOfAnAssignmentOperatorShouldNotBeUsed` query
    SideEffects1Package::resultOfAnAssignmentOperatorShouldNotBeUsedQuery() and
  queryId =
    // `@id` for the `resultOfAnAssignmentOperatorShouldNotBeUsed` query
    "c/misra/result-of-an-assignment-operator-should-not-be-used" and
  ruleId = "RULE-13-4" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `possibleSuppressedSideEffectInLogicOperatorOperand` query
    SideEffects1Package::possibleSuppressedSideEffectInLogicOperatorOperandQuery() and
  queryId =
    // `@id` for the `possibleSuppressedSideEffectInLogicOperatorOperand` query
    "c/misra/possible-suppressed-side-effect-in-logic-operator-operand" and
  ruleId = "RULE-13-5" and
  category = "required"
  or
  query =
    // `Query` instance for the `sizeofOperandWithSideEffect` query
    SideEffects1Package::sizeofOperandWithSideEffectQuery() and
  queryId =
    // `@id` for the `sizeofOperandWithSideEffect` query
    "c/misra/sizeof-operand-with-side-effect" and
  ruleId = "RULE-13-6" and
  category = "required"
}

module SideEffects1Package {
  Query dependenceOnOrderOfScalarEvaluationForSideEffectsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `dependenceOnOrderOfScalarEvaluationForSideEffects` query
      TQueryC(TSideEffects1PackageQuery(TDependenceOnOrderOfScalarEvaluationForSideEffectsQuery()))
  }

  Query dependenceOnOrderOfFunctionArgumentsForSideEffectsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `dependenceOnOrderOfFunctionArgumentsForSideEffects` query
      TQueryC(TSideEffects1PackageQuery(TDependenceOnOrderOfFunctionArgumentsForSideEffectsQuery()))
  }

  Query unevaluatedOperandWithSideEffectQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `unevaluatedOperandWithSideEffect` query
      TQueryC(TSideEffects1PackageQuery(TUnevaluatedOperandWithSideEffectQuery()))
  }

  Query assignmentsInSelectionStatementsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `assignmentsInSelectionStatements` query
      TQueryC(TSideEffects1PackageQuery(TAssignmentsInSelectionStatementsQuery()))
  }

  Query unenclosedSizeofOperandQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `unenclosedSizeofOperand` query
      TQueryC(TSideEffects1PackageQuery(TUnenclosedSizeofOperandQuery()))
  }

  Query implicitPrecedenceOfOperatorsInExpressionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `implicitPrecedenceOfOperatorsInExpression` query
      TQueryC(TSideEffects1PackageQuery(TImplicitPrecedenceOfOperatorsInExpressionQuery()))
  }

  Query initializerListsContainPersistentSideEffectsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `initializerListsContainPersistentSideEffects` query
      TQueryC(TSideEffects1PackageQuery(TInitializerListsContainPersistentSideEffectsQuery()))
  }

  Query resultOfAnAssignmentOperatorShouldNotBeUsedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `resultOfAnAssignmentOperatorShouldNotBeUsed` query
      TQueryC(TSideEffects1PackageQuery(TResultOfAnAssignmentOperatorShouldNotBeUsedQuery()))
  }

  Query possibleSuppressedSideEffectInLogicOperatorOperandQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `possibleSuppressedSideEffectInLogicOperatorOperand` query
      TQueryC(TSideEffects1PackageQuery(TPossibleSuppressedSideEffectInLogicOperatorOperandQuery()))
  }

  Query sizeofOperandWithSideEffectQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `sizeofOperandWithSideEffect` query
      TQueryC(TSideEffects1PackageQuery(TSizeofOperandWithSideEffectQuery()))
  }
}
