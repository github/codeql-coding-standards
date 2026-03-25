/**
 * @id cpp/misra/non-static-member-not-init-before-use
 * @name RULE-15-1-4: All direct, non-static data members of a class should be initialized before the class object is accessible
 * @description Explicit initialization of all non-static data members reduces the risk of an
 *              invalid state existing after successful construction.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-15-1-4
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.StdNamespace
import codingstandards.cpp.misra
import codingstandards.cpp.types.TrivialType

/**
 * A type needs initialization if it is:
 * - a scalar type
 * - an array of types that need initialization
 * - an aggregate class with a field that needs initialization
 */
private predicate needsInitialization(Type t) {
  isScalarType(t)
  or
  needsInitialization(t.getUnspecifiedType().(ArrayType).getBaseType())
  or
  t instanceof RelevantAggregate
}

/**
 * An aggregate that must be validated at construction time. 
 * For example, `Agg` must be validated at construction time as it includes field `f1` that needs initialization.
 * ```
 * struct Agg {
 *   int f1;
 * };
 * ```
 */
class RelevantAggregate extends Class {
  CheckedField f;

  RelevantAggregate() {
    isAggregateClass(this) and
    f = getAField() and
    not getNamespace() instanceof StdNS and
    // Some aggregates, such as va_list, have no location
    exists(getLocation())
  }

  CheckedField getField() { result = f }
}

/**
 * A field must be checked for initialization if its type needs initialization, is not static, and
 * it does not have a default member initializer.
 *
 * Note that `Field` excludes static data members.
 */
class CheckedField extends Field {
  CheckedField() {
    this instanceof Field and
    needsInitialization(this.getUnspecifiedType()) and
    not exists(this.getInitializer())
  }
}

/**
 * Holds if `f` is initialized in constructor `ctor` via the member initialization list
 * or has a default member initializer (NSDMI).
 */
predicate ctorInitializesCheckedField(Constructor ctor, CheckedField f) {
  // Field appears in the member initialization list
  exists(ConstructorFieldInit init |
    init = ctor.getAnInitializer() and
    init.getTarget() = f and
    not init.isCompilerGenerated()
  )
}

/**
 * Represents an AST element that does not initialize a non-static data member that requires initialization.
 *
 * This may be a constructor definition, or an aggregate creation, etc.
 */
abstract class IncompleteInitialization extends Element {
  abstract CheckedField getField();

  abstract string getKindStr();
}

/**
 * A constructor that does not initialize a field that requires initialization.
 *
 * Non-aggregate class constructors must either:
 * - belong to an aggregate class, or
 * - delegate to another constructor in the same class, or
 * - initialize all fields that require initialization, or
 * - be a defaulted move/copy constructor (which we assume satisfies the above)
 *
 * Constructors that don't meet these criteria are non-compliant.
 */
class IncompleteConstructor extends Constructor, IncompleteInitialization {
  CheckedField checkedField;

  IncompleteConstructor() {
    checkedField = this.getDeclaringType().getAField() and
    not ctorInitializesCheckedField(this, checkedField) and
    // aggregate classes are allowed and do not initialize members
    not isAggregateClass(getDeclaringType()) and
    not getDeclaringType() instanceof Union and
    this.getDeclaringType().hasDefinition() and
    not this.isDeleted() and
    // Delegating constructors do not need to initialize members
    not any(ConstructorDelegationInit init) = this.getAnInitializer() and
    // exclude defaulted move and copy constructors.
    not (
      (
        this.isDefaulted() or
        this.isCompilerGenerated()
      ) and
      (
        this instanceof MoveConstructor or
        this instanceof CopyConstructor
      )
    )
  }

  override CheckedField getField() { result = checkedField }

  override string getKindStr() { result = "Constructor" }
}

/**
 * A using declaration that introduces a base class constructor and skips initialization of a field.
 *
 * A declaration `using BaseClass::BaseClass;` in a derived class allows the derived class to
 * inherit the base class constructors. These will not initialize any fields declared in the derived
 * class, so if any checked field exists, the using declaration is non-compliant.
 */
class UsingBaseConstructor extends UsingDeclarationEntry, IncompleteInitialization {
  Class baseClass;
  Class containerClass;
  CheckedField checkedField;

  UsingBaseConstructor() {
    getEnclosingElement() = containerClass and
    baseClass = getDeclaration() and
    checkedField = containerClass.getAField()
  }

  override CheckedField getField() { result = checkedField }

  override string getKindStr() { result = "Using declaration with base constructor" }
}

/**
 * Handles the scenarios where an aggregate may be initialized by value based on a type.
 *
 * For instance, `const Agg`, `Agg[]`, and `Agg[][]` will be initialized by value, but `Agg*` and
 * `Agg&` will not. This is important to verify that aggregates are properly initialized
 */
predicate typeContainsAggregate(Type t, RelevantAggregate aggregate) {
  t.getUnderlyingType() = aggregate
  or
  not t.getUnderlyingType() instanceof RelevantAggregate and
  typeContainsAggregate(t.getUnderlyingType().(ArrayType).getBaseType(), aggregate)
}

/**
 * A declaration of an aggregate that does not initialize necessary fields.
 *
 * By rule, aggregates are checked at construction time, rather than non-aggregates which are
 * checked at constructor definition.
 *
 * A declaration of `aggregate agg;` does not zero-initialize members, and may be non-compliant,
 * while `aggregate agg{};` does zero-initialize members and is compliant.
 *
 * Note that `aggregate agg;` as a member of an aggregate class is compliant, and as a member of a
 * non-aggregate class will be checked at the outer class constructor definition.
 */
class IncompleteAggregateInit extends LocalVariable, IncompleteInitialization {
  RelevantAggregate aggregate;

  IncompleteAggregateInit() {
    typeContainsAggregate(getType(), aggregate) and
    // agg{} is allowed, and agg; is not.
    not this.hasInitializer()
  }

  override CheckedField getField() { result = aggregate.getField() }

  override string getKindStr() { result = "Aggregate variable" }
}

/**
 * An aggregate created by a new or new[] expression that does not initialize necessary fields.
 *
 * For example, `new Aggregate;` does not zero-initialize members and may be non-compliant, while
 * `new Aggregate{};` does zero-initialize members and is compliant.
 */
class IncompleteAggregateNew extends NewOrNewArrayExpr, IncompleteInitialization {
  RelevantAggregate aggregate;

  IncompleteAggregateNew() {
    typeContainsAggregate(this.getAllocatedType().getUnspecifiedType(), aggregate) and
    not exists(getAChild())
  }

  override CheckedField getField() { result = aggregate.getField() }

  override string getKindStr() { result = "Aggregate new expression" }
}

from IncompleteInitialization init, CheckedField f, int total, int ranked, string suffix
where
  not isExcluded(init, Classes4Package::nonStaticMemberNotInitBeforeUseQuery()) and
  total = count(init.getField()) and
  f =
    rank[ranked](Field candidate |
      candidate = init.getField()
    |
      candidate order by candidate.getName()
    ) and
  ranked <= 3 and
  if total > 1 then suffix = " (and " + (total - 1) + " more)" else suffix = ""
select init, init.getKindStr() + " does not initialize non-static data member $@" + suffix + ".", f,
  f.getName()
