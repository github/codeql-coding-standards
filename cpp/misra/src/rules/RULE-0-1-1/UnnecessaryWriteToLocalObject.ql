/**
 * @id cpp/misra/unnecessary-write-to-local-object
 * @name RULE-0-1-1: A value should not be unnecessarily written to a local object
 * @description Unused writes to objects may harm performance, complicate code comprehension, or
 *              indicate logical errors in the program.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-0-1-1
 *       scope/system
 *       correctness
 *       maintainability
 *       performance
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/advisory
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.misra
import codingstandards.cpp.lifetimes.CppObjects
import codingstandards.cpp.lifetimes.CppSubObjects
import codingstandards.cpp.dominance.FeasiblePath
import codingstandards.cpp.types.TrivialType
import codingstandards.cpp.standardlibrary.STLContainers

/**
 * A type that is relevant for analysis by this rule.
 *
 * Objects tracked by this rule must have a trivially destructible type, or be a container of
 * trivially destructible types (either a standard library container or an array).
 *
 * Non-class types such as pointer types, built-in types, and enumerations are trivially
 * destructible.
 *
 * Note that `T*` is a trivially destructible type, regardless of whether `T` is trivially
 * destructible.
 */
class RelevantType extends Type {
  RelevantType() {
    // Include trivially destructible types
    hasTrivialDestructor(this)
    or
    // Include scalar types, but arrays must be checked recursively.
    not this instanceof ArrayType and
    not this instanceof Class
    or
    // Arrays of trivial types are trivial
    this.(ArrayType).getBaseType() instanceof RelevantType
    or
    // TODO exclude arrays of containers
    // Containers of trivial types are trivial
    // Exclude containers of containers because we can't model those well yet.
    exists(RelevantType elemType |
      elemType = this.(STLContainer).getElementType() and
      not elemType instanceof STLContainer
    )
  }
}

/**
 * Certain types of behavior are not correctly tracked and therefore we exclude functions
 * containing them from analysis.
 *
 * Try-catch blocks can complicate control flow in ways that are not currently modeled.
 *
 * Lambda captures by reference are not yet tracked, so we exclude functions that define lambdas
 * entirely. Additionally, the bodies of those lambdas had some odd results during testing, so those
 * functions are also excluded.
 */
class ExcludedFunction extends Function {
  ExcludedFunction() {
    exists(TryStmt try | try.getEnclosingFunction() = this)
    or
    exists(LambdaExpression l | l.getEnclosingFunction() = this)
    or
    exists(Closure c | c.getLambdaFunction() = this)
  }
}

/**
 * For performance reasons, we limit the analyzed control flow nodes to the ones that are not in
 * excluded functions.
 */
class RelevantControlFlowNode extends ControlFlowNode {
  RelevantControlFlowNode() {
    not this.(Element).getEnclosingElement+() instanceof ExcludedFunction
  }
}

/**
 * For performance reasons, we define this class to be the set of objects that we want to track
 * writes and reads for to satisfy the rule.
 */
class RelevantObject extends ObjectIdentity {
  RelevantObject() {
    getStorageDuration().isAutomatic() and
    getType() instanceof RelevantType
  }
}

newtype TTrackedObject =
  TJustSubObject(SubObject subObj) { subObj.getRootIdentity() instanceof RelevantObject } or
  /**
   * An indexed element of a container or array, tracked with a `BoundedIndex`, see `TrackedObject`
   * for details.
   */
  TContainerElementSubObject(SubObject container, BoundedIndex index) {
    exists(STLContainerIndexAccess access |
      access.getContainer() = container.getType() and
      access.getContainerExpr() = container.getAnAccess() and
      index = access.getIndexIdentity()
    )
    or
    container.getType() instanceof ArrayType and
    exists(ArrayExpr access |
      access.getArrayBase() = container.getAnAccess() and
      index.forIndexExpr(access.getArrayOffset())
    )
  }

