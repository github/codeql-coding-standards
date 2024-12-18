/**
 * Provides the Uninitialized Field query as a library. This allows queries to customize how alerts
 * should be rendered by extending class `LinkableElement`. The main predicate for the query is named
 * `uninitializedFieldQuery`.
 */

import cpp
private import semmle.code.cpp.dataflow.DataFlow
private import semmle.code.cpp.controlflow.SubBasicBlocks
private import semmle.code.cpp.padding.Padding as Padding
private import semmle.code.cpp.dataflow.internal.FlowVar
private import TrustBoundary

/**
 * A local variable of struct type that is not initialized.
 */
private class UninitializedStructVar extends LocalVariable {
  Struct struct;

  UninitializedStructVar() {
    not this.isStatic() and
    not this.hasInitializer() and
    this.getType().getUnspecifiedType() = struct and
    // Assert that all members are declared in the same file, to avoid structs
    // with preprocessor-confused members.
    exists(File file |
      struct.getFile() = file and
      forall(Field f | struct.getAField() = f | f.getFile() = file)
    )
  }

  Struct getStructType() { result = struct }

  DataFlow::Node asSourceNode() { result.asUninitialized() = this }
}

/**
 * Gets a maximum number of padding bytes contained in `struct` on some
 * architecture we support, yielding no result for structs that are not
 * supported by the padding library. Unsupported structs are those that use
 * virtual member functions, virtual inheritance, or multiple inheritance.
 *
 * The result does not include the padding that may exist in sub-structs of
 * `struct`.
 */
private int getANumberOfPaddingBytes(Struct struct) {
  if struct.getAnAttribute().hasName("packed")
  then result = 0
  else
    exists(Padding::Architecture arch |
      result = arch.wastedSpace(struct) / 8 and
      result >= 0 // can happen due to preprocessor confusion
    )
}

/**
 * Provides an overapproximation, using a simple data flow analysis, of which
 * sources (`UninitializedStructVar`) may reach which sinks
 * (`InformationLeakBoundary`).
 */
private module Pass1 {
  /**
   * A node that has additional data flow into it for the purpose of this
   * analysis.
   */
  class NodeWithAdditionalFlow extends DataFlow::Node {
    Expr eFrom;

    NodeWithAdditionalFlow() {
      exists(Expr eTo | eTo = this.asExpr() |
        eTo.(AddressOfExpr).getOperand() = eFrom
        or
        eTo.(ArrayExpr).getArrayBase() = eFrom
        or
        eTo.(FieldAccess).getQualifier() = eFrom
      )
      or
      // This simplistic approach to interprocedural flow mirrors what we do in
      // `Pass2`.
      exists(FunctionCall call, int i |
        call.getArgument(i) = eFrom and
        call.getTarget().getParameter(i) = this.asParameter()
      )
    }

    /** Gets the node from which data flows into `this` in one step. */
    DataFlow::Node getNodeFrom() { result.asExpr() = eFrom }
  }

  private predicate isBarrier(DataFlow::Node nodeTo) {
    // Flow through fields and globals tends to cause too many false positives
    // in this analysis.
    exists(VariableAccess va |
      nodeTo.asExpr() = va and
      not va.getTarget() instanceof StackVariable
    )
  }

  predicate step(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    (
      DataFlow::localFlowStep(nodeFrom, nodeTo)
      or
      nodeFrom = nodeTo.(NodeWithAdditionalFlow).getNodeFrom()
    ) and
    // Flow through fields gives too many false positives
    not isBarrier(nodeTo) and
    // Once we're at a sink, there's no need to search further
    not nodeFrom.asExpr() instanceof InformationLeakBoundary
  }

  predicate sourceReaches(UninitializedStructVar source, DataFlow::Node node) {
    node = source.asSourceNode()
    or
    exists(DataFlow::Node prev |
      sourceReaches(source, prev) and
      step(prev, node)
    )
  }

  predicate sourceSink(UninitializedStructVar source, InformationLeakBoundary sink) {
    sourceReaches(source, DataFlow::exprNode(sink))
  }

  /** Holds if `node` is involved in data flow from any source to any sink. */
  predicate nodeInFlow(DataFlow::Node node) {
    // Start with the sinks that were reached and follow data-flow edges
    // backwards, staying within the set of nodes reachable from any source.
    sourceSink(_, node.asExpr())
    or
    exists(DataFlow::Node next |
      nodeInFlow(next) and
      step(node, next) and
      sourceReaches(_, node)
    )
  }
}

/* module Pass1 */
/** See class `Projection` and its subclasses. */
private newtype TProjection =
  TRootProjection(Struct s) {
    exists(UninitializedStructVar source |
      Pass1::sourceSink(source, _) and
      s = source.getStructType()
    )
  } or
  TFieldProjection(Projection parent, Field f) {
    parent.getType().(Struct) = f.getDeclaringType() and
    // We only create projections for fields that must be written to, and there
    // is no need to write to a zero-sized field -- it can leak 0 bytes of
    // information. Zero-sized types are a GCC C extension.
    not f.getType().getSize() = 0
  } or
  TArrayElementsProjection(Projection parent, Type type) {
    type = parent.getType().(ArrayType).getBaseType()
  } or
  TBaseClassProjection(Projection parent, ClassDerivation derivation) {
    parent.getType().(Struct) = derivation.getDerivedClass()
  } or
  TPaddingProjection(Projection parent) {
    exists(Struct t |
      t = parent.getType() and
      // This struct has padding or is not supported by the padding library
      not max(getANumberOfPaddingBytes(t)) = 0
    )
  }

