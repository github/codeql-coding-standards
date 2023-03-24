import cpp
import codingstandards.cpp.Extensions

/**
 * Common base class for modeling compiler extensions.
 */
abstract class CCompilerExtension extends CompilerExtension { }

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html#Other-Builtins
abstract class CConditionalDefineExtension extends CCompilerExtension, PreprocessorIfdef {
  CConditionalDefineExtension() {
    exists(toString().indexOf("__has_builtin")) or
    exists(toString().indexOf("__has_constexpr_builtin")) or
    exists(toString().indexOf("__has_feature")) or
    exists(toString().indexOf("__has_extension")) or
    exists(toString().indexOf("__has_attribute")) or
    exists(toString().indexOf("__has_declspec_attribute")) or
    exists(toString().indexOf("__is_identifier")) or
    exists(toString().indexOf("__has_include")) or
    exists(toString().indexOf("__has_include_next")) or
    exists(toString().indexOf("__has_warning"))
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
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Variable-Attributes.html#Variable-Attributes
class CAttributeExtension extends CCompilerExtension, Attribute {
  CAttributeExtension() {
    getName() in [
        "ext_vector_type", "vector_size", "access", "aligned", "deprecated", "cold", "unused",
        "fallthrough", "read_only", "alias"
      ]
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
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Alignment.html#Alignment
class CFunctionLikeExtension extends CCompilerExtension, AlignofExprOperator {
  CFunctionLikeExtension() { exists(getValueText().indexOf("__alignof__")) }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html#Statement-Exprs
class CStmtExprExtension extends CCompilerExtension, StmtExpr { }

// Use of ternary like the following: `int a = 0 ?: 0;` where the
// one of the branches is omitted
// Reference: https://gcc.gnu.org/onlinedocs/gcc/Conditionals.html#Conditionals
class CTerseTernaryExtension extends CCompilerExtension, ConditionalExpr {
  CTerseTernaryExtension() { getCondition() = getElse() or getCondition() = getThen() }
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
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/_005f_005fint128.html#g_t_005f_005fint128
class CIntegerTypeExtension extends CCompilerExtension, DeclarationEntry {
  CIntegerTypeExtension() { getType() instanceof Int128Type }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Long-Long.html#Long-Long
class CLongLongType extends CCompilerExtension, DeclarationEntry {
  CLongLongType() { getType() instanceof LongLongType }
}

class CZeroLengthArraysExtension extends CCompilerExtension, DeclarationEntry {
  CZeroLengthArraysExtension() { getType().(ArrayType).getArraySize() = 0 }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Empty-Structures.html#Empty-Structures
class CEmptyStructExtension extends CCompilerExtension, Struct {
  CEmptyStructExtension() { not exists(getAMember(_)) }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Variable-Length.html#Variable-Length
class CVariableLengthArraysExtension extends CCompilerExtension, DeclarationEntry {
  CVariableLengthArraysExtension() {
    getType() instanceof ArrayType and
    not getType().(ArrayType).hasArraySize()
  }
}
