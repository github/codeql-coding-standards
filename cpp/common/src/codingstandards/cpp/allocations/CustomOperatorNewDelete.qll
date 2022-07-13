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
abstract class CustomOperatorNewOrDelete extends Operator {
  CustomOperatorNewOrDelete() {
    // Not in the standard library
    exists(getFile().getRelativePath()) and
    // Not in a file called `new`, which is likely to be a copy of the standard library
    // as it is in our tests
    not getFile().getBaseName() = "new"
  }

  /**
   * Holds if this is a an allocation function that takes a `const std::nothrow_t&`.
   */
  predicate isNoThrowAllocation() {
    getAParameter().getType() instanceof ConstNoThrowTReferenceType
  }

  /** Get the description of this custom allocator. */
  string getAllocDescription() {
    result =
      getName() + "(" +
        concat(Parameter p, int i | p = getParameter(i) | p.getType().getName(), "," order by i) +
        ")"
  }
}

class CustomOperatorNew extends CustomOperatorNewOrDelete {
  CustomOperatorNew() {
    hasDefinition() and
    getName().regexpMatch("operator new(\\[\\])?") and
    getParameter(0).getType() instanceof Size_t and
    (
      getNumberOfParameters() = 1
      or
      getNumberOfParameters() = 2 and
      getParameter(1).getType() instanceof ConstNoThrowTReferenceType
    )
  }
}

class CustomOperatorDelete extends CustomOperatorNewOrDelete {
  CustomOperatorDelete() {
    getName().regexpMatch("operator delete(\\[\\])?") and
    getParameter(0).getType() instanceof VoidPointerType and
    (
      getNumberOfParameters() = 1
      or
      getNumberOfParameters() = 2 and
      (
        getParameter(1).getType() instanceof ConstNoThrowTReferenceType
        or
        getParameter(1).getType() instanceof Size_t
      )
      or
      getNumberOfParameters() = 3 and
      (
        getParameter(1).getType() instanceof Size_t and
        getParameter(2).getType() instanceof ConstNoThrowTReferenceType
      )
    )
  }

  CustomOperatorDelete getPartner() {
    if getAParameter().getType() instanceof Size_t
    then
      result.getAllocDescription() = this.getAllocDescription().replaceAll(",size_t", "") and
      // Linked together in the same target
      result.getALinkTarget() = this.getALinkTarget()
    else result.getPartner() = this
  }
}
