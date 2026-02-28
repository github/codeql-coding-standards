import cpp
import codingstandards.cpp.Handlers

/** The `const std::nothrow_t &` type. */
class ConstNoThrowTReferenceType extends ReferenceType {
  ConstNoThrowTReferenceType() {
    exists(SpecifiedType st |
      st = getBaseType() and
      st.isConst() and
      count(st.getASpecifier()) = 1 and
      st.getUnspecifiedType().(UserType).hasQualifiedName("std", "nothrow_t")
    )
  }
}

/** An `operator` that implements one of the `[replacement.functions]`. */
abstract class OperatorNewOrDelete extends Operator {
  OperatorNewOrDelete() {
    this.getName().regexpMatch("operator new(\\[\\])?") or
    this.getName().regexpMatch("operator delete(\\[\\])?")
  }
}

class ReplaceableOperatorNew extends OperatorNewOrDelete {
  ReplaceableOperatorNew() {
    this.getName().regexpMatch("operator new(\\[\\])?") and
    this.getParameter(0).getType() instanceof Size_t and
    (
      this.getNumberOfParameters() = 1
      or
      this.getNumberOfParameters() = 2 and
      this.getParameter(1).getType() instanceof ConstNoThrowTReferenceType
    )
  }
}

class CustomOperatorNewOrDelete extends OperatorNewOrDelete {
  CustomOperatorNewOrDelete() {
    this.hasDefinition() and
    // Not in the standard library
    exists(this.getFile().getRelativePath()) and
    // Not in a file called `new`, which is likely to be a copy of the standard library
    // as it is in our tests
    not this.getFile().getBaseName() = "new"
  }

  /**
   * Holds if this is a an allocation function that takes a `const std::nothrow_t&`.
   */
  predicate isNoThrowAllocation() {
    this.getAParameter().getType() instanceof ConstNoThrowTReferenceType
  }

  /** Get the description of this custom allocator. */
  string getAllocDescription() {
    result =
      this.getName() + "(" +
        concat(Parameter p, int i | p = this.getParameter(i) | p.getType().getName(), "," order by i)
        + ")"
  }
}

class CustomReplaceableOperatorNew extends CustomOperatorNewOrDelete, ReplaceableOperatorNew { }

class ReplaceableOperatorDelete extends OperatorNewOrDelete {
  ReplaceableOperatorDelete() {
    this.getName().regexpMatch("operator delete(\\[\\])?") and
    this.getParameter(0).getType() instanceof VoidPointerType and
    (
      this.getNumberOfParameters() = 1
      or
      this.getNumberOfParameters() = 2 and
      (
        this.getParameter(1).getType() instanceof ConstNoThrowTReferenceType
        or
        this.getParameter(1).getType() instanceof Size_t
      )
      or
      this.getNumberOfParameters() = 3 and
      (
        this.getParameter(1).getType() instanceof Size_t and
        this.getParameter(2).getType() instanceof ConstNoThrowTReferenceType
      )
    )
  }
}

class CustomReplaceableOperatorDelete extends CustomOperatorNewOrDelete, ReplaceableOperatorDelete {
  CustomReplaceableOperatorDelete getPartner() {
    if this.getAParameter().getType() instanceof Size_t
    then
      result.getAllocDescription() = this.getAllocDescription().replaceAll(",size_t", "") and
      // Linked together in the same target
      result.getALinkTarget() = this.getALinkTarget()
    else result.getPartner() = this
  }
}
