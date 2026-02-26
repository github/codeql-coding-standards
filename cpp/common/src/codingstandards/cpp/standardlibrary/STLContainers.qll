import cpp
import codingstandards.cpp.StdNamespace
private import codingstandards.cpp.standardlibrary.Iterators
private import semmle.code.cpp.dataflow.DataFlow
private import semmle.code.cpp.dataflow.TaintTracking
private import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

newtype TContainerKind =
  TIndexableContainer() or
  TCollectionContainer() or
  TAssociativeContainer() or
  TStringContainer()

newtype TContainerTypeKind =
  TContainerElementType() or
  TContainerKeyType() or
  TContainerCharType()

newtype TIndexIdentity =
  TBoundedIndex(float lower, float upper) {
    exists(ArrayExpr arrayExpr |
      lower = lowerBound(arrayExpr.getArrayOffset().getFullyConverted()) and
      upper = upperBound(arrayExpr.getArrayOffset().getFullyConverted())
    )
    or
    exists(STLContainerKnownElementAccess access |
      access.getContainer().getContainerKind() = TIndexableContainer() and
      lower = lowerBound(access.getElementExpr().getFullyConverted()) and
      upper = upperBound(access.getElementExpr().getFullyConverted())
    )
  }

class BoundedIndex extends TBoundedIndex {
  float ub;
  float lb;

  BoundedIndex() { this = TBoundedIndex(lb, ub) }

  float getLowerBound() { result = lb }

  float getUpperBound() { result = ub }

  predicate mayOverlap(BoundedIndex other) {
    // It's easier to think about bounds that cannot overlap, and then negate that.
    not (
      // If our lower bound is greater than the other's upper bound, they can't overlap.
      lb > other.getUpperBound()
      or
      // If our upper bound is less than the other's lower bound, they can't overlap.
      ub < other.getLowerBound()
    )
  }

  predicate forIndexExpr(Expr expr) {
    this = TBoundedIndex(lowerBound(expr.getFullyConverted()), upperBound(expr.getFullyConverted()))
  }

  string toString() { result = "Index bounded by [" + lb.toString() + ", " + ub.toString() + "]" }
}

class STLContainerUnknownElementAccess extends FunctionCall {
  STLContainer container;
  Expr containerExpr;

  STLContainerUnknownElementAccess() {
    this =
      container
          .getACallTo([
              "front", "back", "top", "count", "find", "contains", "lower_bound", "upper_bound",
              "equal_range"
            ]) and
    containerExpr = this.getQualifier()
  }

  STLContainer getContainer() { result = container }

  Expr getContainerExpr() { result = containerExpr }
}

class STLContainerKnownElementAccess extends FunctionCall {
  STLContainer container;
  Expr containerExpr;
  Expr elementExpr;

  STLContainerKnownElementAccess() {
    this = container.getACallTo(["at", "operator[]"]) and
    containerExpr = this.getQualifier() and
    elementExpr = this.getArgument(0)
  }

  STLContainer getContainer() { result = container }

  Expr getContainerExpr() { result = containerExpr }

  Expr getElementExpr() { result = elementExpr }
}

class STLContainerIndexAccess extends STLContainerKnownElementAccess {
  BoundedIndex index;

  STLContainerIndexAccess() {
    container.getContainerKind() = TIndexableContainer() and
    containerExpr = this.getQualifier() and
    index.forIndexExpr(getElementExpr())
  }

  Expr getIndexExpr() { result = getElementExpr() }

  BoundedIndex getIndexIdentity() { result = index }
}

class STLContainerKeyAccess extends STLContainerKnownElementAccess { }

class STLContainerUnknownElementModification extends FunctionCall {
  Expr keyExpr;
  Expr containerExpr;
  STLContainer container;