/**
 * A `TrackedObject` is an expansion of `SubObject` that allows array and container index tracking.
 *
 * In `CppSubObjects.qll`, an array member is represented as a single `SubObject`, to minimize
 * performance overhead. Most rules can treat `x[i]` and `x[j]` as the same subobject `x[]`, and
 * rely on `SubObject`'s `isPrecise()` predicate to handle the nuance in that type of case. However,
 * this rule explicitly desires us to track writes to different indices of the same array or
 * container, so we use `TrackedObject` to augment `SubObject` with index tracking.
 *
 * To distinguish `arr[x]` and `arr[y]`, we use a `BoundedIndex` to represent the index expression,
 * which represents a lower and upper bound for the index value. Therefore, `arr[0]` and `arr[1]`
 * will be separate `TrackedObject`s. Additionally, `arr[i]` and `arr[j]` will be the same
 * `TrackedObject` when the bounds of `i` and `j` are the same. Lastly, two different expressions
 * `arr[i]` and `arr[i]` with different source locations may be different `TrackedObject`s if their
 * `BoundedIndex`es differ.
 *
 * Note that a `TrackedObject` will only track a single index for a given container or array. For a
 * multidimensional array access such as `arr[i][j]`, the leaf `TrackedObject` will precisely track
 * `j`, but its parent `TrackedObject` will only track `arr[]`, not `i`, via the `SubObject` API.
 *
 * Therefore, tracking equality of two `TrackedObject`s has some subtleties, see `mayOverlap` and
 * `mustOverlap` for implementations.
 */
class TrackedObject extends TTrackedObject {
  ObjectIdentity getRootIdentity() {
    exists(SubObject subObj |
      this = TJustSubObject(subObj) and result = subObj.getRootIdentity()
      or
      this = TContainerElementSubObject(subObj, _) and
      result = subObj.getRootIdentity()
    )
  }

  Expr getAnAccess() {
    exists(SubObject subObj |
      this = TJustSubObject(subObj) and result = subObj.getAnAccess()
      or
      exists(BoundedIndex index |
        this = TContainerElementSubObject(subObj, index) and
        (
          exists(STLContainerIndexAccess access |
            access.getContainer() = subObj.getType() and
            access.getContainerExpr() = subObj.getAnAccess() and
            access.getIndexIdentity() = index and
            result = access
          )
          or
          exists(ArrayExpr arrayExpr |
            arrayExpr.getArrayBase() = subObj.getAnAccess() and
            // Note the pragma on `getArrayOffset` for performance. The join orderer may begin its
            // its search from `index` or `subObj` in `TContainerElementSubObject(subObj, index)`,
            // in order to find `arrayExpr`. We want it to begin from `subObj` instead of `index`,
            // and `pragma[only_bind_out]` does this by disallowing `forIndexExpr` to "write into,"
            // or bind into, `getArrayOffset()`.
            index.forIndexExpr(pragma[only_bind_out](arrayExpr.getArrayOffset())) and
            result = arrayExpr
          )
        )
      )
    )
  }

  /**
   * Holds if this `TrackedObject` represents the root `ObjectIdentity` itself, rather than a subobject,
   * which also have corresponding `TrackedObject`s.
   */
  predicate representsRootObject() {
    exists(SubObject subObj | this = TJustSubObject(subObj) and subObj.representsRootObject())
  }

  /** Gets the parent `TrackedObject`, if any. */
  TrackedObject getParent() {
    exists(SubObject subObj |
      this = TJustSubObject(subObj) and
      result = TJustSubObject(subObj.getParent())
      or
      this = TContainerElementSubObject(subObj, _) and
      result = TJustSubObject(subObj)
    )
  }

  /**
   * Two different `TrackedObject`s may be the same object even if they are tracked separately.
   *
   * For example, `arr[x]` and `arr[y]` are different `TrackedObject`s, but may overlap if `x` and `y`
   * may be the same index.
   */
  predicate mayOverlap(TrackedObject other) {
    this = other
    or
    exists(BoundedIndex index1, BoundedIndex index2, SubObject subObj |
      this = TContainerElementSubObject(subObj, index1) and
      other = TContainerElementSubObject(subObj, index2) and
      index1.mayOverlap(index2)
    )
  }

