/**
 * Provides a library which includes a `problems` predicate for reporting containers which are
 * accessed without a prior suitable range check.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.standardlibrary.String
import codingstandards.cpp.lifetimes.lifetimeprofile.TypeCategories
import codingstandards.cpp.Operator
import semmle.code.cpp.controlflow.Guards
private import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

abstract class ContainerAccessWithoutRangeCheckSharedQuery extends Query { }

Query getQuery() { result instanceof ContainerAccessWithoutRangeCheckSharedQuery }

class InterestingContainerType extends ContainerType {
  InterestingContainerType() {
    not hasQualifiedName("std", ["unordered_map", "map"]) // map handles indexes not within the range
  }

  /**
   * Gets the `size_type` for this container.
   */
  TypedefType getSizeType() {
    result = getAMember() and
    result.getName() = "size_type"
  }
}

predicate hasUpperBound(VariableAccess offsetExpr) {
  exists(BasicBlock controlled, StackVariable offsetVar, SsaDefinition def |
    controlled.contains(offsetExpr) and
    linearBoundControls(controlled, def, offsetVar) and
    offsetExpr = def.getAUse(offsetVar)
  )
}

pragma[noinline]
predicate linearBoundControls(BasicBlock controlled, SsaDefinition def, StackVariable offsetVar) {
  exists(GuardCondition guard, boolean branch |
    guard.controls(controlled, branch) and
    cmpWithLinearBound(guard, def.getAUse(offsetVar), Lesser(), branch)
  )
}

/**
 * Holds if the `indexing` operation is guarded by a check againgst
 */
private predicate isIndexingGuardedByContainerSizeComparison(
  IntegerIndexingCall indexing, Expr comparisonValue, RelationStrictness strictness
) {
  exists(GuardCondition guard, boolean branch |
    guard.controls(indexing.getBasicBlock(), branch) and
    relOpWithSwapAndNegate(guard, indexing.getAContainerSizeCall(), comparisonValue, Greater(),
      strictness, branch)
  )
}

/**
 * The `std::array` type.
 */
class StdArray extends Class {
  StdArray() { hasQualifiedName("std", "array") }

  /**
   * Gets the fixed size of this array type, if this is an instantiation of the `std::array`
   * template class.
   */
  float getStdArraySize() { result = this.getTemplateArgument(1).(Expr).getValue().toFloat() }
}

/**
 * A call to `empty()` on a container.
 */
class ContainerEmptyCall extends FunctionCall {
  ContainerEmptyCall() {
    getTarget().getDeclaringType() instanceof ContainerType and
    getTarget().getName() = "empty"
  }
}

/**
 * A call to either `begin()` on a container.
 */
class ContainerBeginCall extends FunctionCall {
  ContainerBeginCall() {
    getTarget().getDeclaringType() instanceof ContainerType and
    getTarget().getName() = "begin"
  }
}

/**
 * A call to either `end()` on a container.
 */
class ContainerEndCall extends FunctionCall {
  ContainerEndCall() {
    getTarget().getDeclaringType() instanceof ContainerType and
    getTarget().getName() = "end"
  }
}

/**
 * A call to either `size()` or `length()` on a container.
 */
class ContainerSizeCall extends FunctionCall {
  ContainerSizeCall() {
    getTarget().getDeclaringType() instanceof ContainerType and
    getTarget().getName() = ["size", "length"]
  }
}

/**
 * A call to `resize()` on a container.
 */
class ContainerResizeCall extends FunctionCall {
  ContainerResizeCall() {
    getTarget().getDeclaringType() instanceof ContainerType and
    getTarget().getName() = "resize"
  }
}

/** A non-local variable. */
private class NonLocalVariable extends Variable {
  NonLocalVariable() { not this instanceof LocalScopeVariable }
}

/** A `ConstructorCall` that initializes a container. */
abstract class ContainerConstructorCall extends ConstructorCall {
  /** Gets the initial size of the container, if it can be deduced. */
  abstract float getInitialContainerSize();

  /** Gets an expression for the initial size of the container, if any. */
  abstract Expr getInitialContainerSizeExpr();
}

