//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  **/
import cpp
import RuleMetadata
import codingstandards.cpp.exclusions.RuleMetadata

newtype OrderOfEvaluationQuery =
  TExpressionShouldNotRelyOnOrderOfEvaluationQuery() or
  TOperandsOfALogicalAndOrNotParenthesizedQuery() or
  TExplicitConstructionOfUnnamedTemporaryQuery() or
  TGratuitousUseOfParenthesesQuery() or
  TInsufficientUseOfParenthesesQuery() or
  TIncrementAndDecrementOperatorsMixedWithOtherOperatorsInExpressionQuery() or
  TAssignmentInSubExpressionQuery()

predicate isOrderOfEvaluationQueryMetadata(
  Query query, string queryId, string ruleId, string category
) {
  query =
    // `Query` instance for the `expressionShouldNotRelyOnOrderOfEvaluation` query
    OrderOfEvaluationPackage::expressionShouldNotRelyOnOrderOfEvaluationQuery() and
  queryId =
    // `@id` for the `expressionShouldNotRelyOnOrderOfEvaluation` query
    "cpp/autosar/expression-should-not-rely-on-order-of-evaluation" and
  ruleId = "A5-0-1" and
  category = "required"
  or
  query =
    // `Query` instance for the `operandsOfALogicalAndOrNotParenthesized` query
    OrderOfEvaluationPackage::operandsOfALogicalAndOrNotParenthesizedQuery() and
  queryId =
    // `@id` for the `operandsOfALogicalAndOrNotParenthesized` query
    "cpp/autosar/operands-of-a-logical-and-or-not-parenthesized" and
  ruleId = "A5-2-6" and
  category = "required"
  or
  query =
    // `Query` instance for the `explicitConstructionOfUnnamedTemporary` query
    OrderOfEvaluationPackage::explicitConstructionOfUnnamedTemporaryQuery() and
  queryId =
    // `@id` for the `explicitConstructionOfUnnamedTemporary` query
    "cpp/autosar/explicit-construction-of-unnamed-temporary" and
  ruleId = "A6-2-2" and
  category = "required"
  or
  query =
    // `Query` instance for the `gratuitousUseOfParentheses` query
    OrderOfEvaluationPackage::gratuitousUseOfParenthesesQuery() and
  queryId =
    // `@id` for the `gratuitousUseOfParentheses` query
    "cpp/autosar/gratuitous-use-of-parentheses" and
  ruleId = "M5-0-2" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `insufficientUseOfParentheses` query
    OrderOfEvaluationPackage::insufficientUseOfParenthesesQuery() and
  queryId =
    // `@id` for the `insufficientUseOfParentheses` query
    "cpp/autosar/insufficient-use-of-parentheses" and
  ruleId = "M5-0-2" and
  category = "advisory"
  or
  query =
    // `Query` instance for the `incrementAndDecrementOperatorsMixedWithOtherOperatorsInExpression` query
    OrderOfEvaluationPackage::incrementAndDecrementOperatorsMixedWithOtherOperatorsInExpressionQuery() and
  queryId =
    // `@id` for the `incrementAndDecrementOperatorsMixedWithOtherOperatorsInExpression` query
    "cpp/autosar/increment-and-decrement-operators-mixed-with-other-operators-in-expression" and
  ruleId = "M5-2-10" and
  category = "required"
  or
  query =
    // `Query` instance for the `assignmentInSubExpression` query
    OrderOfEvaluationPackage::assignmentInSubExpressionQuery() and
  queryId =
    // `@id` for the `assignmentInSubExpression` query
    "cpp/autosar/assignment-in-sub-expression" and
  ruleId = "M6-2-1" and
  category = "required"
}

module OrderOfEvaluationPackage {
  Query expressionShouldNotRelyOnOrderOfEvaluationQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `expressionShouldNotRelyOnOrderOfEvaluation` query
      TQueryCPP(TOrderOfEvaluationPackageQuery(TExpressionShouldNotRelyOnOrderOfEvaluationQuery()))
  }

  Query operandsOfALogicalAndOrNotParenthesizedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `operandsOfALogicalAndOrNotParenthesized` query
      TQueryCPP(TOrderOfEvaluationPackageQuery(TOperandsOfALogicalAndOrNotParenthesizedQuery()))
  }

  Query explicitConstructionOfUnnamedTemporaryQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `explicitConstructionOfUnnamedTemporary` query
      TQueryCPP(TOrderOfEvaluationPackageQuery(TExplicitConstructionOfUnnamedTemporaryQuery()))
  }

  Query gratuitousUseOfParenthesesQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `gratuitousUseOfParentheses` query
      TQueryCPP(TOrderOfEvaluationPackageQuery(TGratuitousUseOfParenthesesQuery()))
  }

  Query insufficientUseOfParenthesesQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `insufficientUseOfParentheses` query
      TQueryCPP(TOrderOfEvaluationPackageQuery(TInsufficientUseOfParenthesesQuery()))
  }

  Query incrementAndDecrementOperatorsMixedWithOtherOperatorsInExpressionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `incrementAndDecrementOperatorsMixedWithOtherOperatorsInExpression` query
      TQueryCPP(TOrderOfEvaluationPackageQuery(TIncrementAndDecrementOperatorsMixedWithOtherOperatorsInExpressionQuery()))
  }

  Query assignmentInSubExpressionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `assignmentInSubExpression` query
      TQueryCPP(TOrderOfEvaluationPackageQuery(TAssignmentInSubExpressionQuery()))
  }
}