  /**
   * Holds if this and the other `TrackedObject`s are known to be the same object.
   *
   * This predicate is more strict than `mayOverlap`, and while it implies equality, it is not
   * equivalent to it.
   *
   * For example, `arr[x]` and `arr[y]` must be the same object if `x` and `y` are equal constant
   * values. Otherwise, even if the upper and lower bounds of `x` and `y` overlap, we cannot be sure
   * they are exactly the same. Even `arr[x]` and `arr[x]` may not be considered the exact same
   * object if `x` is not known to be a precise value, as the value of `x` may change between uses.
   * In the future we could use GlobalValueNumbering to be more precise for that case.
   */
  predicate mustOverlap(TrackedObject other) {
    this.isPrecise() and this = other
    or
    exists(BoundedIndex index1, BoundedIndex index2, SubObject subObj |
      this = TContainerElementSubObject(subObj, index1) and
      other = TContainerElementSubObject(subObj, index2) and
      // TODO: make this a member predicate of BoundedIndex?
      index1.getLowerBound() = index1.getUpperBound() and
      index1 = index2 and
      subObj.isPrecise()
    )
  }

  predicate isPrecise() {
    exists(SubObject subObj |
      this = TJustSubObject(subObj) and subObj.isPrecise()
      // Container elements are not precise
    )
  }

  string toString() {
    this = TJustSubObject(_) and result = "tracked subobject"
    or
    exists(BoundedIndex index |
      this = TContainerElementSubObject(_, index) and
      result = "tracked container element " + index.toString()
    )
  }
}

/**
 * A recap of the rule:
 * - Writes to objects must be observed, either directly or indirectly through pointers/references.
 * - Observing any part of an object or container is considered to observe the whole object.
 * - Writes may not immediately follow other writes without a read in between.
 * - The rule text states that the above cases must occur on every feasible path to be considered
 *   a violation.
 * - Objects that have non trivial destructors or containers of objects with non-trivial destructors
 *   are exempt.
 *
 * Note that the rule has provides an example that may be considered contradictory:
 *
 * ```c
 *   int m;
 *   for ( ... ) {
 *     m = 10;
 *     m++;
 *   }
 *   return m;
 * ```
 *
 * Here, each write to `m` has a feasible path to an observation (the return), but the rule states
 * that the assignment (`m = 10;`) is non compliant as it overwrites the value from the previous
 * iteration.
 *
 * It's unclear what part of the CFG indicates that the assignment is non compliant. The write to
 * `m` via increment is not postdominated by an overwrite, and the overwrite does not dominate the
 * increment. The clearest explanation is that this is assuming the loop is unrolled, but we do not
 * attempt to model that here.
 */
predicate isRead(TrackedObject object, CrementAwareNode cfn) {
  cfn.asExprRead() = object.getAnAccess() and
  not exists(AssignExpr ae | ae.getLValue() = cfn.asExprRead() and ae.getOperator() = "=")
  or
  isObserved(object.getRootIdentity(), cfn)
}

newtype TCrementAwareNode =
  /** A control flow node that does not involve postfix ++ or -- */
  TNonCrementNode(RelevantControlFlowNode n) { not n instanceof PostfixCrementOperation } or
  /**
   * A control flow node representing the value of a crement node as it is at usage site, before
   * being modified.
   */
  TPreCrementNode(CrementOperation n) { n instanceof PostfixCrementOperation } or
  /**
   * A control flow node representing the value of a crement node after its value was modified.
   */
  TPostCrementNode(CrementOperation n) { n instanceof PostfixCrementOperation }

/**
 * A control flow node that distinguishes between the read and write phases of a postfix
 * crement operation like `i++` or `i--`.
 */