class VectorContainerConstructorCall extends ContainerConstructorCall {
  Constructor c;

  VectorContainerConstructorCall() {
    c = getTarget() and
    c.getDeclaringType().hasQualifiedName("std", "vector")
  }

  override Expr getInitialContainerSizeExpr() {
    exists(int param |
      // Explicit size argument passed
      c.getParameter(param).getType() =
        c.getDeclaringType().(InterestingContainerType).getSizeType() and
      result = getArgument(param)
    )
  }

  override float getInitialContainerSize() {
    result = lowerBound(getInitialContainerSizeExpr().getFullyConverted())
    or
    // Initializer list passed of fixed size
    c.getParameter(0).getType().(Class).hasQualifiedName("std", "initializer_list") and
    // Modelled as a constructor call to std::initializer_list
    result =
      getArgument(0).(ConstructorCall).getArgument(0).(ArrayOrVectorAggregateLiteral).getArraySize()
  }
}

class StringContainerConstructorCall extends ContainerConstructorCall {
  Constructor c;
  StdBasicString stringInstantiation;

  StringContainerConstructorCall() {
    c = getTarget() and
    c.getDeclaringType() = stringInstantiation
  }

  override Expr getInitialContainerSizeExpr() {
    // from buffer
    c.getNumberOfParameters() = 3 and
    c.getParameter(0).getType() = stringInstantiation.getConstCharTPointer() and
    c.getParameter(1).getType() = stringInstantiation.getSizeType() and
    c.getParameter(2).getType() = stringInstantiation.getConstAllocatorReferenceType() and
    // copies `n` items from the buffer
    result = getArgument(1)
    or
    // fill constructor
    c.getNumberOfParameters() = 3 and
    c.getParameter(0).getType() = stringInstantiation.getSizeType() and
    c.getParameter(1).getType() = stringInstantiation.getCharT() and
    c.getParameter(2).getType() = stringInstantiation.getConstAllocatorReferenceType() and
    // This constructor creates a string the same length as the 0th parameter
    result = getArgument(0)
  }

  override float getInitialContainerSize() {
    // Default constructor has an empty string
    c.getNumberOfParameters() = 0 and
    result = 0
    or
    // from c-string constructors
    c.getNumberOfParameters() = 1 and
    c.getParameter(0).getType() = stringInstantiation.getConstCharTPointer() and
    result = getArgument(0).getValue().length()
    or
    c.getNumberOfParameters() = 2 and
    c.getParameter(0).getType() = stringInstantiation.getConstCharTPointer() and
    c.getParameter(1).getType() = stringInstantiation.getSizeType() and
    result = getArgument(1).getValue().toFloat()
    or
    c.getNumberOfParameters() = 2 and
    c.getParameter(0).getType() = stringInstantiation.getSizeType() and
    c.getParameter(1).getType() = stringInstantiation.getCharT() and
    result = getArgument(0).getValue().toFloat()
    or
    c.getNumberOfParameters() = 2 and
    c.getParameter(0).getType() = stringInstantiation.getConstCharTPointer() and
    c.getParameter(1).getType() = stringInstantiation.getConstAllocatorReferenceType() and
    result = getArgument(0).getValue().length()
    or
    // Lower bound of an explicit size argument
    result = lowerBound(getInitialContainerSizeExpr().getFullyConverted())
  }
}

class IntegerIndexingCall extends FunctionCall {
  IntegerIndexingCall() {
    getTarget() instanceof SubscriptOperator and
    getTarget().getParameter(0).getType().getUnspecifiedType() instanceof IntegralType and
    getTarget().getDeclaringType() instanceof InterestingContainerType
  }

  /**
   * Get a prior access to the same container in the same function.
   */
  Expr getAPriorContainerAccess() {
    result = getAnEquivalentContainerAccess() and
    (
      result.getBasicBlock() = getQualifier().getBasicBlock().getAPredecessor+()
      or
      exists(BasicBlock current, int priorPos, int indexPos |
        current = result.getBasicBlock() and
        current = getQualifier().getBasicBlock() and
        current.getNode(priorPos) = result and
        current.getNode(indexPos) = getQualifier() and
        priorPos < indexPos
      )
    )
  }

