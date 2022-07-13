/**
 * This module adds support for the type categories specified in the "Lifetime profile" paper
 * (v1.1, Herb Sutter 2019).
 *
 * The definitions we've chosen for each category have been modified based on experimentation with
 * real world codebases. Most notably we use simplified versions of container and iterator type
 * requirements to capture more real world cases.
 *
 * We also support the explicit annotations `[[gsl::Owner]]`, `[[gsl::Pointer]]` and
 * `[[gsl::SharedOwner]]`.
 */

import cpp
import codingstandards.cpp.Operator

/**
 * A type which is an `Indirection` type according to the Lifetime profile.
 *
 * An indirection type is either a `LifetimePointerType` or `LifetimeOwnerType`.
 */
abstract class LifetimeIndirectionType extends Type {
  /**
   * Gets the `DerefType` of this indirection type.
   *
   * This corresponds to the owned or pointed to type.
   */
  Type getDerefType() {
    result = this.(PointerType).getBaseType()
    or
    result = this.(ReferenceType).getBaseType()
    or
    exists(MemberFunction mf | mf.getDeclaringType() = this |
      result = mf.(StarOperator).getType().getUnspecifiedType().(ReferenceType).getBaseType()
      or
      result = mf.(SubscriptOperator).getType().getUnspecifiedType().(ReferenceType).getBaseType()
      or
      result =
        mf.(StructureDerefOperator).getType().getUnspecifiedType().(PointerType).getBaseType()
      or
      mf.getName() = "begin" and
      result = mf.getType().(LifetimePointerType).getDerefType()
    )
  }
}

/**
 * A lifetime owner type.
 *
 * A type which owns another object. For example, `std::unique_ptr`. Includes
 * `LifetimeSharedOwnerType`.
 */
class LifetimeOwnerType extends LifetimeIndirectionType {
  LifetimeOwnerType() {
    // Any shared owner types are also owner types
    this instanceof LifetimeSharedOwnerType
    or
    // This is a container type, or a type with a star operator and..
    (
      this instanceof ContainerType
      or
      exists(StarOperator mf | mf.getDeclaringType() = this)
    ) and
    // .. has a "user" provided destructor
    exists(Destructor d |
      d.getDeclaringType() = this and
      not d.isCompilerGenerated()
    )
    or
    // Any specified version of an owner type is also an owner type
    getUnspecifiedType() instanceof LifetimeOwnerType
    or
    // Has a field which is a lifetime owner type
    this.(Class).getAField().getType() instanceof LifetimeOwnerType
    or
    // Derived from a public base class which is a owner type
    exists(ClassDerivation cd |
      cd = this.(Class).getADerivation() and
      cd.getBaseClass() instanceof LifetimeOwnerType and
      cd.getASpecifier().hasName("public")
    )
    or
    // Lifetime profile treats the following types as owner types, even though they don't fully
    // adhere to the requirements above
    this.(Class)
        .hasQualifiedName("std",
          ["stack", "queue", "priority_queue", "optional", "variant", "any", "regex"])
    or
    // Explicit annotation on the type
    this.getAnAttribute().getName().matches("gsl::Owner%")
  }
}

/**
 * A `ContainerType`, based on `[container.requirements]` with some adaptions to capture more real
 * world containers.
 */
class ContainerType extends Class {
  ContainerType() {
    // We use a simpler set of heuristics than the `[container.requirements]`, requiring only
    // `begin()`/`end()`/`size()` as the minimum API for something to be considered a "container"
    // type
    getAMemberFunction().getName() = "begin" and
    getAMemberFunction().getName() = "end" and
    getAMemberFunction().getName() = "size"
    or
    // This class is a `ContainerType` if it is constructed from a `ContainerType`. This is
    // important, because templates may not have instantiated all the required member functions
    exists(TemplateClass tc |
      this.isConstructedFrom(tc) and
      tc instanceof ContainerType
    )
  }
}

/**
 * A lifetime "shared owner" type.
 *
 * A shared owner is type that "owns" another object, and shares that ownership with other owners.
 * Examples include `std::shared_ptr` along with other reference counting types.
 */