class CrementAwareNode extends TCrementAwareNode {
  /** The underlying control flow node. */
  RelevantControlFlowNode n;

  CrementAwareNode() {
    this = TNonCrementNode(n)
    or
    this = TPreCrementNode(n)
    or
    this = TPostCrementNode(n)
  }

  /**
   * Whether this node represents the beginning of a control flow node.
   *
   * For non-crement nodes, this is always true. For crement nodes, this holds for the "pre-crement"
   * node only.
   */
  predicate beginsControlFlowNode() {
    this = TNonCrementNode(_) or
    this = TPreCrementNode(_)
  }

  /** Gets the underlying control flow node. */
  RelevantControlFlowNode getControlFlowNode() { result = n }

  /**
   * Gets the successor node in the control flow graph, accounting for crement nodes.
   */
  CrementAwareNode getASuccessor() {
    if this = TPreCrementNode(n)
    then result = TPostCrementNode(n)
    else (
      result.beginsControlFlowNode() and
      result.getControlFlowNode() = n.getASuccessor()
    )
  }

  /**
   * Can be used to get the crement-aware control flow node for a given expression, treated as a
   * read operation.
   *
   * For non-crement expressions, this is just the expression itself. For crement expressions, this
   * is the "pre-crement" node, and does not hold for the "post-crement" node.
   */
  Expr asExprRead() {
    result = this.getControlFlowNode() and
    this.beginsControlFlowNode()
  }

  /**
   * Can be used to get the crement-aware control flow node for a given expression, treated as a
   * write operation.
   *
   * For non-crement expressions, this is just the expression itself. For crement expressions, this
   * is the "post-crement" node, and does not hold for the "pre-crement" node.
   */
  Expr asExprWrite() {
    // Pre-crement nodes are not writes, and have no result.
    not this = TPreCrementNode(n) and
    result = this.getControlFlowNode()
  }

  string toString() {
    this = TNonCrementNode(_) and result = "non crement node"
    or
    this = TPreCrementNode(_) and result = "pre crement node"
    or
    this = TPostCrementNode(_) and result = "post crement node"
  }

  Location getLocation() { result = getControlFlowNode().getLocation() }
}

predicate isWrite(RelevantObject obj, TrackedObject subObj, CrementAwareNode cfn) {
  subObj.getRootIdentity() = obj and
  (
    cfn.asExprWrite() = obj.(Variable).getInitializer().getExpr() and
    // Parameter initializers are default argument values, not writes.
    not obj instanceof Parameter and
    subObj.representsRootObject()
    or
    exists(AssignExpr ae |
      ae.getLValue() = cfn.asExprWrite() and
      ae.getOperator() = "=" and
      ae.getLValue() = subObj.getAnAccess()
    )
    or
    exists(CrementOperation crement |
      cfn.asExprWrite() = crement and
      crement.getOperand() = subObj.getAnAccess()
    )
  )
}

/**
 * An expression that functions as a condition in a program's control flow.
 *
 * These expressions are control flow nodes that have a "true" and/or "false" successor.
 */
class ConditionalExpr extends Expr {
  RelevantControlFlowNode cfn;

  ConditionalExpr() {
    this = cfn and
    (
      exists(cfn.getAFalseSuccessor())
      or
      exists(cfn.getATrueSuccessor())
    )
  }
}

/**
 * Finds the objects observed via an rvalue expression in an assignment.
 *
 * This is differentiated from `exprIsObserved` so that we can exclude reciprocal assignments, such
 * as `x = x + 1`. This is unique to assignment, note that `return x + 1;` cannot be reciprocal and
 * always observes `x`.
 *
 * This predicate does not find all reciprocal assignments, such as `*(p + 1) = *(p + 1) + 1`. It
 * only finds reciprocal assignments where the lvalue is a direct access to the object, such as
 * `x = x + 1`, `arr[i] = arr[i] + 1`, or `x.field = x.field + 1`, though the lvalue and rvalue may
 * refer to different subobjects of the same root object, such as `x.a = x.b`.
 */