/**
 * A conceptual tree of addressable locations in a struct type. The root is the
 * type of a struct we're interested in tracking, and the children of each node
 * typically represent the fields of a struct.
 *
 * As a running example, we'll use the following declaration of a local
 * variable `s`:
 *
 * ```
 * struct {
 *     int a;
 *     struct {
 *         int b1;
 *         struct {
 *             int b2a;
 *             int b2b;
 *         } b2;
 *     } b;
 * } s;
 * ```
 *
 * The type of `s` can be visualized as follows, where each box is a
 * `Projection`. The leftmost box is the `RootProjection`, and the other boxes
 * are `FieldProjection`s. The `Projection::getParent` predicate will give the
 * box immediately to the left.
 *
 * ```
 * +--+--+
 * |  |a | .a
 * |  +--+--+
 * |  |b |b1| .b.b1
 * |  |  +--+---+
 * |  |  |b2|b2a| .b.b2.b2a
 * |  |  |  +---+
 * |  |  |  |b2b| .b.b2.b2b
 * +--+--+--+---+
 * ```
 *
 * In addition to projections for the root and fields, there are also
 * projections for array elements, base class subobjects, and struct padding.
 */
private class Projection extends TProjection {
  /**
   * Gets the type of the right-most component of this projection.
   */
  final Type getType() {
    // Implemented without dynamic dispatch, to avoid the type checker flagging
    // it as non-monotonic recursion.
    this = TRootProjection(result)
    or
    exists(Field field |
      this = TFieldProjection(_, field) and
      result = field.getType().getUnspecifiedType()
    )
    or
    this = TArrayElementsProjection(_, result)
    or
    exists(ClassDerivation derivation |
      this = TBaseClassProjection(_, derivation) and
      result = derivation.getBaseClass()
    )
  }

  /**
   * Gets an expression that, if written to as an lvalue, will overwrite the
   * data in this projection of `root`, where `root` is an _access_ to the
   * `RootProjection` of this projection.
   *
   * For example, given the statement `s.x = 0`, the projection representing
   * field `x` in the type of `s` with have the `FieldAccess` to `s.x` as an
   * _access_, whose `root` is the `VariableAccess` to `s`.
   */
  Expr getAnAccess(VariableAccess root) { none() } // overridden in subclasses

  /**
   * Gets the parent of this projection, which typically represents a compound
   * type that contains this projection.
   */
  Projection getParent() { none() } // overridden in subclasses

  /** Gets a descriptive string for alert messages. */
  string toString() { none() } // overridden in subclasses

  /** Gets an element that's appropriate to link to in alert messages. */
  Element getElement() { none() } // overridden in subclasses

  /** This is the inverse of `getParent`. */
  final Projection getAChild() { result.getParent() = this }

  /**
   * Gets the `RootProjection` that is at the end of the chain of parent
   * projections.
   */
  final RootProjection getRoot() { result = this.getParent*() }
}

/**
 * A struct type of a local variable that may reach an information-leak
 * boundary.
 */
private class RootProjection extends Projection {
  Struct struct;

  RootProjection() { this = TRootProjection(struct) }

  override VariableAccess getAnAccess(VariableAccess root) {
    root = result and
    exists(UninitializedStructVar source |
      source.getStructType() = struct and
      Pass1::sourceSink(source, _) and
      Pass1::sourceReaches(source, DataFlow::exprNode(result))
    )
  }

  override Projection getParent() { none() }

  override string toString() { result = struct.getName() }

  override Element getElement() { result = struct }
}

/**
 * An addressable location of a field inside a parent projection.
 */
private class FieldProjection extends Projection {
  Projection parent;
  Field field;

  FieldProjection() { this = TFieldProjection(parent, field) }

  override FieldAccess getAnAccess(VariableAccess root) {
    result.getQualifier() = parent.getAnAccess(root) and
    result.getTarget() = field
  }

  override Projection getParent() { result = parent }

  override string toString() { result = field.getName() }

  override Element getElement() { result = field }
}

/**
 * A conceptual location representing all elements within an array. Ideally,
 * each element should have a separate projection, just like we represent each
 * field of a struct with a separate projection, but this would be a
 * combinatorial explosion if done naively. Instead, we pretend that a write to
 * any array element will write to all of them.
 */
private class ArrayElementsProjection extends Projection {
  Projection parent;

  ArrayElementsProjection() { this = TArrayElementsProjection(parent, _) }

  override ArrayExpr getAnAccess(VariableAccess root) {
    result.getArrayBase() = parent.getAnAccess(root)
  }

  override Projection getParent() { result = parent }

  override string toString() { result = "elements of " + parent.toString() + "[...]" }

  override Element getElement() { result = parent.getElement() }
}

/**
 * An addressable location of a base class subobject inside a parent
 * projection. This is almost like a field, except that there is no syntax
 * in the AST for accessing these objects, so we pretend that they are accessed
 * exactly when their parent projections are accessed.
 */
private class BaseClassProjection extends Projection {
  Projection parent;
  ClassDerivation derivation;

