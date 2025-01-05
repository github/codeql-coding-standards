import cpp
import codingstandards.cpp.Extensions

/**
 * Common base class for modeling compiler extensions.
 */
abstract class CCompilerExtension extends CompilerExtension {
  abstract string getMessage();
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html#Other-Builtins
abstract class CConditionalDefineExtension extends CCompilerExtension, PreprocessorIfdef {
  string feature;

  CConditionalDefineExtension() {
    feature =
      [
        "__has_builtin", "__has_constexpr_builtin", "__has_feature", "__has_extension",
        "__has_attribute", "__has_declspec_attribute", "__is_identifier", "__has_include",
        "__has_include_next", "__has_warning"
      ] and
    exists(toString().indexOf(feature))
  }

  override string getMessage() {
    result =
      "Call to builtin function '" + feature +
        "' is a compiler extension and is not portable to other compilers."
  }
}

// Reference: https://clang.llvm.org/docs/LanguageExtensions.html#builtin-macros
class CMacroBasedExtension extends CCompilerExtension, Macro {
  CMacroBasedExtension() {
    getBody() in [
        "__BASE_FILE__", "__FILE_NAME__", "__COUNTER__", "__INCLUDE_LEVEL__", "_TIMESTAMP__",
        "__clang__", "__clang_major__", "__clang_minor__", "__clang_patchlevel__",
        "__clang_version__", "__clang_literal_encoding__", "__clang_wide_literal_encoding__"
      ]
  }

  override string getMessage() {
    result =
      "Use of builtin macro '" + getBody() +
        "' is a compiler extension and is not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Variable-Attributes.html#Variable-Attributes
class CAttributeExtension extends CCompilerExtension, Attribute {
  CAttributeExtension() {
    getName() in [
        "ext_vector_type", "vector_size", "access", "aligned", "deprecated", "cold", "unused",
        "fallthrough", "read_only", "alias"
      ]
  }

  override string getMessage() {
    result =
      "Use of attribute  '" + getName() +
        "' is a compiler extension and is not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/_005f_005fsync-Builtins.html#g_t_005f_005fsync-Builtins
class CFunctionExtension extends CCompilerExtension, FunctionCall {
  CFunctionExtension() {
    // these must be somewhat broad because of how they vary
    // in implementation / naming
    getTarget().getName().indexOf("__sync_fetch") = 0 or
    getTarget().getName().indexOf("__sync_add") = 0 or
    getTarget().getName().indexOf("__sync_sub") = 0 or
    getTarget().getName().indexOf("__sync_or") = 0 or
    getTarget().getName().indexOf("__sync_and") = 0 or
    getTarget().getName().indexOf("__sync_xor") = 0 or
    getTarget().getName().indexOf("__sync_nand") = 0 or
    getTarget().getName().indexOf("__sync_bool") = 0 or
    getTarget().getName().indexOf("__sync_val") = 0 or
    getTarget().getName().indexOf("__sync_lock") = 0 or
    // the built-in extensions
    getTarget().getName().indexOf("__builtin_") = 0
  }

  override string getMessage() {
    result =
      "Call to builtin function '" + getTarget().getName() +
        "' is a compiler extension and is not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Alignment.html#Alignment
class CFunctionLikeExtension extends CCompilerExtension, AlignofExprOperator {
  CFunctionLikeExtension() { exists(getValueText().indexOf("__alignof__")) }

  override string getMessage() {
    result = "'__alignof__' is a compiler extension and is not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html#Statement-Exprs
class CStmtExprExtension extends CCompilerExtension, StmtExpr {
  override string getMessage() {
    result =
      "Statement expressions are a compiler extension and are not portable to other compilers."
  }
}

// Use of ternary like the following: `int a = 0 ?: 0;` where the
// one of the branches is omitted
// Reference: https://gcc.gnu.org/onlinedocs/gcc/Conditionals.html#Conditionals
class CTerseTernaryExtension extends CCompilerExtension, ConditionalExpr {
  CTerseTernaryExtension() { getCondition() = getElse() or getCondition() = getThen() }

  override string getMessage() {
    result =
      "Ternaries with omitted middle operands are a compiler extension and is not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/_005f_005fint128.html#g_t_005f_005fint128
// Reference: https://gcc.gnu.org/onlinedocs/gcc/Decimal-Float.html#Decimal-Float
class CRealTypeExtensionExtension extends CCompilerExtension, DeclarationEntry {
  CRealTypeExtensionExtension() {
    getType() instanceof Decimal128Type or
    getType() instanceof Decimal32Type or
    getType() instanceof Decimal64Type or
    getType() instanceof Float128Type
  }

  override string getMessage() {
    result = "Decimal floats are a compiler extension and are not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/_005f_005fint128.html#g_t_005f_005fint128
class CIntegerTypeExtension extends CCompilerExtension, DeclarationEntry {
  CIntegerTypeExtension() { getType() instanceof Int128Type }

  override string getMessage() {
    result = "128-bit integers are a compiler extension and are not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Long-Long.html#Long-Long
class CLongLongType extends CCompilerExtension, DeclarationEntry {
  CLongLongType() { getType() instanceof LongLongType }

  override string getMessage() {
    result =
      "Double-Word integers are a compiler extension and are not portable to other compilers."
  }
}

class CZeroLengthArraysExtension extends CCompilerExtension, DeclarationEntry {
  CZeroLengthArraysExtension() { getType().(ArrayType).getArraySize() = 0 }

  override string getMessage() {
    result = "Zero length arrays are a compiler extension and are not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Empty-Structures.html#Empty-Structures
class CEmptyStructExtension extends CCompilerExtension, Struct {
  CEmptyStructExtension() { not exists(getAMember(_)) }

  override string getMessage() {
    result = "Empty structures are a compiler extension and are not portable to other compilers."
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Variable-Length.html#Variable-Length
class CVariableLengthArraysExtension extends CCompilerExtension, Field {
  CVariableLengthArraysExtension() {
    getType() instanceof ArrayType and
    not getType().(ArrayType).hasArraySize() and
    // Not the final member of the struct, which is allowed to be variably sized
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
