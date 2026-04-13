import cpp

/**
 * Common base class for modeling compiler extensions.
 */
abstract class CompilerExtension extends Locatable { }

/**
 * A usage of a compiler extension in C++ code, such as non-standard attributes or built-in function
 * calls.
 */
abstract class CPPCompilerExtension extends CompilerExtension {
  abstract string getMessage();
}

/**
 * An `Attribute` that may be a `GnuAttribute` or `Declspec`, or `MicrosoftAttribute`, etc.
 *
 * There are language extensions such as GNU `__attribute__`, Microsoft `__declspec` or
 * `[attribute]` syntax.
 */
class CPPAttributeExtension extends CPPCompilerExtension, Attribute {
  CPPAttributeExtension() { not this instanceof StdAttribute and not this instanceof AlignAs }

  override string getMessage() {
    result =
      "Use of attribute '" + getName() +
        "' is a compiler extension and is not portable to other compilers."
  }
}

/**
 * A `StdAttribute` within a compiler specific namespace such as `[[gnu::weak]]`.
 */
class CPPNamespacedStdAttributeExtension extends CPPCompilerExtension, StdAttribute {
  CPPNamespacedStdAttributeExtension() { exists(this.getNamespace()) and not getNamespace() = "" }

  override string getMessage() {
    result =
      "Use of attribute '" + getName() + "' in namespace '" + getNamespace() +
        "' is a compiler extension and is not portable to other compilers."
  }
}

/**
 * A `StdAttribute` with a name not recognized as part of the C++17 standard.
 *
 * Only the listed names are valid C++17. Namespaced attributes are handled by
 * `CPPNamespacedStdAttributeExtension` and not considered here.
 */
class CPPUnrecognizedAttributeExtension extends CPPCompilerExtension, StdAttribute {
  CPPUnrecognizedAttributeExtension() {
    not this instanceof CPPNamespacedStdAttributeExtension and
    not getName() in [
        "maybe_unused", "nodiscard", "noreturn", "deprecated", "carries_dependency", "fallthrough"
      ]
  }

  override string getMessage() {
    result = "Use of unrecognized or non-C++17 attribute '" + getName() + "'."
  }
}

/**
 * A `FunctionCall` of a compiler-specific builtin function.
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html
 */
class CPPBuiltinFunctionExtension extends CPPCompilerExtension, FunctionCall {
  CPPBuiltinFunctionExtension() {
    getTarget().getName().indexOf("__builtin_") = 0 or
    getTarget().getName().indexOf("__sync_") = 0 or
    getTarget().getName().indexOf("__atomic_") = 0
  }

  override string getMessage() {
    result =
      "Call to builtin function '" + getTarget().getName() +
        "' is a compiler extension and is not portable to other compilers."
  }
}

/**
 * A `StmtExpr`, which uses `({ <stmts> })` syntax, which is a GNU extension.
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
 */
class CPPStmtExprExtension extends CPPCompilerExtension, StmtExpr {
  override string getMessage() {
    result =
      "Statement expressions are a compiler extension and are not portable to other compilers."
  }
}

/**
 * A `ConditionalExpr` using GNU-style omitted middle operand such as `x ?: y`.
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Conditionals.html
 */
class CPPTerseTernaryExtension extends CPPCompilerExtension, ConditionalExpr {
  CPPTerseTernaryExtension() { getCondition() = getElse() or getCondition() = getThen() }

  override string getMessage() {
    result =
      "Ternaries with omitted middle operands are a compiler extension and are not portable to " +
        "other compilers."
  }
}

/**
 * A non-standard `Type` that is only available as a compiler extension, such as `__int128`,
 * `_Decimal32`, `_Decimal64`, `_Decimal128`, or `__float128`.
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/__int128.html
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Decimal-Float.html
 */
class CPPExtensionType extends Type {
  CPPExtensionType() {
    this instanceof Int128Type or
    this instanceof Decimal128Type or
    this instanceof Decimal32Type or
    this instanceof Decimal64Type or
    this instanceof Float128Type
  }
}

/**
 * A `DeclarationEntry` using an extended type such as `__int128`, `_Decimal32`, `_Decimal64`,
 * `_Decimal128`, or `__float128`.
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/__int128.html
 */
class CPPExtensionTypeUsage extends CPPCompilerExtension, DeclarationEntry {
  CPPExtensionType extendedType;

  CPPExtensionTypeUsage() { extendedType = getType() }

  override string getMessage() {
    result =
      "Declaration '" + getName() + "' uses type '" + extendedType.getName() +
        "' which is a compiler extension and is not portable to other compilers."
  }
}

/**
 * A `DeclarationEntry` using a zero-length array, which is a non-standard way to declare a flexible
 * array member.
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html
 */
class CPPZeroLengthArraysExtension extends CPPCompilerExtension, DeclarationEntry {
  ArrayType array;

  CPPZeroLengthArraysExtension() {
    array = getType() and
    array.getArraySize() = 0
  }

  override string getMessage() {
    result =
      "Variable '" + getName() + "' is declared with a zero-length array (of '" +
        array.getBaseType() + "') is a compiler extension and are not portable to other compilers."
  }
}

/**
 * A `Field` with a variable-length array type in a struct member (not C++17 compliant).
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Variable-Length.html
 */
class CPPVariableLengthArraysExtension extends CPPCompilerExtension, VlaDeclStmt {
  override string getMessage() {
    result =
      "Variable length array (used in '" + this +
        "') are a compiler extension and are not portable to other compilers."
  }
}

/**
 * A `PreprocessorIfdef` using a builtin preprocessor feature such as `__has_builtin`,
 * `__has_include`, etc., which are non-standard clang extensions.
 *
 * Reference: https://clang.llvm.org/docs/LanguageExtensions.html
 */
class CPPConditionalDefineExtension extends CPPCompilerExtension, PreprocessorIfdef {
  string feature;

  CPPConditionalDefineExtension() {
    feature =
      [
        "__has_builtin", "__has_constexpr_builtin", "__has_feature", "__has_extension",
        "__has_attribute", "__has_declspec_attribute", "__is_identifier", "__has_include",
        "__has_include_next", "__has_warning", "__has_cpp_attribute"
      ] and
    exists(toString().indexOf(feature))
  }

  override string getMessage() {
    result =
      "Call to builtin preprocessor feature '" + feature +
        "' is a compiler extension and is not portable to other compilers."
  }
}

/**
 * A `PreprocessorDirective` that is a non-standard compiler extension, such as `#pragma`, `#error`,
 * or `#warning`.
 */
class CPPPreprocessorDirectiveExtension extends CPPCompilerExtension, PreprocessorDirective {
  string kind;

  CPPPreprocessorDirectiveExtension() {
    this instanceof PreprocessorPragma and kind = "#pragma " + getHead()
    or
    this instanceof PreprocessorError and kind = "#error"
    or
    this instanceof PreprocessorWarning and kind = "#warning"
  }

  override string getMessage() {
    result = "Use of non-standard preprocessor directive '" + kind + "' is a compiler extension."
  }
}

/**
 * A `BuiltInOperation` which describes certain non-standard syntax such as type trait operations,
 * for example GNU `__is_abstract(T)`, `__is_same(T, U)`, etc.
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Type-Traits.html
 */
class CPPBuiltinOperationExtension extends CPPCompilerExtension, BuiltInOperation {
  override string getMessage() {
    result = "Use of built-in operation '" + toString() + "' is a compiler extension."
  }
}