  BaseClassProjection() { this = TBaseClassProjection(parent, derivation) }

  override VariableAccess getAnAccess(VariableAccess root) { result = parent.getAnAccess(root) }

  override Projection getParent() { result = parent }

  override string toString() {
    result = "base " + derivation.getBaseClass().getName() + " of " + parent.toString()
  }

  override Element getElement() { result = derivation }
}

/**
 * A projection that represents all the padding bytes in a struct. Padding
 * behaves much like a field that cannot be written to directly. The only way
 * to overwite this projection is to overwrite one of its parents; in the
 * program, that corresponds to `memset`ing the entire struct.
 */
private class PaddingProjection extends Projection {
  Projection parent;

  PaddingProjection() { this = TPaddingProjection(parent) }

  override VariableAccess getAnAccess(VariableAccess root) { result = parent.getAnAccess(root) }

  override Projection getParent() { result = parent }

  override string toString() {
    exists(Struct t |
      t = parent.getType() and
      if exists(getANumberOfPaddingBytes(t))
      then
        result =
          min(getANumberOfPaddingBytes(t)) + " to " + max(getANumberOfPaddingBytes(t)) +
            " bytes of padding in " + parent.toString()
      else
        // This struct is not supported by our padding library. It may contain
        // padding bytes or virtual-pointers.
        result = "unknown padding in " + parent.toString()
    )
  }

  override Element getElement() { result = parent.getElement() }
}

/**
 * Provides predicates for determining the control-flow nodes where projections
 * are overwritten.
 */
private module Overwrite {
  /**
   * Holds if the known library function `name` will overwrite argument number
   * `dstArg` with the number of bytes passed into argument number `sizeArg`.
   */
  private predicate functionOverwritesArray(string name, int dstArg, int sizeArg) {
    name = "bzero" and dstArg = 0 and sizeArg = 1
    or
    name = "bcopy" and dstArg = 1 and sizeArg = 2
    or
    name = "RtlZeroMemory" and dstArg = 0 and sizeArg = 1
    or
    name = "RtlCopyMemory" and dstArg = 0 and sizeArg = 2
    or
    // strncpy overwrites the rest of the buffer with zeros, unlike strcpy and
    // the sprintf family of functions.
    name = "strncpy" and dstArg = 0 and sizeArg = 2
    or
    name = "memset" and dstArg = 0 and sizeArg = 2
    or
    name = "memcpy" and dstArg = 0 and sizeArg = 2
    or
    name = "__builtin___memcpy_chk" and dstArg = 0 and sizeArg = 2
    or
    name = "__builtin___memmove_chk" and dstArg = 0 and sizeArg = 2
    or
    // The `copyin` and `copy_from_user` functions may not overwrite `dstArg`
    // if they fail. It is therefore crucial to check their return value.
    // Making sure that happens should probably be a separate query, though.
    name = "copyin" and dstArg = 1 and sizeArg = 2
    or
    name = "copy_from_user" and dstArg = 0 and sizeArg = 2
  }

  /**
   * Holds if `call` invokes a known library function that will overwrite what
   * `addressArg` points to with `size` bytes.
   */
  private predicate libraryCallOverwrites(FunctionCall call, Expr addressArg, Expr sizeArg) {
    exists(int dstIdx, int sizeIdx |
      functionOverwritesArray(call.getTarget().getName(), dstIdx, sizeIdx) and
      addressArg = call.getArgument(dstIdx) and
      sizeArg = call.getArgument(sizeIdx)
    )
  }

  /**
   * Holds if `call` passes `arg` as a pointer to non-const struct, and the
   * target of `call` is a function whose implementation is unknown. To avoid
   * false positives around calls to unknown libraries, We assume that such a
   * call will overwrite `arg`. Calls to less specific functions, like those
   * taking a `char *` parameter, are instead handled by
   * `libraryCallOverwrites`, which also takes a size argument into account.
   */
  private predicate externalCallCouldOverwrite(FunctionCall call, Expr arg) {
    exists(Function f, int i |
      f = call.getTarget() and
      not exists(f.getBlock()) and
      arg = call.getArgument(i) and
      exists(PointerType pt |
        pt = f.getParameter(i).getType().getUnderlyingType() and
        pt.getBaseType().getUnspecifiedType() instanceof Struct and
        not pt.getBaseType().isConst()
      )
    ) and
    // This makes sure we don't consider a value to be overwritten, and thus
    // safe, at exactly the point where it leaks.
    not arg instanceof InformationLeakBoundary
  }

  /**
   * Gets an expression that represents the address of `lvalue` if used in a
   * function argument context, either with an explicit `AddressOfExpr` or by
   * an implicit decay of an array type to a pointer type.
   */
  Expr addressOfOrDecay(Expr lvalue) {
    // An array can decay into a pointer
    lvalue.getType().getUnspecifiedType() instanceof ArrayType and
    result = lvalue
    or
    // But all other types need their address taken explicitly.
    result.(AddressOfExpr).getOperand() = lvalue
    // It's possible that we could support C++ references here by adding a
    // third case for when the fully-converted expression has reference type.
  }