class LifetimeSharedOwnerType extends Type {
  LifetimeSharedOwnerType() {
    /*
     * Find all types which can be dereferenced (i.e. have unary * operator), and are therefore
     * likely to be "owner"s or "pointer"s to other objects. We then consider these classes to be
     * shared owners if:
     *  - They can be copied (a unique "owner" type would not be copyable)
     *  - They can destroyed
     */

    // unary * (i.e. can be dereferenced)
    exists(StarOperator mf | mf.getDeclaringType() = this) and
    // "User" provided destructor
    exists(Destructor d |
      d.getDeclaringType() = this and
      not d.isCompilerGenerated()
    ) and
    // A copy constructor and copy assignment operator
    exists(CopyConstructor cc | cc.getDeclaringType() = this and not cc.isDeleted()) and
    exists(CopyAssignmentOperator cc | cc.getDeclaringType() = this and not cc.isDeleted())
    or
    // This class is a `SharedOwnerType` if it is constructed from a `SharedOwnerType`. This is
    // important, because templates may not have instantiated all the required member functions
    exists(TemplateClass tc |
      this.(Class).isConstructedFrom(tc) and
      tc instanceof LifetimeSharedOwnerType
    )
    or
    // Any specified version of a shared owner type is also a shared owner type
    this.getUnspecifiedType() instanceof LifetimeSharedOwnerType
    or
    // Has a field which is a lifetime shared owner type
    this.(Class).getAField().getType() instanceof LifetimeSharedOwnerType
    or
    // Derived from a public base class which is a shared owner type
    exists(ClassDerivation cd |
      cd = this.(Class).getADerivation() and
      cd.getBaseClass() instanceof LifetimeSharedOwnerType and
      cd.getASpecifier().hasName("public")
    )
    or
    // Lifetime profile treats the following types as shared owner types, even though they don't
    // fully adhere to the requirements above
    this.(Class).hasQualifiedName("std", "shared_future")
    or
    // Explicit annotation on the type
    this.getAnAttribute().getName().matches("gsl::SharedOwner%")
  }
}

/**
 * An `IteratorType`, based on `[iterator.requirements]` with some adaptions to capture more real
 * world iterators.
 */
class IteratorType extends Type {
  IteratorType() {
    // We consider anything with an increment and * operator to be sufficient to be an iterator type
    exists(StarOperator mf |
      mf.getDeclaringType() = this and mf.getType().getUnspecifiedType() instanceof ReferenceType
    ) and
    exists(IncrementOperator op |
      op.getDeclaringType() = this and op.getType().(ReferenceType).getBaseType() = this
    )
    or
    // Along with unspecified versions of the types above
    this.getUnspecifiedType() instanceof IteratorType
  }
}

/**
 * A lifetime pointer type.
 *
 * A type which points to another object. For example, `std::unique_ptr`. Includes
 * `LifetimeSharedOwnerType`.
 */
class LifetimePointerType extends LifetimeIndirectionType {
  LifetimePointerType() {
    this instanceof IteratorType
    or
    this instanceof PointerType
    or
    this instanceof ReferenceType
    or
    // A shared owner type is a pointer type, but an owner type is not.
    this instanceof LifetimeSharedOwnerType and
    not this instanceof LifetimeOwnerType
    or
    this.(Class).hasQualifiedName("std", "reference_wrapper")
    or
    exists(Class vectorBool, UserType reference |
      vectorBool.hasQualifiedName("std", "vector") and
      vectorBool.getATemplateArgument() instanceof BoolType and
      reference.hasName("reference") and
      reference.getDeclaringType() = vectorBool and
      this = reference.getUnderlyingType()
    )
    or
    // Any specified version of a pointer type is also an owner type
    this.getUnspecifiedType() instanceof LifetimePointerType
    or
    // Has a field which is a lifetime pointer type
    this.(Class).getAField().getType() instanceof LifetimePointerType
    or
    // Derived from a public base class which is a pointer type
    exists(ClassDerivation cd |
      cd = this.(Class).getADerivation() and
      cd.getBaseClass() instanceof LifetimePointerType and
      cd.getASpecifier().hasName("public")
    )
    or
    // Explicit annotation on the type
    this.getAnAttribute().getName().matches("gsl::Pointer%")
  }
}