predicate assignmentObservesObject(Assignment assign, RelevantObject object) {
  exists(
    // Objects accessed in an rvalue are observed except for reciprocal assignments.
    Expr rvaluePart
  |
    assign.getRValue() = rvaluePart.getParent*() and
    rvaluePart = object.getASubobjectAccess() and
    // An assignment like x = x + 1 does not observe x.
    not exists(TrackedObject lvalueObj |
      assign.getLValue() = lvalueObj.getAnAccess() and lvalueObj.getRootIdentity() = object
    )
  )
}

/**
 * Finds the certain types of lvalue expressions that indirectly observe their subexpressions.
 *
 * For example, in the expression `*p = 42`, the pointer dereference `*p` observes `p`, and the
 * array index expressions `arr[i] = 42` or `p[i] = 42` observe both `i` and `p`, when `p` is a
 * pointer type.
 *
 * In cases such as `arr[i + 1] = 42`, this predicate holds for the expression `i + 1` but not the
 * inner expression `i`. This is because this predicate does not track which subexpression values
 * ultimately affect the lvalue, or which subexpressions correspond to which objects.
 *
 * This predicate could be more pessimistic in cases such as `p[*p] = p`, which could be said to not
 * observe `p`. However it does not distinguish these cases for simplicity.
 */
predicate assignmentObservesLvalueExpr(Expr assign, Expr observed) {
  exists(Expr lvaluePart, Expr assignBase |
    // Using `getParent*()` is not strictly correct in certain edge cases such as lambda expressions
    // and comma operators, but is sufficient for our purposes here.
    lvaluePart.getParent*() = assignBase and
    (
      assignBase = assign.(Assignment).getLValue()
      or
      // Handle cases like `*p++ = 42;`
      assignBase = assign.(CrementOperation).getOperand()
    ) and
    (
      lvaluePart.(PointerDereferenceExpr).getOperand() = observed
      or
      lvaluePart.(PointerFieldAccess).getQualifier() = observed
      or
      lvaluePart.(ArrayExpr).getArrayOffset() = observed
      or
      lvaluePart.(ArrayExpr).getArrayBase() = observed and
      // An array's address is not part of its value per se, so `x[y]` does not observe `x` when
      // `x` is an array type. However, if `x` is a pointer, then `x[y]` uses its value and thus
      // observes it.
      observed.getType().getUnderlyingType() instanceof PointerType
    )
  )
}

/**
 * By rule definition, an object is observed when its value affects the control flow of the program
 * or its value affects the value external program state.
 *
 * This predicate finds syntactic constructs that induce an observation of an expression, without
 * analyzing the observed subexpressions or which subexpressions may be from which objects.
 */
predicate exprIsObserved(Expr e) {
  e instanceof ConditionalExpr
  or
  exists(SwitchStmt switch | switch.getControllingExpr() = e)
  or
  exists(Initializer i | i.getExpr() = e)
  or
  assignmentObservesLvalueExpr(_, e)
  or
  exists(Call c, Expr arg |
    c.getAnArgument() = arg and
    arg = e
  )
  or
  exists(Call c |
    c.getQualifier() = e and
    // Exclude container element lookup calls, as those do not observe the container.
    not exists(STLContainer container |
      container = c.getQualifier().getType() and
      c instanceof STLContainerIndexAccess
    ) and
    // Exclude destructor calls, as those do not observe the object, which is either a trivially
    // destructible type or a container.
    not c instanceof DestructorCall
  )
  or
  exists(ExprCall ec | ec.getExpr() = e)
  or
  exists(ReturnStmt rs | rs.getExpr() = e)
  or
  exists(ThrowExpr ts | ts.getExpr() = e)
  or
  exists(DeleteExpr de | de.getExpr() = e)
}