  /**
   * Holds if the evaluation of `cfn` will completely overwrite lvalue stored
   * at the projection `prj` from `root` or, if `root` is a `VariableAccess` to
   * a pointer, the value it points to.
   */
  predicate overwrite(VariableAccess root, Projection prj, ControlFlowNode cfn) {
    exists(Expr e, int size |
      e = prj.getAnAccess(root) and
      // If `sizeArg` is a constant, meaning `sizeArg.getValue()` exists, then
      // we require an exact match. Otherwise we assume that the size is
      // correct since this query offers no means to check it.
      size = prj.getType().getSize() and
      if
        e = root and
        e.getType().getUnspecifiedType() instanceof PointerType
      then (
        // Special cases for pointer to root for now
        exists(Expr sizeArg |
          libraryCallOverwrites(cfn, e, sizeArg) and
          not sizeArg.getValue().toInt() != size
        )
        or
        externalCallCouldOverwrite(cfn, e)
        or
        cfn = any(AssignExpr assign | assign.getLValue().(PointerDereferenceExpr).getOperand() = e)
      ) else (
        exists(Expr sizeArg |
          libraryCallOverwrites(cfn, addressOfOrDecay(e), sizeArg) and
          not sizeArg.getValue().toInt() != size
        )
        or
        externalCallCouldOverwrite(cfn, addressOfOrDecay(e))
        or
        cfn = any(AssignExpr assign | assign.getLValue() = e)
      )
    )
  }
}

/* module Overwrite */
/**
 * Contains predicates for computing which `Projection`s should have their
 * assignments tracked. We want to track as few projections as possible for the
 * sake of performance and to some extent for the sake of alert message
 * brevity.
 */
private module ProjectionTracking {
  /*
   * The documentation of the internals of this module continues from the
   * example declaration of `s` in the documentation of class `Projection`.
   *
   * Assume that the program contains the following statements affecting `s`
   * (not necessarily in sequence).
   *
   *   s.a = 1;
   *   memset(&s.b, 0, sizeof s.b);
   *   s.b.b1 = 1;
   *   memset(&s.b.b2, 0, sizeof s.b.b2);
   *   s.b.b2.b2b = 1;
   *
   * In words, every field is fully overwritten except `b2a`. Because `b2a` is
   * never overwritten, we may ignore writes to its sibling field `b2b`: they
   * will never matter for the purpose of overwriting all of `s`. The
   * predicates in this module will essentially compute that we should track
   * the right-most projections we cannot ignore.
   */

  /**
   * Holds if the program contains the necessary code to completely overwrite
   * `prj`, either directly or by overwriting all its components. This is a
   * coarse overapproximation, pretending that all references to `prj` in the
   * program may alias.
   *
   * For our running example, the following diagram illustrates this predicate,
   * where the marked boxes are the projections accepted by this predicate.
   *
   * ```
   *   +--+--+
   *   |  |##| .a
   *   |  +--+--+
   *   |  |##|##| .b.b1
   *   |  |##+--+--+
   *   |  |##|##|  | .b.b2.b2a
   *   |  |##|##+--+
   *   |  |##|##|##| .b.b2.b2b
   *   +--+--+--+--+
   * ```
   */
  predicate canBeOverwritten(Projection prj) {
    Overwrite::overwrite(_, prj, _)
    or
    canBeCoveredByWrites(prj)
  }

  /**
   * Holds if it is possible to overwrite `prj` by overwriting its individual
   * fields. This predicate only holds if `prj` is a compound type.
   *
   * For our running example, the following diagram illustrates this predicate,
   * where the marked boxes are the projections accepted by this predicate.
   *
   * ```
   *   +--+--+
   *   |##|  | .a
   *   |##+--+--+
   *   |##|##|  | .b.b1
   *   |##|##+--+--+
   *   |##|##|  |  | .b.b2.b2a
   *   |##|##|  +--+
   *   |##|##|  |  | .b.b2.b2b
   *   +--+--+--+--+
   * ```
   */
  private predicate canBeCoveredByWrites(Projection prj) {
    forex(Projection child | child = prj.getAChild() | canBeOverwritten(child))
  }

  /**
   * Holds if overwriting `prj` may contribute toward overwriting its root
   * projection -- whether or an overwrite of `prj` actually exists in the
   * program.
   *
   * For our running example, the following diagram illustrates this predicate,
   * where the marked boxes are the projections accepted by this predicate. The
   * projection of `b2a` is not accepted because it has no writes, while `b2b`
   * is not accepted because its sibling `b2a` has no writes.
   *
   * ```
   *   +--+--+
   *   |##|##| .a
   *   |##+--+--+
   *   |##|##|##| .b.b1
   *   |##|##+--+---+
   *   |##|##|##|   | .b.b2.b2a
   *   |##|##|##+---+
   *   |##|##|##|   | .b.b2.b2b
   *   +--+--+--+---+
   * ```
   */
  private predicate writesShouldNotBeIgnored(Projection prj) {
    prj instanceof RootProjection
    or
    exists(Projection parent |
      parent = prj.getParent() and
      writesShouldNotBeIgnored(parent) and
      canBeCoveredByWrites(parent)
    )
  }

