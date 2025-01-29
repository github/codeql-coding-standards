/**
 * A library for modeling iterators and various iterator operations.
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.StdNamespace
import codingstandards.cpp.rules.containeraccesswithoutrangecheck.ContainerAccessWithoutRangeCheck as ContainerAccessWithoutRangeCheck
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils

abstract class ContainerAccess extends VariableAccess {
  abstract Variable getOwningContainer();
}

pragma[noinline, nomagic]
predicate localTaint(DataFlow::Node n1, DataFlow::Node n2) { TaintTracking::localTaint(n1, n2) }

// define this as anything with dataflow FROM the vector
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

/**
 * Models a variable of type `const_iterator` or `iterator`
 */
class ContainerIteratorAccess extends ContainerAccess {
  ContainerIteratorAccess() { getType() instanceof IteratorType }

  predicate isAdditiveOperation() {
    exists(AdditiveOperatorFunctionCall fc |
      // start with all accesses to this variable
      // and restrict it to those accesses where
      // the access is as a qualifier to a
      // ++ or + operation.
      this = fc.getQualifier()
    )
  }

  override Variable getOwningContainer() {
    exists(FunctionCall fc |
      fc = getANearbyAssigningIteratorCall() and
      result = fc.getQualifier().(VariableAccess).getTarget()
    )
  }

  /**
   * gets a function call to cbegin/begin that
   * assigns its value to the iterator represented by this
   * access
   */
  FunctionCall getANearbyAssigningIteratorCall() {
    // the underlying container for this variable is one wherein
    // there is an assigned value of cbegin/cend
    // find all the cbegin/begin calls
    exists(STLContainer c, FunctionCall fc |
      // all calls to cbegin/begin
      fc = c.getAnIteratorFunctionCall() and
      // wherein it has dataflow into this access
      DataFlow::localFlow(DataFlow::exprNode(fc), DataFlow::exprNode(this)) and
      result = fc
    )
  }
}

class ContainerRevalidationOperation extends FunctionCall {
  ContainerRevalidationOperation() { getTarget().getType() instanceof IteratorType }

  Variable getOwningContainer() { result = getQualifier().(VariableAccess).getTarget() }

  VariableAccess getARevalidatedExpr() {
    localTaint(DataFlow::exprNode(this), DataFlow::exprNode(result))
  }
}

/**
 * Models the set of operations that can invalidate a pointer, iterator or
 * reference to a `STLContainer`.
 */
class ContainerInvalidationOperation extends FunctionCall {
  ContainerInvalidationOperation() {
    //std::deque
    (
      exists(STLContainer c |
        c.getSimpleName() = "deque" and
        this = c.getACallToAFunction() and
        getTarget().getName() in [
            "insert", "emplace_front", "emplace_back", "emplace", "push_front", "push_back",
            "erase", "pop_back", "resize", "clear"
          ]
      )
      or
      //std::forward_list
      exists(STLContainer c |
        c.getSimpleName() = "forward_list" and
        this = c.getACallToAFunction() and
        getTarget().getName() in ["erase_after", "pop_front", "resize", "remove", "unique", "clear"]
      )
      or
      //std::list
      exists(STLContainer c |
        c.getSimpleName() = "list" and
        this = c.getACallToAFunction() and
        getTarget().getName() in [
            "erase", "pop_front", "pop_back", "clear", "remove", "remove_if", "unique", "clear"
          ]
      )
      or
      //std::vector
      exists(STLContainer c |
        c.getSimpleName() = "vector" and
        this = c.getACallToAFunction() and
        getTarget().getName() in [
            "reserve", "insert", "emplace_back", "emplace", "push_back", "erase", "pop_back",
            "resize", "clear"
          ]
      )
      or
      //std::set,multiset, map, multimap
      exists(STLContainer c |
        c.getSimpleName() in ["set", "multiset", "map", "multimap"] and
        this = c.getACallToAFunction() and
        getTarget().getName() in ["erase", "clear"]
      )
      or
      //std::unordered_set, unordered_multiset, unordered_map, unordered_multimap
      exists(STLContainer c |
        c.getSimpleName() in [
            "unordered_set", "unordered_multiset", "unordered_map", "unordered_multimap"
          ] and
        this = c.getACallToAFunction() and
        getTarget().getName() in ["erase", "clear", "insert", "emplace", "rehash", "reserve"]
      )
      or
      //std::valarray
      exists(STLContainer c |
        c.getSimpleName() in ["valarray"] and
        this = c.getACallToAFunction() and
        getTarget().getName() in ["resize"]
      )
      or
      //std::string
      (
        exists(STLContainer c |
          c.getSimpleName() in ["string", "basic_string"] and
          this = c.getACallToAFunction() and
          // non-const member functions
          not getTarget().hasSpecifier("const") and
          // except
          not getTarget().getName() in [
              "operator[]", "at", "front", "back", "begin", "rbegin", "end", "rend", "data"
            ]
        )
        or
        exists(FunctionCall fc |
          fc.getTarget().getNamespace() instanceof StdNS and
          this.getTarget().getName() in ["swap", "operator>>", "getline"]
        )
      )
    )
  }

