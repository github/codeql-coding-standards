import cpp

/**
 * A `std::string` instantiation.
 */
class StdBasicString extends ClassTemplateInstantiation {
  StdBasicString() { this.hasQualifiedName(["std", "bsl"], "basic_string") }

  /** Gets the `charT` type for this `basic_string` instantiation. */
  Type getCharT() { result = getTemplateArgument(0) }

  /** Gets the `Allocator` type for this `basic_string` instantiation. */
  Type getAllocator() { result = getTemplateArgument(2) }

  /** Gets the `const charT*` type for this `basic_string` instantiation. */
  PointerType getConstCharTPointer() {
    exists(SpecifiedType specType |
      specType = result.getBaseType() and
      specType.isConst() and
      count(specType.getASpecifier()) = 1 and
      (specType.getBaseType() = getCharT() or specType.getBaseType().getName() = "value_type")
    )
  }

  /** Gets the `const Allocator&` type for this `basic_string` instantiation. */
  ReferenceType getConstAllocatorReferenceType() {
    exists(SpecifiedType specType |
      specType = result.getBaseType() and
      specType.getBaseType() = getAllocator() and
      specType.isConst() and
      count(specType.getASpecifier()) = 1
    )
  }

  /** Gets the `size_type` type for this `basic_string` instantiation. */
  Type getSizeType() {
    exists(TypedefType t |
      t.getDeclaringType() = this and
      t.getName() = "size_type" and
      result = t
    )
  }

  /** Gets the `const_iterator` type for this `basic_string` instantiation. */
  Type getConstIteratorType() {
    exists(TypedefType t |
      t.getDeclaringType() = this and
      // Certain compilers user __const_iterator instead of const_iterator.
      t.getName() = ["const_iterator", "__const_iterator"] and
      result = t
    )
  }
}