  STLContainerUnknownElementModification() {
    this =
      container
          .getACallTo([
              "clear", "push_back", "pop_back", "pop_front", "insert", "emplace", "emplace_back",
              "emplace_front", "emplace_hint", "erase", "resize", "assign", "assign_range", "swap",
              "push", "pop", "fill", "extract", "merge", "insert_or_assign", "try_emplace",
              "operator+=", "replace", "replace_with_range", "copy"
            ])
  }
}

class STLContainerElementModification extends FunctionCall {
  STLContainer container;
  Expr elementExpr;

  STLContainerElementModification() {
    this = container.getACallTo(["remove", "remove_if", "sort", "reverse", "unique"])
  }
}

class STLContainerStorageAccess extends FunctionCall {
  STLContainer container;

  Expr getAStorageAccess() {
    result =
      container
          .getACallTo([
              "data", "c_str", "bucket_count", "max_bucket_count", "bucket_size", "bucket",
              "load_factor", "max_load_factor", "capacity", "length", "size", "empty", "length",
              "find", "rfind", "find_first_of", "find_last_of", "find_first_not_of",
              "find_last_not_of", "substr", "compare"
            ])
  }
}

class STLContainerIndexAssignment extends FunctionCall { }

class STLContainerKeyAssignment extends FunctionCall { }

class STLContainerStorageModification extends FunctionCall { }

/**
 * Models a collection of STL container classes.
 */
class STLContainer extends Class {
  TContainerKind containerKind;

  STLContainer() {
    getNamespace() instanceof StdNS and
    // TODO: add to change log that we added std::array
    getSimpleName() in ["vector", "deque", "array", "valarray"] and
    containerKind = TIndexableContainer()
    or
    getSimpleName() in [
        "set", "stack", "queue", "list", "priority_queue", "forward_list", "unordered_set"
      ] and
    containerKind = TCollectionContainer()
    or
    getNamespace() instanceof StdNS and
    getSimpleName() in [
        "multiset", "map", "multimap", "unordered_multiset", "unordered_map", "unordered_multimap"
      ] and
    containerKind = TAssociativeContainer()
    or
    // TODO: This intentionally doesn't check namespace::std, what are the implications?
    // TODO: add support for `std::string_view`?
    getSimpleName() in ["string", "basic_string"] and
    containerKind = TStringContainer()
  }

  /**
   * Get the kind of this container, such as array-like or associative or string.
   */
  TContainerKind getContainerKind() { result = containerKind }

  /**
   * Get the type argument corresponding to the given kind, such as element type or key type.
   *
   * Note that this treats `T` in `std::set<T>` (and similar containers) as the element type, though
   * it may be referred to as the key type by some documentation.
   */
  Type getTypeArgument(TContainerTypeKind kind) {
    (containerKind = TIndexableContainer() or containerKind = TCollectionContainer()) and
    kind = TContainerElementType() and
    result = this.getTemplateArgument(0)
    or
    containerKind = TAssociativeContainer() and
    kind = TContainerKeyType() and
    result = this.getTemplateArgument(0)
    or
    containerKind = TAssociativeContainer() and
    kind = TContainerElementType() and
    result = this.getTemplateArgument(1)
    or
    containerKind = TStringContainer() and
    kind = TContainerCharType() and
    result = this.getTemplateArgument(0)
  }

  /**
   * Get the element type of this container, for instance `int` in `std::vector<int>`.
   *
   * Note that for associative containers like `std::map<K, V>`, this returns `V`. For the key type,
   * use `getKeyType()`.
   *
   * For set-like containers such as `std::set<T>`, this returns `T`, though it may be referred to as the key
   * type by some documentation.
   */
  Type getElementType() { result = getTypeArgument(TContainerElementType()) }

  /**
   * Get the key type of this container, for instance `K` in `std::map<K, V>`.
   *
   * This does not return a result for set-like containers such as `std::set<T>`, though `T` may be
   * referred to as the key type by some documentation.
   */
  Type getKeyType() { result = getTypeArgument(TContainerKeyType()) }