  /**
   * Holds if `prj` is a right-most projection whose writes should not be
   * ignored. These are the projections we want to track.
   *
   * For our running example, the following diagram illustrates this predicate,
   * where the marked boxes are the projections accepted by this predicate. A
   * write to a projection on the _right_ of a tracked projection will be
   * ignored. A write to a projection on the _left_ of a tracked projection
   * will be tracked as a write to each of its transitive children that are
   * tracked.
   *
   * ```
   *   +--+--+
   *   |  |##| .a
   *   |  +--+--+
   *   |  |  |##| .b.b1
   *   |  |  +--+---+
   *   |  |  |##|   | .b.b2.b2a
   *   |  |  |##+---+
   *   |  |  |##|   | .b.b2.b2b
   *   +--+--+--+---+
   * ```
   */
  predicate shouldBeTracked(Projection prj) {
    writesShouldNotBeIgnored(prj) and
    not writesShouldNotBeIgnored(prj.getAChild())
  }
}

/* module ProjectionTracking */
/**
 * A `Projection` that should be tracked in the following analysis because the
 * right assignments to this projection, and other tracked projections, can
 * make us consider some struct to be initialized.
 */
private class TrackedProjection extends Projection {
  TrackedProjection() { ProjectionTracking::shouldBeTracked(this) }

  /**
   * Holds if the evaluation of `cfn` will completely overwrite lvalue
   * stored at `this` from `root` or, if `root` is a `VariableAccess` to a
   * pointer, the value it points to.
   */
  predicate overwritten(Expr root, ControlFlowNode cfn) {
    Overwrite::overwrite(root, this.getParent*(), cfn)
  }
}

/**
 * Provides predicates for finding which function calls always overwrite some
 * projection of some argument.
 */
private module CallSideEffects {
  /**
   * Holds if the involved types do not rule out that the projection `prj` of
   * `p` is always overwritten before the function of `p` returns.
   *
   * This predicate keeps the base case of the recursion at a manageable size.
   * To handle both loops and recursion correctly, most predicates in this
   * module compute a negatively phrased property: "this code _does not_
   * overwrite (p, prj)". In principle, it's correct to say that practically
   * all functions do not overwrite practically all parameters with respect to
   * all projections, but that would be too many facts to enumerate. This
   * predicate is used as context in base cases to make sure the recursive
   * predicates only compute facts about combinations that might have an effect
   * on the overall query.
   */
  private predicate interestingParameter(Parameter p, TrackedProjection prj) {
    exists(UninitializedStructVar source |
      Pass1::sourceReaches(source, DataFlow::parameterNode(p)) and
      source.getStructType() = prj.getRoot().getType() and
      // Pointers to const are not interesting
      not p.getType().(PointerType).getBaseType().isConst() and
      // References to const are not interesting
      not p.getType().(ReferenceType).getBaseType().isConst()
    )
  }

  /**
   * Holds if the involved types do not rule out that `call` might always
   * overwrite the projection `prj` of `arg`. See `interestingParameter`.
   */
  predicate interestingCall(FunctionCall call, Expr arg, TrackedProjection prj) {
    exists(Parameter p, int i |
      p = call.getTarget().getParameter(i) and
      arg = call.getArgument(i) and
      interestingParameter(p, prj)
    )
  }

  private class InterestingCallCutNode extends SubBasicBlockCutNode {
    InterestingCallCutNode() {
      // We cut the basic blocks at the arguments rather than the call. This is
      // technically wrong but allows us to handle functions that have side
      // effects on more than one argument without an expensive `forall`.
      interestingCall(_, this, _)
    }
  }

  /** Holds if evaluating `va` will yield the value passed into `p`. */
  private predicate parameterReaches(Parameter p, VariableAccess va) {
    interestingParameter(p, _) and
    DataFlow::localFlow(DataFlow::parameterNode(p), DataFlow::exprNode(va))
  }

  /**
   * Holds if `sbb`, in isolation, directly overwrites projection `prj` of `p`.
   * This does not include overwrites due to calling functions with side
   * effects.
   */
  private predicate sbbAlwaysOverwrites(SubBasicBlock sbb, Parameter p, TrackedProjection prj) {
    exists(VariableAccess pAccess |
      parameterReaches(p, pAccess) and
      prj.overwritten(pAccess, sbb.getANode())
    )
  }

  /**
   * Holds if control flow can reach `sbb` from the entry point of `p`'s
   * function without passing through a control-flow node that overwrites `prj`
   * of `p`, either directly or by calling a function that does this.
   */
  private predicate sbbReachableWithoutOverwrite(
    SubBasicBlock sbb, Parameter p, TrackedProjection prj
  ) {
    (
      interestingParameter(p, prj) and
      sbb.getStart() = p.getFunction().getEntryPoint()
      or
      sbbReachableWithoutOverwrite(sbb.getAPredecessor(), p, prj)
    ) and
    (
      not sbbAlwaysOverwrites(sbb, p, prj) and
      // While computing this predicate, block reachability at all calls that
      // may potentially overwrite `prj` of `p` until it has been recursively
      // found that there is a path through the call target that does not
      // overwrite `prj` of `p`. When that has been found, the reachability
      // will be allowed by the `callMayNotOverwrite` case below.
      not interestingCall(_, sbb, prj)
      or
      // Because `InterestingCallCutNode` cuts the basic blocks at call
      // _arguments_, we pass `sbb` into the `arg` parameter of
      // `callMayNotOverwrite`.
      callMayNotOverwrite(_, sbb, prj)
    )
  }