  /**
   * Holds if this operation taints a given `VariableAccess`. This is useful for
   * tracking flow out of these functions (which may or may not happen). For
   * example, if an iterator reference returned is not subsequently assigned.
   */
  predicate taintsVariables() {
    exists(VariableAccess e | localTaint(DataFlow::exprNode(this), DataFlow::exprNode(e)))
  }

  /**
   * All operations in this class happen on a variable.
   */
  Variable getContainer() { result = getQualifier().(VariableAccess).getTarget() }
}

/** An iterator type in the `std` namespace. */
class StdIteratorType extends UserType {
  StdIteratorType() {
    this.getNamespace() instanceof StdNS and
    getSimpleName().matches("%_iterator") and
    not getSimpleName().matches("const_%")
  }
}

abstract class IteratorType extends Type { }

/**
 * Models a `const_iterator` datatype.
 */
class ConstIteratorType extends IteratorType {
  ConstIteratorType() {
    this.(CTypedefType).getName() = "const_iterator"
    or
    this.isConst() and
    this.(SpecifiedType).getBaseType() instanceof StdIteratorType
  }
}

/**
 * Models a `iterator` datatype.
 */
class NonConstIteratorType extends IteratorType {
  NonConstIteratorType() {
    this.(CTypedefType).getName() = "iterator"
    or
    this instanceof StdIteratorType
  }
}

/**
 * Models a variable of type `const_iterator`.
 */
class ConstIteratorVariable extends Variable {
  ConstIteratorVariable() { getType() instanceof ConstIteratorType }
}

/**
 * Models a call to an additive operator.
 */
class AdditiveOperatorFunctionCall extends FunctionCall {
  AdditiveOperatorFunctionCall() {
    getTarget().getName() = "operator+" or getTarget().getName() = "operator++"
  }
}

/**
 * Models a collection of STL container classes.
 */