  Type getStringCharType() {
    // TODO: unwrap `std::string` to `std::basic_string<char, ...>`
    result = getTypeArgument(TContainerCharType())
  }

  /**
   * Get a call to a named function of this class.
   */
  FunctionCall getACallTo(string name) {
    exists(Function f |
      f = getAMemberFunction() and
      f.hasName(name) and
      result = f.getACallToThisFunction()
    )
  }

  /**
   * Gets all calls to all functions of this class.
   */
  FunctionCall getACallToAFunction() {
    exists(Function f |
      f = getAMemberFunction() and
      result = f.getACallToThisFunction()
    )
  }

  FunctionCall getACallToSize() { result = getACallTo("size") }

  FunctionCall getANonConstIteratorBeginFunctionCall() { result = getACallTo(["begin", "rbegin"]) }

  IteratorSource getAConstIteratorBeginFunctionCall() { result = getACallTo(["cbegin", "crbegin"]) }

  IteratorSource getANonConstIteratorEndFunctionCall() { result = getACallTo(["end", "rend"]) }

  IteratorSource getAConstIteratorEndFunctionCall() { result = getACallTo(["cend", "crend"]) }

  IteratorSource getANonConstIteratorFunctionCall() {
    result = getACallToAFunction() and
    result.getTarget().getType() instanceof NonConstIteratorType
  }

  IteratorSource getAConstIteratorFunctionCall() {
    result = getACallToAFunction() and
    result.getTarget().getType() instanceof ConstIteratorType
  }

  IteratorSource getAnIteratorFunctionCall() {
    result = getANonConstIteratorFunctionCall() or result = getAConstIteratorFunctionCall()
  }

  IteratorSource getAnIteratorBeginFunctionCall() {
    result = getANonConstIteratorBeginFunctionCall() or
    result = getAConstIteratorBeginFunctionCall()
  }

  IteratorSource getAnIteratorEndFunctionCall() {
    result = getANonConstIteratorEndFunctionCall() or result = getAConstIteratorEndFunctionCall()
  }
}

/**
 * Models a variable that is a `STLContainer`
 */
class STLContainerVariable extends Variable {
  STLContainerVariable() { getType() instanceof STLContainer }
}

/**
 * An access to a variable that refers to an STL container, or objects owned by such a container.
 *
 * Includes `ContainerPointerOrReferenceAccess`, and `ContainerIteratorAccess` from `Iterators.qll`,
 * which tracks access to container elements via iterators.
 */
abstract class ContainerAccess extends VariableAccess {
  abstract Variable getOwningContainer();
}

pragma[noinline, nomagic]
private predicate localTaint(DataFlow::Node n1, DataFlow::Node n2) {
  TaintTracking::localTaint(n1, n2)
}

/**
 * An access that gets a pointer or reference to an element of an STL container.
 *
 * Defined as anything with dataflow FROM the container.
 */
class ContainerPointerOrReferenceAccess extends ContainerAccess {
  Variable owningContainer;

  ContainerPointerOrReferenceAccess() {
    exists(STLContainer c, FunctionCall fc |
      fc = c.getACallToAFunction() and
      // There are a few cases where the value is tainted
      // but no actual link to the underlying container is established.
      // For example, calling Vector<int>.size() returns an int but the
      // resulting variable doesn't depend on the underlying container
      // anymore.
      (
        fc.getTarget().getType() instanceof ReferenceType or
        fc.getTarget().getType() instanceof PointerType or
        fc.getTarget().getType() instanceof IteratorType
      ) and
      localTaint(DataFlow::exprNode(fc), DataFlow::exprNode(this)) and
      (getUnderlyingType() instanceof ReferenceType or getUnderlyingType() instanceof PointerType) and
      fc.getQualifier().(VariableAccess).getTarget() = owningContainer and
      // Exclude cases where we see taint into the owning container
      not this = owningContainer.getAnAccess()
    )
  }

  override Variable getOwningContainer() { result = owningContainer }
}
