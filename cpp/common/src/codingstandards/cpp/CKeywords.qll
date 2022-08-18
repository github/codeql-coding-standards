import cpp

/** Module to reason about keywords in standards C90, C99 and C11. */
module Keywords {
  /** Holds if `s` is a keyword. */
  predicate isKeyword(string s) {
    s = "auto"
    or
    s = "break"
    or
    s = "case"
    or
    s = "char"
    or
    s = "const"
    or
    s = "continue"
    or
    s = "default"
    or
    s = "do"
    or
    s = "double"
    or
    s = "else"
    or
    s = "enum"
    or
    s = "extern"
    or
    s = "float"
    or
    s = "for"
    or
    s = "goto"
    or
    s = "if"
    or
    s = "inline"
    or
    s = "int"
    or
    s = "long"
    or
    s = "register"
    or
    s = "restrict"
    or
    s = "return"
    or
    s = "short"
    or
    s = "signed"
    or
    s = "sizeof"
    or
    s = "static"
    or
    s = "struct"
    or
    s = "switch"
    or
    s = "typedef"
    or
    s = "union"
    or
    s = "unsigned"
    or
    s = "void"
    or
    s = "volatile"
    or
    s = "while"
    or
    s = "_Alignas"
    or
    s = "_Alignof"
    or
    s = "_Atomic"
    or
    s = "_Bool"
    or
    s = "_Complex"
    or
    s = "_Generic"
    or
    s = "_Imaginary"
    or
    s = "_Noreturn"
    or
    s = "_Static_assert"
    or
    s = "_Thread_local"
  }
}