  /** Holds if `p`'s function may return without overwriting `prj` of `p`. */
  private predicate parameterMayNotBeOverwritten(Parameter p, TrackedProjection prj) {
    exists(SubBasicBlock lastSBB |
      lastSBB.getEnd() = p.getFunction() and // exit node is function itself
      sbbReachableWithoutOverwrite(lastSBB, p, prj)
    )
  }

  /** Holds if `call` may not overwrite `prj` of `arg`. */
  private predicate callMayNotOverwrite(FunctionCall call, Expr arg, TrackedProjection prj) {
    exists(Parameter p, int i |
      p = call.getTarget().getParameter(i) and
      arg = call.getArgument(i) and
      parameterMayNotBeOverwritten(p, prj)
    )
  }

  /**
   * Holds if `call` always overwrites the projection `prj` of `arg`.
   */
  predicate callAlwaysOverwrites(FunctionCall call, Expr arg, TrackedProjection prj) {
    interestingCall(call, arg, prj) and
    (
      not callMayNotOverwrite(call, arg, prj)
      or
      // It is a common pattern that a function returns a status code and has
      // only initialized the passed-in struct if that status code is some true
      // value. Until this query can model the passing and checking of such
      // status codes, we pretend that all addressable projections are
      // overwritten in calls where a status code appears to be involved.
      not call.getParent() instanceof ExprStmt
    )
  }
}

/* module CallSideEffects */
/**
 * Provides a precise analysis of which sources (`UninitializedStructVar`) may
 * reach which sinks (`InformationLeakBoundary`).
 */
private module Pass2 {
  private Expr getAStructPointerExpr(FlowVar var) {
    result.getType().getUnspecifiedType() instanceof PointerType and
    result = var.getAnAccess()
    or
    exists(UninitializedStructVar v |
      var.definedByInitialValue(v) and
      result.(AddressOfExpr).getOperand().(VariableAccess).getTarget() = v
    )
  }

  /**
   * An extension of `SubBasicBlockCutNode` to ensure that all control-flow
   * nodes relevant to `overwrittenAtSBB` are placed at the beginning of a
   * `SubBasicBlock`.
   */
  private class OverwriteCutNode extends SubBasicBlockCutNode {
    OverwriteCutNode() {
      exists(TrackedProjection prj, VariableAccess va | prj.overwritten(va, this))
      or
      // This case handles both calls that might have side effects and calls
      // where leaks might happen. Calls of the former type need to begin a new
      // SBB to get sequencing of side effects right. Calls of the latter type
      // need to begin a new SBB to make sure they are not part of the SBB
      // containing the source because uninitialized fields propagate from an
      // SBB _before_ the call rather than the SBB of the call itself.
      exists(Expr reachedArg |
        Pass1::sourceReaches(_, DataFlow::exprNode(reachedArg)) and
        reachedArg = this.(FunctionCall).getAnArgument()
      )
      or
      // This ensures that reaching a sink always adds an extra `Node`
      // and does not get tangled up with sources or possible overwrites.
      this instanceof InformationLeakBoundary
    }
  }

  /**
   * Holds if the tracked projection `prj` of `var` is overwritten in `sbb`.
   *
   * Example: `memset(&s, 0, sizeof s)` would have `var` as `s` and `prj` as
   * either the type of `s` or some set of fields covering `s`.
   */
  private predicate overwrittenAtSBB(SubBasicBlock sbb, FlowVar var, TrackedProjection prj) {
    prj.overwritten(var.getAnAccess(), sbb)
    or
    CallSideEffects::callAlwaysOverwrites(sbb, Overwrite::addressOfOrDecay(var.getAnAccess()), prj)
  }

  /** See `Node`. */
  private newtype TNode =
    MakeNode(SubBasicBlock sbb, FlowVar var, TrackedProjection prj) {
      sourceNode(_, sbb, var, prj)
      or
      stepToComponents(_, sbb, var, prj)
    }

  /**
   * A node in the directed graph that witnesses how an
   * `UninitializedStructVar` may reach an `InformationLeakBoundary` without
   * being overwritten. There is a subclass of `Node` for each particularly
   * interesting kind of node: sources, sinks, and interprocedural control
   * flow. Nodes not belonging to these subclasses only serve to propagate
   * reachability of uninitialized data within a function.
   */
  class Node extends TNode {
    string toString() { result = "Pass2::Node" }

    /** Gets a successor in this graph. */
    Node getASuccessor() {
      exists(SubBasicBlock sbb, FlowVar var, TrackedProjection prj |
        result = MakeNode(sbb, var, prj) and
        stepToComponents(this, sbb, var, prj)
      )
    }
  }

  /**
   * Holds if uninitialized data from `source` propagates in one step to
   * `MakeNode(sbb, var, prj)`.
   */
  private predicate sourceNode(
    UninitializedStructVar source, SubBasicBlock sbb, FlowVar var, TrackedProjection prj
  ) {
    Pass1::sourceSink(source, _) and
    var.definedByInitialValue(source) and
    source.getStructType() = prj.getRoot().getType() and
    exists(DeclStmt declStmt |
      source = declStmt.getDeclaration(_) and
      sbb.contains(declStmt)
    ) and
    not overwrittenAtSBB(sbb, var, prj)
  }