  /**
   * Get an equivalent access to the same container anywhere in the same function.
   */
  private Expr getAnEquivalentContainerAccess() {
    exists(SsaDefinition def, StackVariable containerVar |
      this.getQualifier() = def.getAUse(containerVar) and
      result = def.getAUse(containerVar)
    )
    or
    // For member and global/namespace variables we provide an over-approximation of equivalence
    // to avoid false positives
    exists(NonLocalVariable nlv |
      nlv.getAnAccess() = this.getQualifier() and
      result = nlv.getAnAccess() and
      result.getEnclosingFunction() = getEnclosingFunction()
    )
    or
    // Use GVN to fill out more complex cases
    globalValueNumber(result) = globalValueNumber(this.getQualifier())
  }

  /** Gets a prior call which returns the size of the container used in this indexing operation. */
  ContainerSizeCall getAContainerSizeCall() { result.getQualifier() = getAPriorContainerAccess() }

  /**
   * Gets a prior call which returns whether the container used in this indexing operation is empty.
   */
  ContainerEmptyCall getAContainerEmptyCall() { result.getQualifier() = getAPriorContainerAccess() }

  /** Gets a prior call which resized the container used in this indexing operation. */
  ContainerResizeCall getAContainerResizeCall() {
    result.getQualifier() = getAPriorContainerAccess()
  }

  /**
   * Gets a lower bound for the accessed container.
   */
  float getContainerSizeLowerBound() {
    // We iterate a number of different "candidate" ways of identifying bounds, then choose the
    // largest candidate bound, as the bound cannot be lower.
    result = max(getContainerSizeLowerBound_candidates())
  }

  private ContainerConstructorCall getAConstructorCallSource() {
    // Use local flow to find allocations which reach this qualifier without redefinition
    DataFlow::localFlow(DataFlow::exprNode(result), DataFlow::exprNode(getQualifier()))
  }

  /**
   * A set of candidate lower bounds for the indexing expression.
   */
  private float getContainerSizeLowerBound_candidates() {
    // If the container is is allocated locally at a fixed size
    result = getAConstructorCallSource().getInitialContainerSize()
    or
    // At least one "push_back" happens on this container, indicates the size is > 1
    // This is a rough approximation - clearly, the element could be removed from container, or
    // additional elements could be pushed, but this is not currently modeled.
    exists(DataFlow::DefinitionByReferenceNode ref, FunctionCall call |
      DataFlow::localFlow(ref, DataFlow::exprNode(getQualifier())) and
      ref.getArgument() = call.getQualifier() and
      call.getTarget().hasName("push_back") and
      result = 1
    )
    or
    // Container was previously resized, so consider the range of the argument supplied
    exists(ContainerResizeCall c |
      c = getAContainerResizeCall() and
      // The fully converted expression is the one which will be used as the container size.
      // Note: this isn't as helpful an addition as it first seems. Consider this example:
      //
      //   std::string its_name(host_->get_name());
      //   uint32_t its_size(static_cast<uint32_t>(its_name.size()));
      //   its_command.resize(7 + its_name.size());
      //
      // Here, we deduce that the resize has a lower bound of `0`, because `its_name.size()` is
      // unbounded, and therefore adding `7` could overflow. As the integer is unsigned, the
      // overflow provides a lower bound of zero.
      result = lowerBound(c.getArgument(0).getFullyConverted())
    )
    or
    // If the container is a std::array, then it has a fixed size we can determine by inspecting
    // the type of the qualifier of this indexing operation.
    exists(Type qualifierType, StdArray stdArrayType |
      qualifierType = getQualifier().getType().getUnspecifiedType() and
      result = stdArrayType.getStdArraySize()
    |
      stdArrayType = qualifierType or
      stdArrayType = qualifierType.(DerivedType).getBaseType().getUnspecifiedType()
    )
    or
    // If this indexing operation is guarded by a bounds check that ensures the size of the
    // container is above a certain size, then we use lower bound of the comparison value
    // as a lower bound for the container size
    exists(Expr comparisonValue, RelationStrictness rs |
      isIndexingGuardedByContainerSizeComparison(this, comparisonValue, rs)
    |
      result = lowerBound(comparisonValue) and
      rs = Nonstrict()
      or
      result = lowerBound(comparisonValue) + 1 and
      rs = Strict()
    )
    or
    // If this indexing operation is guarded by a call to `container.size()` or `container.empty()`
    // we can deduce, on certain paths, that the container is non-empty (i.e. the size has a lower
    // bound of 1)
    exists(GuardCondition guard, boolean branch |
      guard.controls(this.getBasicBlock(), branch) and
      result = 1
    |
      guard = getAContainerSizeCall() and
      branch = true
      or
      guard = getAContainerEmptyCall() and
      branch = false
    )
    or
    // If this indexing operation is guarded by a `==` or `!=` call on the size of the container,
    // we can refine the lower bound if we have confirmed that the size is equal to some value, or
    // if we've confirmed the size is not equal to zero (in which case the container is non-empty)
    exists(GuardCondition guard, EqualityOperation op, Expr otherOperand, boolean branch |
      guard.controls(this.getBasicBlock(), branch) and
      guard = op and
      op.getAnOperand() = getAContainerSizeCall() and
      otherOperand = op.getAnOperand() and
      not otherOperand = getAContainerSizeCall()
    |
      op instanceof EQExpr and
      (
        // If the size is equal to some value, then the lower bound of size will be the lower bound
        // of that value
        branch = true and
        result = lowerBound(otherOperand)
        or
        // If the size is not equal to some value, we can only make further deductions about the
        // lower bound if the value it's not equal to is zero
        branch = false and
        otherOperand.getValue() = "0" and
        result = 1
      )
      or
      // If the size is not equal to some value, we can only make further deductions about the
      // lower bound if the value it's not equal to is zero
      op instanceof NEExpr and
      otherOperand.getValue() = "0" and
      branch = true and
      result = 1
    )
    or
    // Containers are always at least size 0
    result = 0
  }

