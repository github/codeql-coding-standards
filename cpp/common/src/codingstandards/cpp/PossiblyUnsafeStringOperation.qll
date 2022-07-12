import cpp
import semmle.code.cpp.security.BufferWrite
import semmle.code.cpp.commons.Buffer

class StandardCStringFunction extends Function {
  StandardCStringFunction() {
    this instanceof StrcatFunction or
    this instanceof StrcpyFunction or
    this instanceof Snprintf
  }
}

private class StdBasicIStream extends TemplateClass {
  StdBasicIStream() { this.hasQualifiedName("std", "basic_istream") }
}

private class StdIStreamInNonMember extends Function {
  StdIStreamInNonMember() {
    this.hasQualifiedName("std", "operator>>") and
    this.getUnspecifiedType().(ReferenceType).getBaseType() =
      any(StdBasicIStream s).getAnInstantiation()
  }
}

class PossiblyUnsafeStringOperation extends FunctionCall {
  PossiblyUnsafeStringOperation() {
    exists(BufferWriteCall bwc, Expr src, Expr dest |
      this = bwc and
      src = bwc.getASource() and
      dest = bwc.getDest() and
      // Consider the standard c type functions
      (
        // Case 1: Consider the `strncat(dest, src, n)` to determine the safety
        // of this function we must know the current contents of the destination
        // buffer. Thus, we consider any usage of strcat to be potentially
        // problematic.
        bwc.getTarget() instanceof StrcatFunction
        or
        // Case 2: Consider the `strncpy(dest, src, n)` function. We do not
        // consider `strcpy` since it is a banned function. The behavior of
        // strncpy(dest, src, n) is that it will copy null terminators only if n
        // > sizeof(src). If `src` is null-terminated then it will be null
        // terminated if n >= sizeof(src). We take the conservative approach and
        // use strictly greater. Thus this can be violated under the condition
        // that n <  strlen(src). Note that a buffer overflow is possible if
        // `n` is greater than sizeof(dest). The point of this query is not to
        // check for buffer overflows but we would certainly want to indicate
        // this would be a case where a string will not be null terminated.
        bwc.getTarget() instanceof StrcpyFunction and
        (
          (bwc.getExplicitLimit() / bwc.getCharSize()) < getBufferSize(src, _) or
          getBufferSize(dest, _) < (bwc.getExplicitLimit() / bwc.getCharSize())
        )
        or
        // Case 3: Consider the `snprintf(dest, N, format,...)` functions. These
        // will always null-terminate. They only require that the destination
        // buffer is larger or equal to N. This will check for overflow, which
        // is the only case there would be an issue with null termination (if
        // the program doesn't crash first).
        bwc.getTarget() instanceof Snprintf and
        getBufferSize(dest, _) < (bwc.getExplicitLimit() / bwc.getCharSize())
      )
    )
    or
    //Case 4: Consider operations such as: `cin >> buffer` In these cases
    // `buffer` will possibly overflow.
    getTarget() instanceof StdIStreamInNonMember and
    getAnArgument().getUnspecifiedType().(DerivedType).getBaseType*() instanceof CharType
    or
    // Case 5: Consider an operation such as: `in.read(buffer, sz)` If buffer is
    // a character array and it is not wrapped in a try/catch, it can result in
    // buffer overflows and undefined behavior.
    getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", "basic_istream") and
    getAnArgument().getUnspecifiedType().(DerivedType).getBaseType*() instanceof CharType and
    not exists(TryStmt ts |
      ts.getEnclosingFunction() = getEnclosingFunction() and
      ts.getAChild*() = this
    )
  }
}

/**
 * Models a character array that is initialized with a string literal.
 */
class CharArrayInitializedWithStringLiteral extends Expr {
  int stringLiteralLength;
  int containerLength;

  CharArrayInitializedWithStringLiteral() {
    exists(Variable v, StringLiteral sl |
      v.getInitializer().getExpr() = sl and
      (
        // `getValueText()` includes the quotes of the string
        // this calculation is to subtract that overage. This also handles
        // wide strings initialized with L""
        if sl.getValueText().charAt(0) = "L"
        then sl.getValueText().length() - 3 = stringLiteralLength
        else sl.getValueText().length() - 2 = stringLiteralLength
      ) and
      containerLength = v.getType().(ArrayType).getArraySize() and
      this = sl
    )
  }

  int getStringLiteralLength() { result = stringLiteralLength }

  int getContainerLength() { result = containerLength }
}
