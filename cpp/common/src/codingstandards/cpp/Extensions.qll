import cpp

/**
 * Common base class for modeling compiler extensions.
 */
abstract class CompilerExtension extends Locatable { }

/**
 * Common base class for modeling compiler extensions in CPP.
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
 * An `Attribute` within a compiler specific namespace such as `[[gnu::weak]]`.
 */
class CppNamespacedStdAttributeExtension extends CPPCompilerExtension, StdAttribute {
  CppNamespacedStdAttributeExtension() { exists(this.getNamespace()) and not getNamespace() = "" }

  override string getMessage() {
    result =
      "Use of attribute '" + getName() + "' in namespace '" + getNamespace() +
        "' is a compiler extension and is not portable to other compilers."
  }
}

class CppUnrecognizedAttributeExtension extends CPPCompilerExtension, StdAttribute {
  CppUnrecognizedAttributeExtension() {
    not this instanceof CppNamespacedStdAttributeExtension and
    not getName() in [
        "maybe_unused", "nodiscard", "noreturn", "deprecated", "carries_dependency", "fallthrough"
      ]
  }

  override string getMessage() {
    result = "Use of unrecognized or non-C++17 attribute '" + getName() + "'."
  }
}

/**
 * Compiler-specific builtin functions.
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
 * Statement expressions: ({ ... }) syntax.
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
 */
class CPPStmtExprExtension extends CPPCompilerExtension, StmtExpr {
  override string getMessage() {
    result =
      "Statement expressions are a compiler extension and are not portable to other compilers."
  }
}

/**
 * Ternary expressions with omitted middle operand: x ?: y
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Conditionals.html
 */
class CPPTerseTernaryExtension extends CPPCompilerExtension, ConditionalExpr {
  CPPTerseTernaryExtension() { getCondition() = getElse() or getCondition() = getThen() }

  override string getMessage() {
    result =
      "Ternaries with omitted middle operands are a compiler extension and are not portable to other compilers."
  }
}

/**
 * Extended integer types: __int128, etc.
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/__int128.html
 */
class CPPExtendedIntegerTypeExtension extends CPPCompilerExtension, DeclarationEntry {
  CPPExtendedIntegerTypeExtension() { getType() instanceof Int128Type }

  override string getMessage() {
    result = "128-bit integers are a compiler extension and are not portable to other compilers."
  }
}

/**
 * Extended floating-point types: __float128, _Decimal32, etc.
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Decimal-Float.html
 */
class CPPExtendedFloatTypeExtension extends CPPCompilerExtension, DeclarationEntry {
  CPPExtendedFloatTypeExtension() {
    getType() instanceof Decimal128Type or
    getType() instanceof Decimal32Type or
    getType() instanceof Decimal64Type or
    getType() instanceof Float128Type
  }

  override string getMessage() {
    result =
      "Extended floating-point types are a compiler extension and are not portable to other compilers."
  }
}

/**
 * Zero-length arrays (flexible array members must be last).
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html
 */
class CPPZeroLengthArraysExtension extends CPPCompilerExtension, DeclarationEntry {
  CPPZeroLengthArraysExtension() { getType().(ArrayType).getArraySize() = 0 }

  override string getMessage() {
    result = "Zero length arrays are a compiler extension and are not portable to other compilers."
  }
}

/**
 * Variable-length arrays in struct members (not C++17 compliant).
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Variable-Length.html
 */
class CPPVariableLengthArraysExtension extends CPPCompilerExtension, Field {
  CPPVariableLengthArraysExtension() {
    getType() instanceof ArrayType and
    not getType().(ArrayType).hasArraySize() and
    // Not the final member of the struct, which is allowed in some contexts
    not exists(int lastIndex, Class declaringStruct |
      declaringStruct = getDeclaringType() and
      lastIndex = count(declaringStruct.getACanonicalMember()) - 1 and
      this = declaringStruct.getCanonicalMember(lastIndex)
    )
  }

  override string getMessage() {
    result =
      "Variable length arrays are a compiler extension and are not portable to other compilers."
  }
}

/**
 * __alignof__ operator (use alignof from C++11 instead).
 */
class CPPAlignofExtension extends CPPCompilerExtension, AlignofExprOperator {
  CPPAlignofExtension() { exists(getValueText().indexOf("__alignof__")) }

  override string getMessage() {
    result = "'__alignof__' is a compiler extension and is not portable to other compilers."
  }
}

/**
 * Preprocessor extensions for feature detection.
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
 * Built-in type traits and operations such as `__is_abstract`, `__is_same`, etc.
 *
 * Reference: https://gcc.gnu.org/onlinedocs/gcc/Type-Traits.html
 */
class CPPBuiltinOperationExtension extends CPPCompilerExtension, BuiltInOperation {
  override string getMessage() {
    result = "Use of built-in operation '" + toString() + "' is a compiler extension."
  }
}
