/**
 * A module to reason about C++ Standard Library lexical conventions.
 */

import cpp

module Lex {
  module Cpp14 {
    /** Gets a language keyword. */
    string keyword() {
      // Keywords (2.12 Table 4)
      result in [
          "alignas", "alignof", "asm", "auto", "bool", "break", "case", "catch", "char", "char16_t",
          "char32_t", "class", "const", "constexpr", "const_cast", "continue", "decltype",
          "default", "delete", "do", "double", "dynamic_cast", "else", "enum", "explicit", "export",
          "extern", "false", "float", "for", "friend", "goto", "if", "inline", "int", "long",
          "mutable", "namespace", "new", "noexcept", "nullptr", "operator", "private", "protected",
          "public", "register", "reinterpret_cast", "return", "short", "signed", "sizeof", "static",
          "static_assert", "static_cast", "struct", "switch", "template", "this", "thread_local",
          "throw", "true", "try", "typedef", "typeid", "typename", "union", "unsigned", "using",
          "virtual", "void", "volatile", "wchar_t", "while"
        ]
      or
      // Altnerative representations (2.12 Table 5)
      result in [
          "and", "and_eq", "not_eq", "or", "bitand", "or_eq", "bitor", "xor", "compl", "not",
          "xor_eq"
        ]
    }

    /** Gets an identifier that is considered special and reserved by the C++ standard. */
    string specialIdentfier() { result in ["override", "final"] }

    /** Gets an attribute token that is reserved by the C++ standard. */
    string reservedAttributeToken() {
      result in ["alignas", "noreturn", "carries_dependency", "deprecated"]
    }
  }
}