  /**
   * Holds if uninitialized data from `prev` propagates in one step to
   * `MakeNode(sbb, var, prj)`. This is the main analysis predicate of this
   * query.
   */
  private predicate stepToComponents(
    Node prev, SubBasicBlock sbb, FlowVar var, TrackedProjection prj
  ) {
    (
      // Propagate to next SBB unless the value is overwritten in it
      exists(SubBasicBlock sbbPrev |
        sbbPrev = sbb.getAPredecessor() and
        prev = MakeNode(sbbPrev, var, prj)
      )
      or
      // Propagate across assignments
      exists(FlowVar varPrev |
        prev = MakeNode(sbb, varPrev, prj) and
        var.definedByExpr(getAStructPointerExpr(varPrev), sbb.getANode())
      )
      or
      // Propagate into calls directly from a previous SBB. This ensures that
      // we propagate into calls even if the function we're calling will
      // eventually overwrite its arguments.
      exists(FunctionCall call, int i, Expr arg, SubBasicBlock sbbPrev, FlowVar varPrev |
        arg = call.getArgument(i) and
        arg = getAStructPointerExpr(varPrev) and
        var.definedByInitialValue(call.getTarget().getParameter(i)) and
        prev = MakeNode(sbbPrev, varPrev, prj) and
        sbbPrev = call.(SubBasicBlock).getAPredecessor() and
        sbb = call.getTarget().getEntryPoint() and
        // Once we're at a sink, there's no need to search further
        not arg instanceof InformationLeakBoundary
      )
    ) and
    not overwrittenAtSBB(sbb, var, prj)
  }

  /** A node that arises from an `UninitializedStructVar`. */
  class SourceNode extends Node {
    UninitializedStructVar source;

    SourceNode() {
      exists(SubBasicBlock sbb, FlowVar var, TrackedProjection prj |
        this = MakeNode(sbb, var, prj) and
        sourceNode(source, sbb, var, prj)
      )
    }

    UninitializedStructVar getSource() { result = source }
  }

  /** A node representing an `InformationLeakBoundary`. */
  class SinkNode extends Node {
    InformationLeakBoundary sink;

    SinkNode() {
      exists(FlowVar var |
        sink = getAStructPointerExpr(var) and
        this = MakeNode(sink, var, _)
      )
    }

    InformationLeakBoundary getSink() { result = sink }
  }

  /**
   * A node representing a parameter that may be instantiated with a pointer to
   * an uninitialized value.
   */
  class OutOfParameterNode extends Node {
    Parameter param;

    OutOfParameterNode() {
      exists(SubBasicBlock sbb, FlowVar var, TrackedProjection prj |
        this = MakeNode(sbb, var, prj) and
        var.definedByInitialValue(param) and
        sbb = param.getFunction().getEntryPoint()
      )
    }

    Parameter getParameter() { result = param }
  }

  /**
   * A node representing a point where a non-const pointer to uninitialized
   * data is passed to a function that does not initialize it.
   */
  class PastCallNode extends Node {
    Parameter param;

    PastCallNode() {
      exists(FlowVar var, TrackedProjection prj, FunctionCall call, int i, Expr arg |
        this = MakeNode(call, var, prj) and
        not overwrittenAtSBB(call, var, prj) and
        CallSideEffects::interestingCall(call, arg, prj) and
        arg = Overwrite::addressOfOrDecay(var.getAnAccess()) and
        arg = call.getArgument(i) and
        param = call.getTarget().getParameter(i)
      )
    }

    Parameter getParameter() { result = param }
  }

  /**
   * Holds if projection `prj` of `source` may reach `sink` without being
   * initialized.
   */
  predicate sourceSink(
    UninitializedStructVar source, InformationLeakBoundary sink, TrackedProjection prj
  ) {
    exists(SourceNode sourceNode, SinkNode sinkNode |
      sourceNode.getSource() = source and
      sinkNode.getSink() = sink and
      sinkNode = MakeNode(_, _, prj) and
      sourceNode.getASuccessor+() = sinkNode
    )
  }
}

/* module Pass2 */
/**
 * An element that can generate a link suitable to some front end for
 * presentation of query results. The default type of link is human-readable
 * text since no form of clickable link works with all front ends.
 */
class LinkableElement extends Element {
  bindingset[text]
  string makeLink(string text) {
    exists(string filename, int startLine |
      filename = this.getFile().getBaseName() and
      startLine = this.getLocation().getStartLine() and
      result = text + " (" + filename + ":" + startLine + ")"
    )
  }
}

/**
 * Decorates `text` such that will be rendered as a link to `e` when used as
 * part of an alert query message. The type of link to be generated can be
 * changed by overriding LinkableElement.
 */
bindingset[text]
private string repr(Element e, string text) { result = e.(LinkableElement).makeLink(text) }

/**
 * Provides human-readable path explanations to help the user understand the
 * alerts.
 */
private module Explanations {
  /** A node that has a human-readable explanation. */
  private class ExplainedNode extends Pass2::Node {
    string explanation;