predicate childExprTaintStep(Expr child, Expr parent) {
  parent.(Operation).getAnOperand() = child
  or
  parent.(ArrayExpr).getArrayBase() = child
  or
  parent.(ArrayExpr).getArrayOffset() = child
  or
  parent.(AggregateLiteral).getAChild() = child
  or
  // We need this to model containers, where vec.at(i) is tainted by vec.
  parent.(Call).getQualifier() = child
  or
  // a->b is tainted by a.
  // We don't model a.b tainting b, because the 'SubObject' captures this relationship.
  parent.(PointerFieldAccess).getQualifier() = child
}

predicate isObserved(RelevantObject obj, CrementAwareNode cfn) {
  exists(Expr directlyObservedExpr, Expr accessExpr |
    cfn.asExprRead() = directlyObservedExpr and
    accessExpr = obj.getASubobjectAccess() and
    childExprTaintStep*(accessExpr, directlyObservedExpr) and
    exprIsObserved(directlyObservedExpr)
  )
  or
  assignmentObservesObject(cfn.asExprWrite(), obj)
}

/**
 * Writes that occur after taking the address of or a reference to a subobject are excluded from
 * consideration, as the address/reference may be used later to observe the object.
 *
 * This could be tracked more precisely in the future, however, for the moment this case is simply
 * excluded.
 */
predicate isExcludedWrite(RelevantControlFlowNode node, RelevantObject obj) {
  node.getAPredecessor+() = [obj.getASubobjectAddressExpr(), obj.getASubobjectTakenAsReference()]
}

module WriteWithReadConfig implements FeasiblePathConfigSig {
  class State = TrackedObject;

  class Node = CrementAwareNode;

  predicate isStart(TrackedObject state, CrementAwareNode node) {
    exists(RelevantObject rootObj |
      isWrite(rootObj, state, node) and
      not isExcludedWrite(node.getControlFlowNode(), rootObj)
    )
  }

  predicate isExcludedPath(TrackedObject state, CrementAwareNode node) {
    exists(TrackedObject rewritten |
      rewritten = state.getParent*() and
      isWrite(_, rewritten, node) and
      // Don't stop at writes to imprecise subobjects, as they may overlap.
      state.isPrecise()
      or
      isWrite(_, rewritten, node) and
      rewritten.mustOverlap(state)
    )
  }

  predicate isEnd(TrackedObject obj, CrementAwareNode node) {
    exists(TrackedObject readObj |
      isRead(readObj, node) and
      readObj.mayOverlap(obj)
    )
  }
}

predicate isWriteWithRead = FeasiblePath<WriteWithReadConfig>::isSuccessor/3;

predicate isWriteWithObserve(RelevantObject obj, CrementAwareNode node) {
  isWrite(obj, _, node) and
  isObserved(obj, node.getASuccessor*()) and
  not isExcludedWrite(node.getControlFlowNode(), obj)
}

from
  RelevantControlFlowNode cfn, CrementAwareNode crementNode, RelevantObject obj, string explanation
where
  not isExcluded(cfn, DeadCode5Package::unnecessaryWriteToLocalObjectQuery()) and
  // Exclude macro expansions, with variables that may be unused only in certain expansions.
  not cfn.isInMacroExpansion() and
  // Exclude compiler generated variables and nodes.
  not cfn.(Expr).isCompilerGenerated() and
  not obj.(Variable).isCompilerGenerated() and
  // Exclude variables with no enclosing element, indicating odd cases such as structured bindings
  // where CodeQL modeling is incomplete.
  exists(obj.getEnclosingElement()) and
  crementNode.getControlFlowNode() = cfn and
  exists(TrackedObject subObj |
    isWrite(obj, subObj, crementNode) and not isExcludedWrite(cfn, obj)
  |
    if not isWriteWithObserve(obj, crementNode)
    then explanation = "is never observed"
    else
      if not isWriteWithRead(subObj, crementNode, _)
      then explanation = "is not read before subsequent writes"
      else none()
  )
select cfn, "Unnecessary write to object $@ " + explanation + ".", obj, obj.toString()
