/**
 * @id cpp/autosar/non-template-member-defined-in-template
 * @name A14-5-2: Class members that are not dependent on template class parameters should be defined separately
 * @description Class members that are not dependent on template class parameters should be defined
 *              in a separate base class.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a14-5-2
 *       maintainability
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.TypeUses
import codingstandards.cpp.Operator

predicate templateDefinitionMentionsTypeParameter(Declaration d, TemplateParameter tp) {
  exists(Type t |
    (
      // direct reference, e.g., fields.
      t = d.getDefinition().getType()
      or
      // if it is a kind of typedef
      t = d.(TypedefType).getBaseType()
      or
      // if this is a class or enum, the class or enum's declaration
      t = classTemplateReferences(d.getDefinition().getType())
      or
      // the union of all references within a class
      // element
      t = classTemplateReferences(d)
      or
      // A reference inside an enum
      t = enumTemplateReferences(d)
      or
      // function return type
      t = functionTemplateReferences(d)
      or
      // per the standard, referencing an enum in the outer definition
      // is enough to count as a type reference even though we model
      // the individual enums within an enum as members.
      t = enumConstantTemplateReferences(d)
    ) and
    t.refersTo(tp)
  )
}

/**
 * The set of `TemplateParameter` references within an `Enum`.
 */
TemplateParameter enumTemplateReferences(Enum e) {
  templateDefinitionMentionsTypeParameter(e.getADeclaration(), result)
  or
  result = e.getExplicitUnderlyingType()
}

/**
 * The set of `TemplateParameter` references within an `Class`.
 */
TemplateParameter classTemplateReferences(Class c) {
  templateDefinitionMentionsTypeParameter(c.getAMember(), result)
  or
  c.getADerivation().getBaseType() = result
}

/**
 * The set of all of the `TemplateParameter`s referenced by a `EnumConstant`.
 */
TemplateParameter enumConstantTemplateReferences(EnumConstant ec) {
  templateDefinitionMentionsTypeParameter(ec.getDeclaringType(), result)
}

/**
 * The set of all `TemplateParameter`s referenced by a `Function`.
 */
TemplateParameter functionTemplateReferences(Function mf) {
  // the type of the function
  exists(TemplateParameter tp |
    result = tp and
    (
      mf.getType().refersTo(result)
      or
      // the parameters
      exists(Parameter p |
        p = mf.getAParameter() and
        p.getType().refersTo(result)
      )
      or
      // any normal definition within the function
      (
        exists(Declaration d |
          d.getParentScope*() = mf and
          templateDefinitionMentionsTypeParameter(d, result)
        )
        or
        exists(Expr e |
          e.getEnclosingFunction() = mf and
          e.getType().refersTo(result)
        )
        or
        // as a special case, we consider struts/classes within the template
        // function to not be members and instead look at the union
        // of all the types used within the struct/class
        exists(Class d |
          d.getEnclosingFunction() = mf and
          templateDefinitionMentionsTypeParameter(d.getAMember(), result)
        )
      )
    )
  )
}

/**
 * The set of all `TemplateParameters` available as arguments to the declaring
 * element of some `Declarations`.
 */
TemplateParameter templateParametersOfDeclaringTemplateClass(Declaration d) {
  result = d.getDeclaringType().getATemplateArgument()
}

/**
 * It is not enough to check if something is a `TemplateClass`. Within a nested
 * `TemplateClass` even plain classes are `TemplateClass`s. Since we wish to
 * not check each member of these classes it is necessary to look only for those
 * classes which have arguments.
 */
predicate declaredWithinTemplateClassWithParameters(Declaration d) {
  d.getDeclaringType() instanceof TemplateClass and
  exists(d.getDeclaringType().getATemplateArgument()) and
  // do not report all of the instantiations
  not d.isFromTemplateInstantiation(_)
}

from Declaration d
where
  not isExcluded(d, ClassesPackage::nonTemplateMemberDefinedInTemplateQuery()) and
  // only examine members of template
  // classes
  declaredWithinTemplateClassWithParameters(d) and
  //
  // Omit special functions
  not d instanceof UserAssignmentOperator and
  not d instanceof Constructor and
  not d instanceof Destructor and
  not d instanceof UserNegationOperator and
  // for each declaration within a template class get the
  // template parameters of the declaring class
  not exists(TemplateParameter t |
    t = templateParametersOfDeclaringTemplateClass(d) and
    // and require that the declaration depends on at least
    // one of those template parameters.
    templateDefinitionMentionsTypeParameter(d, t)
  ) and
  // Only report functions which have a body, as otherwise we cannot tell if they depend on the
  // template parameter or not
  (d instanceof Function implies exists(d.(Function).getBlock())) and
  // Only report classes where all the non-compiler generated functions have bodies
  (
    d instanceof Class
    implies
    exists(Class c | c = d |
      not exists(MemberFunction mf |
        mf = c.getAMemberFunction() and not mf.isCompilerGenerated() and not exists(mf.getBlock())
      )
    )
  )
select d,
  "Member " + d.getName() + " template class does not use any of template arguments of its $@.",
  d.getDeclaringType(), "declaring type"
