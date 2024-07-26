/**
 * A module for identifying uses of a `Type` within the source code.
 *
 * The strategy used within this module is to identify types directly used within the AST classes
 * represented in the databases - for example, `Type`s associated with variables, function return
 * types, casts/sizeofs, name qualifiers and so forth. A recursive approach is then used to unwrap
 * those types to determine which types are used transitively, such as base types, type arguments
 * and so forth.
 *
 * The analysis also makes some basic attempts to exclude type self references, to avoid marking a
 * type as "used" if it is only referenced from itself.
 */

import cpp

/**
 * Gets a typedef with the same qualified name and declared at the same location.
 *
 * A single typedef may occur in our database multiple times, if it is compiled into multiple
 * separate link targets with a different context. This predicate implements a hueristic for
 * identifying "equivalent" typedefs, so that we can say if one is "live", the others are live.
 */
pragma[noinline, nomagic]
private TypedefType getAnEquivalentTypeDef(TypedefType type) {
  // pragmas due to bad magic, bad inlining
  type.getQualifiedName() = result.getQualifiedName() and
  type.getLocation() = result.getLocation()
}

/**
 * Gets a meaningful use of `type` in the source code.
 *
 * This reports all the places in the source checkout root that the type was used, directly or
 * indirectly. The makes a basic attempt to exclude self-referential types where the only reference
 * is from within the function signature or field declaration of the type itself.
 */
Locatable getATypeUse(Type type) {
  result = getATypeUse_i(type, _)
  or
  // Identify `TypeMention`s of typedef types, where the underlying type is used.
  //
  // In principle, we shouldn't need to use `TypeMention` at all, because `getATypeUse_i` captures
  // all the AST structures which reference types. Unfortunately, there is one case where the AST
  // type structures don't capture full fidelity type information: type arguments of template
  // instantiations and specializations which are typedef'd types. Instead of the type argument
  // being represented as the typedef type, it is represented as the _underlying_ type. There is,
  // however, a type mention in the appropriate place for the typedef'd type. We therefore use
  // the TypeMention information in this one case only, restricting it to avoid largely duplicating
  // the work already determined as part of `getATypeUse_i`.
  //
  // For example, in:
  // ```
  // 1 | typedef X Y;
  // 2 | std::list<Y> x;
  // ```
  // The type of `x` is `std::list<X>` not `std::list<Y>`. There is, however a `TypeMention` of `Y`
  // on line 2, we determine `Y` is used
  exists(TypeMention tm, TypedefType typedefType |
    result = tm and
    type = getAnEquivalentTypeDef(typedefType) and
    tm.getMentionedType() = typedefType
  |
    exists(tm.getFile().getRelativePath()) and
    exists(getATypeUse_i(typedefType.getUnderlyingType(), _))
  )
}

private Locatable getATypeUse_i(Type type, string reason) {
  (
    // Restrict to uses within the source checkout root
    exists(result.getFile().getRelativePath())
    or
    // Unless it's an alias template instantiation, as they do not have correct locations (last
    // verified in CodeQL CLI 2.7.6)
    result instanceof UsingAliasTypedefType and
    not exists(result.getLocation())
  ) and
  (
    // Used as a variable type
    exists(Variable v | result = v |
      type = v.getType() and
      // Ignore self referential variables and parameters
      not v.getDeclaringType().refersTo(type) and
      not type = v.(Parameter).getFunction().getDeclaringType()
    ) and
    reason = "used as a variable type"
    or
    // Used a function return type
    exists(Function f |
      result = f and
      not f.isCompilerGenerated() and
      not type = f.getDeclaringType()
    |
      type = f.getType() and reason = "used as a function return type"
      or
      type = f.getATemplateArgument() and reason = "used as a function template argument"
    )
    or
    // Used either in a function call as a template argument, or as the declaring type
    // of the function
    exists(FunctionCall fc | result = fc |
      type = fc.getTarget().getDeclaringType() and reason = "used in call to member function"
      or
      type = fc.getATemplateArgument() and reason = "used in function call template argument"
    )
    or
    // Aliased in a user typedef
    exists(TypedefType t | result = t | type = t.getBaseType()) and
    reason = "aliased in user typedef"
    or
    // A use in a `FunctionAccess`
    exists(FunctionAccess fa | result = fa | type = fa.getTarget().getDeclaringType()) and
    reason = "used in a function accesses"
    or
    // A use in a `sizeof` expr
    exists(SizeofTypeOperator soto | result = soto | type = soto.getTypeOperand()) and
    reason = "used in a sizeof expr"
    or
    // A use in a `Cast`
    exists(Cast c | c = result | type = c.getType()) and
    reason = "used in a cast"
    or
    // Use of the type name in source
    exists(TypeName t | t = result | type = t.getType()) and
    reason = "used in a typename"
    or
    // Access of an enum constant
    exists(EnumConstantAccess eca | result = eca | type = eca.getTarget().getDeclaringEnum()) and
    reason = "used in an enum constant access"
    or
    // Accessing a field on the type
    exists(FieldAccess fa |
      result = fa and
      type = fa.getTarget().getDeclaringType()
    ) and
    reason = "used in a field access"
    or
    // Name qualifiers
    exists(NameQualifier nq |
      result = nq and
      type = nq.getQualifyingElement()
    ) and
    reason = "used in name qualifier"
    or
    // Temporary object creation of type `type`
    exists(TemporaryObjectExpr toe | result = toe | type = toe.getType()) and
    reason = "used in temporary object expr"
  )
  or
  // Recursive case - used by a used type
  exists(Type used | result = getATypeUse_i(used, _) |
    // The `used` class has `type` as a base class
    type = used.(DerivedType).getBaseType() and
    reason = "used in derived type"
    or
    // The `used` class has `type` as a template argument
    type = used.(Class).getATemplateArgument() and
    reason = "used in class template argument"
    or
    // A used class is derived from the type class
    type = used.(Class).getABaseClass() and
    reason = "used in derived class"
    or
    // This is a TemplateClass where one of the instantiations is used
    type.(TemplateClass).getAnInstantiation() = used and
    reason = "used in template class instantiation"
    or
    // This is a TemplateClass where one of the specializations is used
    type = used.(ClassTemplateSpecialization).getPrimaryTemplate() and
    reason = "used in template class specialization"
    or
    // Alias templates - alias templates and instantiations are not properly captured by the
    // extractor (last verified in CodeQL CLI 2.7.6). The only distinguishing factor is that
    // instantiations of alias templates do not have a location.
    exists(UsingAliasTypedefType template, UsingAliasTypedefType instantiation |
      // Instantiation is a "use" of the template
      used = instantiation and
      type = template and
      // The template has a location
      exists(template.getLocation()) and
      // The instantiation does not
      not exists(instantiation.getLocation()) and
      // Template and instantiation both have the same qualified name
      template.getQualifiedName() = instantiation.getQualifiedName()
    ) and
    reason = "used in alias template instantiation"
  )
}
