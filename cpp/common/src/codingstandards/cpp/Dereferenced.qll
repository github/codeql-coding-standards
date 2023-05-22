import cpp
private import codingstandards.cpp.Operator
private import codingstandards.cpp.standardlibrary.String

/**
 * An expression which is dereferenced.
 */
class DereferencedExpr extends Expr {
  DereferencedExpr() {
    // This is a dereferencing operation
    (
      // stdlib dereferencing library
      dereferenced(this)
      or
      // The above misses field accesses of reference types
      exists(FieldAccess fa |
        this = fa.getQualifier() and
        this.getType() instanceof ReferenceType
      )
      or
      // And calls using the * operator
      exists(Call c |
        c.getQualifier() = this and
        c.getTarget() instanceof StarOperator
      )
      or
      // And access to arrays `array[0]`
      this = any(ArrayExpr ae).getArrayBase()
      or
      this instanceof StandardLibraryDereferencedExpr
    )
  }
}

abstract class StandardLibraryDereferencedExpr extends Expr { }

abstract class BasicStringDereferencedExpr extends StandardLibraryDereferencedExpr { }

class BasicStringMemberFunctionDereferencedExpr extends BasicStringDereferencedExpr {
  BasicStringMemberFunctionDereferencedExpr() {
    // The following std::basic_string member functions result in a call to std::char_traits::length():
    exists(FunctionCall fc, Function f, StdBasicString stringType |
      fc.getTarget() = f and
      f.getDeclaringType() = stringType
    |
      // basic_string::basic_string(const charT *, const Allocator &)
      f instanceof Constructor and
      f.getNumberOfParameters() <= 2 and
      f.getParameter(0).getType() = stringType.getConstCharTPointer() and
      (
        f.getNumberOfParameters() = 2
        implies
        f.getParameter(1).getType() = stringType.getConstAllocatorReferenceType()
      ) and
      this = fc.getArgument(0)
      or
      // basic_string &basic_string::append(const charT *)
      // basic_string &basic_string::assign(const charT *)
      f.hasName(["append", "assign"]) and
      f.getNumberOfParameters() = 1 and
      f.getParameter(0).getType() = stringType.getConstCharTPointer() and
      this = fc.getArgument(0)
      or
      // basic_string &basic_string::insert(size_type, const charT *)
      f.hasName("insert") and
      f.getNumberOfParameters() = 2 and
      f.getParameter(0).getType() = stringType.getSizeType() and
      f.getParameter(1).getType() = stringType.getConstCharTPointer() and
      this = fc.getArgument(1)
      or
      // basic_string &basic_string::replace(size_type, size_type, const charT *)
      // basic_string &basic_string::replace(const_iterator, const_iterator, const charT *)
      f.hasName("replace") and
      f.getNumberOfParameters() = 3 and
      f.getParameter(0).getType() = [stringType.getSizeType(), stringType.getConstIteratorType()] and
      f.getParameter(1).getType() = [stringType.getSizeType(), stringType.getConstIteratorType()] and
      f.getParameter(2).getType() = stringType.getConstCharTPointer() and
      this = fc.getArgument(2)
      or
      // size_type basic_string::find(const charT *, size_type)
      // size_type basic_string::rfind(const charT *, size_type)
      // size_type basic_string::find_first_of(const charT *, size_type)
      // size_type basic_string::find_last_of(const charT *, size_type)
      // size_type basic_string::find_first_not_of(const charT *, size_type)
      // size_type basic_string::find_last_not_of(const charT *, size_type)
      f.hasName([
          "find", "rfind", "find_first_of", "find_last_of", "find_first_not_of", "find_last_not_of"
        ]) and
      f.getNumberOfParameters() = 2 and
      f.getParameter(0).getType() = stringType.getConstCharTPointer() and
      f.getParameter(1).getType() = stringType.getSizeType() and
      this = fc.getArgument(0)
      or
      // int basic_string::compare(const charT *)
      // basic_string &basic_string::operator=(const charT *)
      // basic_string &basic_string::operator+=(const charT *)
      f.hasName(["compare", "operator=", "operator+="]) and
      f.getNumberOfParameters() = 1 and
      f.getParameter(0).getType() = stringType.getConstCharTPointer() and
      this = fc.getArgument(0)
      or
      // int basic_string::compare(size_type, size_type, const charT *)
      f.hasName("compare") and
      f.getNumberOfParameters() = 3 and
      f.getParameter(0).getType() = stringType.getSizeType() and
      f.getParameter(1).getType() = stringType.getSizeType() and
      f.getParameter(2).getType() = stringType.getConstCharTPointer() and
      this = fc.getArgument(2)
    )
  }
}

class BasicStringNonMemberFunctionDereferencedExpr extends BasicStringDereferencedExpr {
  BasicStringNonMemberFunctionDereferencedExpr() {
    // The following std::basic_string nonmember functions result in a call to to std::char_traits::length():
    exists(FunctionCall fc, Function f, StdBasicString stringType | fc.getTarget() = f |
      // basic_string operator+(const charT *, const basic_string&)
      // basic_string operator+(const charT *, basic_string &&)
      // basic_string operator+(const basic_string &, const charT *)
      // basic_string operator+(basic_string &&, const charT *)
      // bool operator==(const charT *, const basic_string &)
      // bool operator==(const basic_string &, const charT *)
      // bool operator!=(const charT *, const basic_string &)
      // bool operator!=(const basic_string &, const charT *)
      // bool operator<(const charT *, const basic_string &)
      // bool operator<(const basic_string &, const charT *)
      // bool operator>(const charT *, const basic_string &)
      // bool operator>(const basic_string &, const charT *)
      // bool operator<=(const charT *, const basic_string &)
      // bool operator<=(const basic_string &, const charT *)
      // bool operator>=(const charT *, const basic_string &)
      // bool operator>=(const basic_string &, const charT *)
      f.hasName([
          "operator+", "operator==", "operator!=", "operator<", "operator>", "operator<=",
          "operator>="
        ]) and
      f.getAParameter().getType().(ReferenceType).getBaseType().getUnspecifiedType() = stringType and
      exists(int param |
        f.getParameter(param).getType() = stringType.getConstCharTPointer() and
        this = fc.getArgument(param)
      )
    )
  }
}