class STLContainer extends Class {
  STLContainer() {
    getNamespace() instanceof StdNS and
    getSimpleName() in [
        "vector", "list", "deque", "set", "multiset", "map", "multimap", "stack", "queue",
        "priority_queue", "string", "forward_list", "unordered_set", "unordered_multiset",
        "unordered_map", "unordered_multimap", "valarray", "string", "basic_string"
      ]
    or
    getSimpleName() = "string"
    or
    getSimpleName() = "basic_string"
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

  FunctionCall getANonConstIteratorBeginFunctionCall() { result = getACallTo("begin") }

  IteratorSource getAConstIteratorBeginFunctionCall() { result = getACallTo("cbegin") }

  IteratorSource getANonConstIteratorEndFunctionCall() { result = getACallTo("end") }

  IteratorSource getAConstIteratorEndFunctionCall() { result = getACallTo("cend") }

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
 * Models the set of iterator sources. Useful for encapsulating dataflow coming
 * from a function call producing an iterator.
 */
class IteratorSource extends FunctionCall {
  IteratorSource() { this.getType() instanceof IteratorType }

  predicate sourceFor(Expr e) {
    DataFlow::localFlow(DataFlow::exprNode(this), DataFlow::exprNode(e))
  }

  Variable getOwner() { result = getQualifier().(VariableAccess).getTarget() }
}

/**
 * Models a variable that is a `STLContainer`
 */
class STLContainerVariable extends Variable {
  STLContainerVariable() { getType() instanceof STLContainer }
}

/**
 * Usually an iterator range consists of two sequential iterator arguments, for
 * example, the start and end. However, there are exceptions to this rule so
 * rather than relying on a heuristic alone, this class is encoded with
 * with exceptions to create a more accurate model. It is used with `IteratorRangeFunctionCall`
 * to create this functionality.
 */
class IteratorRangeModel extends Function {
  IteratorRangeModel() { hasQualifiedName("std", "lexicographical_compare") }

  int getAnIndexOfAStartRange() {
    (hasQualifiedName("std", "lexicographical_compare") and result = [0, 1])
  }

  int getAnIndexOfAEndRange() {
    (hasQualifiedName("std", "lexicographical_compare") and result = [2, 3])
  }

  int getAnIteratorArgumentIndex() {
    (hasQualifiedName("std", "lexicographical_compare") and result = [0, 1, 2, 3])
  }

  predicate getAPairOfStartEndIndexes(int start, int end) {
    hasQualifiedName("std", "lexicographical_compare") and start = 0 and end = 1
    or
    hasQualifiedName("std", "lexicographical_compare") and start = 2 and end = 3
  }
}

/**
 * This definition takes the position that any function taking more than one
 * iterator is a range function. This assumption appears to be reasonable
 * based on testing on several large databases.
 *
 * We add special cases for functions where this assumption is not correct.
 * These exceptions are modeled by the `IteratorRangeModel` class on which
 * this class depends.
 */
class IteratorRangeFunctionCall extends FunctionCall {
  IteratorRangeFunctionCall() {
    count(Expr e |
      e = getAnArgument() and
      e.getType() instanceof IteratorType and
      getTarget().getNamespace() instanceof StdNS and
      not getTarget().getName() in ["operator==", "operator!="]
    ) > 1
  }

  int getAnIteratorArgumentIndex() {
    result = getTarget().(IteratorRangeModel).getAnIteratorArgumentIndex()
    or
    getArgument(result).getType() instanceof IteratorType
  }

  // develop a function that gives indexes of which things are which
  // then we basically theck that there is flow from cend/cbegin to those
  // essentially that there exists one
  int getAnIndexOfAStartRange() {
    result = getTarget().(IteratorRangeModel).getAnIndexOfAStartRange()
    or
    result = min(getAnIteratorArgumentIndex())
  }

  int getAnIndexOfAEndRange() {
    result = getTarget().(IteratorRangeModel).getAnIndexOfAEndRange()
    or
    result = getAnIteratorArgumentIndex() and not result = getAnIndexOfAStartRange()
  }

  Expr getAStartRangeFunctionCallArgument() { result = getArgument(getAnIndexOfAStartRange()) }

  Expr getAEndRangeFunctionCallArgument() { result = getArgument(getAnIndexOfAEndRange()) }

  predicate getAStartEndRangeFunctionCallArgumentPairIndexes(int start, int end) {
    getTarget().(IteratorRangeModel).getAPairOfStartEndIndexes(start, end)
    or
    end = getAnIndexOfAEndRange() and start = getAnIndexOfAStartRange()
  }

  /**
   * This predicate produces the set of (start,end) where `start` and `end` are
   * start end pairs corresponding to some usage. Note this is modeled by `IteratorRangeModel`.
   */
  predicate getAStartEndRangeFunctionCallArgumentPair(Expr start, Expr end) {
    exists(int s, int e |
      getAStartEndRangeFunctionCallArgumentPairIndexes(s, e) and
      start = getArgument(s) and
      end = getArgument(e)
    )
  }
}

/**
 * This predicate holds if a given `ContainerInvalidationOperation` reaches a
 * `ContainerAccess` without being revalidated.
 */
predicate invalidationReaches(ContainerInvalidationOperation op, ContainerAccess target) {
  target.getOwningContainer() = op.getContainer() and
  target = getANonInvalidatedSuccessor(op) and
  not exists(ContainerRevalidationOperation rop |
    rop.getARevalidatedExpr() = target and
    rop = getANonInvalidatedSuccessor(op) and
    rop = getANonInvalidatedPredecessor(target)
  )
}

/** Get a predecessor of `target` that occurs without invalidation. */
ControlFlowNode getANonInvalidatedPredecessor(ContainerAccess target) {
  result = target
  or
  exists(ControlFlowNode mid |
    mid = getANonInvalidatedPredecessor(target) and
    result = mid.getAPredecessor() and
    not result instanceof ContainerInvalidationOperation
  )
}

/** Get a successor of `target` that occurs without invalidation. */
ControlFlowNode getANonInvalidatedSuccessor(ContainerInvalidationOperation op) {
  result = op
  or
  exists(ControlFlowNode mid |
    mid = getANonInvalidatedSuccessor(op) and
    result = mid.getASuccessor() and
    not result instanceof ContainerInvalidationOperation
  )
}

/**
 * Guarded by a bounds check that ensures our destination is larger than "some" value
 */
predicate sizeCompareBoundsChecked(IteratorSource iteratorCreationCall, Expr guarded) {
  exists(
    GuardCondition guard, ContainerAccessWithoutRangeCheck::ContainerSizeCall sizeCall,
    boolean branch
  |
    globalValueNumber(sizeCall.getQualifier()) =
      globalValueNumber(iteratorCreationCall.getQualifier()) and
    guard.controls(guarded.getBasicBlock(), branch) and
    relOpWithSwapAndNegate(guard, sizeCall, _, Greater(), _, branch)
  )
}
