//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  */
import cpp
import RuleMetadata

newtype TemplatesQuery =
  TTemplateShouldCheckArgQuery() or
  TTemplateConstructorOverloadResolutionQuery() or
  TTypeUsedAsTemplateArgShallProvideAllMembersQuery() or
  TTemplateSpecializationNotDeclaredInTheSameFileQuery() or
  TExplicitSpecializationsOfFunctionTemplatesUsedQuery() or
  TCopyAssignmentOperatorNotDeclaredQuery() or
  TNameNotReferredUsingAQualifiedIdOrThisQuery() or
  TNameNotReferredUsingAQualifiedIdOrThisAuditQuery()

predicate isTemplatesQueryMetadata(Query query, string queryId, string ruleId) {
  query =
    // `Query` instance for the `templateShouldCheckArg` query
    TemplatesPackage::templateShouldCheckArgQuery() and
  queryId =
    // `@id` for the `templateShouldCheckArg` query
    "cpp/autosar/template-should-check-arg" and
  ruleId = "A14-1-1"
  or
  query =
    // `Query` instance for the `templateConstructorOverloadResolution` query
    TemplatesPackage::templateConstructorOverloadResolutionQuery() and
  queryId =
    // `@id` for the `templateConstructorOverloadResolution` query
    "cpp/autosar/template-constructor-overload-resolution" and
  ruleId = "A14-5-1"
  or
  query =
    // `Query` instance for the `typeUsedAsTemplateArgShallProvideAllMembers` query
    TemplatesPackage::typeUsedAsTemplateArgShallProvideAllMembersQuery() and
  queryId =
    // `@id` for the `typeUsedAsTemplateArgShallProvideAllMembers` query
    "cpp/autosar/type-used-as-template-arg-shall-provide-all-members" and
  ruleId = "A14-7-1"
  or
  query =
    // `Query` instance for the `templateSpecializationNotDeclaredInTheSameFile` query
    TemplatesPackage::templateSpecializationNotDeclaredInTheSameFileQuery() and
  queryId =
    // `@id` for the `templateSpecializationNotDeclaredInTheSameFile` query
    "cpp/autosar/template-specialization-not-declared-in-the-same-file" and
  ruleId = "A14-7-2"
  or
  query =
    // `Query` instance for the `explicitSpecializationsOfFunctionTemplatesUsed` query
    TemplatesPackage::explicitSpecializationsOfFunctionTemplatesUsedQuery() and
  queryId =
    // `@id` for the `explicitSpecializationsOfFunctionTemplatesUsed` query
    "cpp/autosar/explicit-specializations-of-function-templates-used" and
  ruleId = "A14-8-2"
  or
  query =
    // `Query` instance for the `copyAssignmentOperatorNotDeclared` query
    TemplatesPackage::copyAssignmentOperatorNotDeclaredQuery() and
  queryId =
    // `@id` for the `copyAssignmentOperatorNotDeclared` query
    "cpp/autosar/copy-assignment-operator-not-declared" and
  ruleId = "M14-5-3"
  or
  query =
    // `Query` instance for the `nameNotReferredUsingAQualifiedIdOrThis` query
    TemplatesPackage::nameNotReferredUsingAQualifiedIdOrThisQuery() and
  queryId =
    // `@id` for the `nameNotReferredUsingAQualifiedIdOrThis` query
    "cpp/autosar/name-not-referred-using-a-qualified-id-or-this" and
  ruleId = "M14-6-1"
  or
  query =
    // `Query` instance for the `nameNotReferredUsingAQualifiedIdOrThisAudit` query
    TemplatesPackage::nameNotReferredUsingAQualifiedIdOrThisAuditQuery() and
  queryId =
    // `@id` for the `nameNotReferredUsingAQualifiedIdOrThisAudit` query
    "cpp/autosar/name-not-referred-using-a-qualified-id-or-this-audit" and
  ruleId = "M14-6-1"
}

module TemplatesPackage {
  Query templateShouldCheckArgQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `templateShouldCheckArg` query
      TTemplatesPackageQuery(TTemplateShouldCheckArgQuery())
  }

  Query templateConstructorOverloadResolutionQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `templateConstructorOverloadResolution` query
      TTemplatesPackageQuery(TTemplateConstructorOverloadResolutionQuery())
  }

  Query typeUsedAsTemplateArgShallProvideAllMembersQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `typeUsedAsTemplateArgShallProvideAllMembers` query
      TTemplatesPackageQuery(TTypeUsedAsTemplateArgShallProvideAllMembersQuery())
  }

  Query templateSpecializationNotDeclaredInTheSameFileQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `templateSpecializationNotDeclaredInTheSameFile` query
      TTemplatesPackageQuery(TTemplateSpecializationNotDeclaredInTheSameFileQuery())
  }

  Query explicitSpecializationsOfFunctionTemplatesUsedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `explicitSpecializationsOfFunctionTemplatesUsed` query
      TTemplatesPackageQuery(TExplicitSpecializationsOfFunctionTemplatesUsedQuery())
  }

  Query copyAssignmentOperatorNotDeclaredQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `copyAssignmentOperatorNotDeclared` query
      TTemplatesPackageQuery(TCopyAssignmentOperatorNotDeclaredQuery())
  }

  Query nameNotReferredUsingAQualifiedIdOrThisQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `nameNotReferredUsingAQualifiedIdOrThis` query
      TTemplatesPackageQuery(TNameNotReferredUsingAQualifiedIdOrThisQuery())
  }

  Query nameNotReferredUsingAQualifiedIdOrThisAuditQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `nameNotReferredUsingAQualifiedIdOrThisAudit` query
      TTemplatesPackageQuery(TNameNotReferredUsingAQualifiedIdOrThisAuditQuery())
  }
}