    ExplainedNode() {
      // Source
      exists(UninitializedStructVar source |
        source = this.(Pass2::SourceNode).getSource() and
        explanation = repr(source, source.toString())
      )
      or
      // Sink
      exists(InformationLeakBoundary sink |
        sink = this.(Pass2::SinkNode).getSink() and
        explanation = repr(sink, sink.toString())
      )
      or
      // Out of parameter
      exists(Parameter param |
        param = this.(Pass2::OutOfParameterNode).getParameter() and
        explanation = repr(param, param.getFunction().getName() + "(...)")
      )
      or
      // Past a non-modifying call
      exists(Parameter param |
        param = this.(Pass2::PastCallNode).getParameter() and
        explanation = "past " + repr(param, param.getFunction().getName())
      )
    }

    string getExplanation() { result = explanation }
  }

  /**
   * Gets `n` itself or a transitive predecessor reachable without passing
   * through another `ExplainedNode`.
   */
  private Pass2::Node selfOrUnexplainedAncestor(ExplainedNode n) {
    result = n
    or
    result.getASuccessor() = selfOrUnexplainedAncestor(n) and
    not result instanceof ExplainedNode
  }

  /**
   * Holds if `n1` and `n2` are adjacent when skipping nodes that are not
   * instances of `ExplainedNode`.
   */
  private predicate bigStep(ExplainedNode n1, ExplainedNode n2) {
    n1.getASuccessor() = selfOrUnexplainedAncestor(n2)
  }

  private predicate isSourceNode(Pass2::SourceNode sourceNode) { any() }

  /**
   * Holds if the shortest distance from `source` to `node` is `dist`.
   */
  private predicate distanceIs(Pass2::SourceNode source, ExplainedNode node, int dist) =
    shortestDistances(isSourceNode/1, bigStep/2)(source, node, dist)

  /**
   * Holds if `node` is on a shortest path from `source` to `sink`, where
   * `distFromSource` is the distance from `source` to `node`.
   */
  private predicate isOnShortestPath(
    Pass2::SourceNode source, ExplainedNode node, Pass2::SinkNode sink, int distFromSource
  ) {
    distanceIs(source, node, distFromSource) and
    (
      node = sink
      or
      exists(ExplainedNode mid |
        isOnShortestPath(source, mid, sink, distFromSource + 1) and
        bigStep(node, mid)
      )
    )
  }

  /**
   * Gets a human-readable representation of the shortest paths from
   * `source` to `sink`.
   */
  private string explainSourceSinkNodes(Pass2::SourceNode source, Pass2::SinkNode sink) {
    exists(int distance |
      distanceIs(source, sink, distance) and
      result =
        concat(int distFromSource |
          distFromSource = [0 .. distance]
        |
          strictconcat(any(ExplainedNode node | isOnShortestPath(source, node, sink, distFromSource))
                    .getExplanation(), ", "
            ), " --> "
          order by
            distFromSource
        )
    )
  }

  /**
   * Gets a human-readable explanation for how some projection of `source` may
   * reach `sink`.
   */
  string explainSourceSink(UninitializedStructVar source, InformationLeakBoundary sink) {
    exists(Pass2::SourceNode sourceNode, Pass2::SinkNode sinkNode |
      sourceNode.getSource() = source and
      sinkNode.getSink() = sink and
      result = explainSourceSinkNodes(sourceNode, sinkNode)
    )
  }
}

/* module Explanations */
/**
 * Provides predicates for giving better guesses at which specific
 * `Projection`s may be the underlying cause of some `TrackedProjection`
 * reaching a sink.
 */
private module ProjectionReconstruction {
  /**
   * Holds if `prj` has both a child that can be overwritten, directly or
   * indirectly, and a child that cannot.
   */
  private predicate partiallyOverwritten(Projection prj) {
    ProjectionTracking::canBeOverwritten(prj.getAChild()) and
    exists(Projection child |
      child = prj.getAChild() and
      not ProjectionTracking::canBeOverwritten(child)
    )
  }

  /**
   * Gets a projection that should be preferred over `prj` for the purpose of
   * explaining why `prj` was not fully initialized. This can be a child of
   * `prj` if this child is among the children of `prj` never written to. This
   * replacement iterates through children, so it may also be a grandchild and
   * so on.
   *
   * For example, if `prj` is a struct with padding, and the program (globally)
   * writes to all fields except the padding and field `f`, then this predicate
   * will yield the padding projection and the projection for `f`.
   */
  Projection getAReplacement(Projection prj) {
    Pass2::sourceSink(_, _, prj.getParent*()) and // for performance
    if partiallyOverwritten(prj)
    then
      exists(Projection child |
        child = prj.getAChild() and
        not ProjectionTracking::canBeOverwritten(child) and
        result = getAReplacement(child)
      )
    else result = prj
  }
}

/* module ProjectionReconstruction */
/**
 * Holds if the Uninitialized Field query should give an alert for element `v`
 * with message `alertMessage`.
 *
 * This is the main predicate of this library.
 */
predicate uninitializedFieldQuery(LocalVariable v, string alertMessage) {
  exists(InformationLeakBoundary sink, string explanation |
    explanation = Explanations::explainSourceSink(v, sink) and
    alertMessage =
      "'" + v.toString() + "' may leak information from {" +
        strictconcat(TrackedProjection prj, Projection replacement |
          Pass2::sourceSink(v, sink, prj) and
          replacement = ProjectionReconstruction::getAReplacement(prj)
        |
          repr(replacement.getElement(), replacement.toString()), ", "
        ) + "}. Path: " + explanation
  )
}