  float getIndexUpperBound() { result = max(getIndexUpperBound_candidate()) }

  private float getIndexUpperBound_candidate() {
    result = upperBound(getArgument(0).getFullyConverted())
  }

  /**
   * Gets a lower bound for the index, if one can be deduced.
   */
  float getIndexLowerBound() { result = max(getIndexLowerBound_candidate()) }

  private float getIndexLowerBound_candidate() {
    result = lowerBound(getArgument(0).getFullyConverted())
    or
    // If this is the pattern `container[container.size() - n]`, then the lower bound will be the
    // lower bound of the size of the container, minus the upperBound of `n`.
    exists(SubExpr se |
      se.getLeftOperand() = getAContainerSizeCall() and
      result = getContainerSizeLowerBound() - upperBound(se.getRightOperand())
    )
  }
}

query predicate problems(IntegerIndexingCall indexing, string message) {
  not isExcluded(indexing, getQuery()) and
  // Uninstantiated templates may not have full semantic context, so ignore and report in the
  // instantiations instead
  not indexing.isFromUninstantiatedTemplate(_) and
  (
    not hasUpperBound(indexing.getArgument(0)) and
    // We can deduce the indexing is safe iff our lower bound of the container size
    // is less than the upper bound of the index access
    not indexing.getContainerSizeLowerBound() > indexing.getIndexUpperBound() and
    // The access is not of the form `container[container.size() - n]` where n >= 0
    not exists(SubExpr se |
      se.getLeftOperand() = indexing.getAContainerSizeCall() and
      lowerBound(se.getRightOperand()) >= 0
    ) and
    not exists(RemExpr re |
      DataFlow::localExprFlow(re, indexing.getArgument(0)) and
      re.getRightOperand() = indexing.getAContainerSizeCall()
    ) and
    message =
      "Access of container of type " + indexing.getQualifier().getType() +
        " does not ensure that the index is smaller than the bounds."
    or
    // Note: in most cases, the indexing operator will take an argument of size_t, so a negative
    // value is not possible - instead, negative values will be converted to large positive values
    0 > indexing.getIndexLowerBound() and
    message =
      "Access of container of type " + indexing.getQualifier().getType() +
        " does not confirm that the index is non-negative before accessing."
  )
}
