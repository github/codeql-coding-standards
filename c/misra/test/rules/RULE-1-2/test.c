#include <stdbool.h>
#include <stdio.h>
// Note: Clang aims to support both clang and gcc extensions.
// This test case has been designed using lists compiled from:
// - https://clang.llvm.org/docs/LanguageExtensions.html
// - https://gcc.gnu.org/onlinedocs/gcc/C-Extensions.html

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html#Other-Builtins
#ifdef __has_builtin // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_constexpr_builtin // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_feature // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_extension // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_c_attribute // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_attribute // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_declspec_attribute // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __is_identifier // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_include // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_include_next // NON_COMPLIANT[FALSE_NEGATIVE]
#endif
#ifdef __has_warning // NON_COMPLIANT[FALSE_NEGATIVE]
#endif

// Reference: https://clang.llvm.org/docs/LanguageExtensions.html#builtin-macros
#define A __BASE_FILE__                   // NON_COMPLIANT
#define B __FILE_NAME__                   // NON_COMPLIANT
#define C __COUNTER__                     // NON_COMPLIANT
#define D __INCLUDE_LEVEL__               // NON_COMPLIANT
#define E__TIMESTAMP__                    // NON_COMPLIANT
#define F __clang__                       // NON_COMPLIANT
#define G __clang_major__                 // NON_COMPLIANT
#define H __clang_minor__                 // NON_COMPLIANT
#define I __clang_patchlevel__            // NON_COMPLIANT
#define J __clang_version__               // NON_COMPLIANT
#define K __clang_literal_encoding__      // NON_COMPLIANT
#define L __clang_wide_literal_encoding__ // NON_COMPLIANT

// Requires additional compiler flags to change the architecture
// typedef __attribute__((neon_vector_type(8))) int8_t int8x8_t;
// typedef __attribute__((neon_polyvector_type(16))) poly8_t poly8x16_t;

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Variable-Attributes.html#Variable-Attributes
typedef int int4 __attribute__((vector_size(4 * sizeof(int)))); // NON_COMPLIANT
typedef int v4si __attribute__((__vector_size__(16)));          // NON_COMPLIANT
typedef float float4 __attribute__((ext_vector_type(4)));       // NON_COMPLIANT
typedef float float2 __attribute__((ext_vector_type(2)));       // NON_COMPLIANT

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html#Statement-Exprs
void gf1() {
  ({ // NON_COMPLIANT
    int y = 1;
    int z;
    if (y > 0)
      z = y;
    else
      z = -y;
    z;
  });
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Local-Labels.html#Local-Labels
void gf2() {
  // __label__ found; // NON_COMPLIANT[FALSE_NEGATIVE] -- local labels not
  // supported by clang
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Labels-as-Values.html#Labels-as-Values
void gf3() {
  void *ptr;
  // goto *ptr; // NON_COMPLIANT[FALSE_NEGATIVE]  -- not supported in clang
}

// Referfence:
// https://gcc.gnu.org/onlinedocs/gcc/Nested-Functions.html#Nested-Functions
void gf4() {
  // void gf4a(){  // NON_COMPLIANT[FALSE_NEGATIVE]  -- not supported in clang
  //
  // }
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Nonlocal-Gotos.html#Nonlocal-Gotos
void gf5() {
  __builtin_setjmp(0);     // NON_COMPLIANT
  __builtin_longjmp(0, 1); // NON_COMPLIANT
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Constructing-Calls.html#Constructing-Calls
void gf6() {
  // not supported by clang
  //__builtin_apply_args(); // NON_COMPLIANT[FALSE_NEGATIVE]
  //__builtin_apply(0, 0, 0); // NON_COMPLIANT[FALSE_NEGATIVE]
  //__builtin_return(0); // NON_COMPLIANT[FALSE_NEGATIVE]
  //__builtin_va_arg_pack(); // NON_COMPLIANT[FALSE_NEGATIVE]
  //__builtin_va_arg_pack_len(); // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Conditionals.html#Conditionals
void gf7() {
  int a = 0 ?: 0; // NON_COMPLIANT
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Typeof.html#Typeof
void gf8() { // not supported by qcc gcc and clang
  // typeof(int *); // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/_005f_005fint128.html#g_t_005f_005fint128
void gf9() {
  __int128 a; // NON_COMPLIANT
}
// Reference: https://gcc.gnu.org/onlinedocs/gcc/Long-Long.html#Long-Long
void gf10() {
  long long int a; // NON_COMPLIANT
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Complex.html#Complex
void gf11() {
  __real__(0); // NON_COMPLIANT[FALSE_NEGATIVE]
  __imag__(0); // NON_COMPLIANT[FALSE_NEGATIVE]
}

void gf12() {}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Floating-Types.html#Floating-Types
// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Decimal-Float.html#Decimal-Float
void gf13() {
  // not supported on clang
  //_Decimal32 a; // NON_COMPLIANT[FALSE_NEGATIVE]
  //_Decimal64 b; // NON_COMPLIANT[FALSE_NEGATIVE]
  //_Decimal128 c; // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Complex.html#Complex
void gf14() {
  // Do not work in clang
  // typedef _Complex float __attribute__((mode(TC))) _Complex128; //
  // NON_COMPLIANT[FALSE_NEGATIVE] typedef _Complex float
  // __attribute__((mode(XC))) _Complex80; // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Hex-Floats.html#Hex-Floats
void gf15() {
  float f = 0x1.fp3; // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Zero-Length.html#Zero-Length
void gf16() {
  char contents[0]; // NON_COMPLIANT
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Named-Address-Spaces.html#Named-Address-Spaces
void gf17() {
  // const __flash char ** p; // NON_COMPLIANT[FALSE_NEGATIVE] --  not supported
  // in clang
}

void gf18() {
  // not supported by extractor - checked by looking for flags.

  // short _Fract, _Fract; // NON_COMPLIANT[FALSE_NEGATIVE] -
  // long _Fract; // NON_COMPLIANT[FALSE_NEGATIVE]
}

struct gf19 {}; // NON_COMPLIANT

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Variable-Length.html#Variable-Length
void gf20(int n) {
  // struct S { int x[n]; }; // NON_COMPLIANT[FALSE_NEGATIVE] - will never be
  // supported in clang
}
// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Variadic-Macros.html#Variadic-Macros
#define gf21(format, args...)                                                  \
  printf(format, args) // NON_COMPLIANT[FALSE_NEGATIVE] -- note
                       // the issue here is explicitly naming the arguments.
#define gf21a(format, ...) printf(format, __VA_ARGS__) // COMPLIANT

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Escaped-Newlines.html#Escaped-Newlines
#define gf22                                                                   \
  "a"                                                                          \
  \     
"b" // NON_COMPLIANT[FALSE_NEGATIVE] - additional spaces after a backslash --
    // stripped by extractor
#define gf22a                                                                  \
  "a"                                                                          \
  "b" // COMPLIANT

void gf24(int f, int g) {
  float beat_freqs[2] = {f - g, f + g}; // NON_COMPLIANT
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Variable-Length.html#Variable-Length
void gf25t(int N, int M, double out[M][N], // NON_COMPLIANT
           const double in[N][M]);         // NON_COMPLIANT
void gf25() {
  double x[3][2];
  double y[2][3];
  gf25t(3, 2, y,
        x); // in ISO C the const qualifier is formally attached
            // to the element type of the array and not the array itself
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Compound-Literals.html#Compound-Literals
struct gf26t {
  int a;
  char b[2];
} gf26v;
void gf26(int x, int y) {
  gf26v = ((struct gf26t){
      x + y, 'z', 0}); // NON_COMPLIANT[FALSE_NEGATIVE] - compound literal
}
// Reference: https://gcc.gnu.org/onlinedocs/gcc/Case-Ranges.html#Case-Ranges
void gf28() {
  int a;

  // switch(a){
  //     case: 0 ... 5:  // NON_COMPLIANT[FALSE_NEGATIVE] -  Not supported in
  //     clang.
  //         ;;
  //         break;
  //     default:
  //         ;;
  //         break;
  // }
}

union gf29u {
  int i;
  double j;
};

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Cast-to-Union.html#Cast-to-Union
void gf29() {
  int x;
  int y;
  union gf29u z;
  z = (union gf29u)x; // NON_COMPLIANT[FALSE_NEGATIVE]
  z = (union gf29u)y; // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Variable-Attributes.html#Variable-Attributes
// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Function-Attributes.html#Function-Attributes
__attribute__((access(read_only, 1))) int
gf30(const char *); // NON_COMPLIANT -- attributes are not portable.

extern int __attribute__((alias("var_target")))
gf31; // NON_COMPLIANT -- attributes are not portable.

struct __attribute__((aligned(8))) gf32 {
  short f[3];
}; // NON_COMPLIANT -- attributes are not portable.

void gf33() {
gf33l:
  __attribute__((cold, unused)); // NON_COMPLIANT
  return;
}

enum gf34 {
  oldval __attribute__((deprecated)), // NON_COMPLIANT
  newval
};

void gf35() {
  int x;
  // __attribute__((assume(x == 42))); // NON_COMPLIANT[FALSE_NEGATIVE] - Not
  // supported in clang

  switch (x) {
  case 1:
    printf("");
    __attribute__((fallthrough)); // NON_COMPLIANT
  case 2:
    break;
  }
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Dollar-Signs.html#Dollar-Signs
void gf37() {
  int a$1; // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Character-Escapes.html#Character-Escapes
void gf38() {
  const char *c = "test\e"; // NON_COMPLIANT[FALSE_NEGATIVE]
}

struct gf39s {
  int x;
  char y;
} gf39v;

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Alignment.html#Alignment
void gf39() {
  __alignof__(gf39v.x); // NON_COMPLIANT
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Incomplete-Enums.html#Incomplete-Enums
// enum gf40 {}; // NON_COMPLIANT[FALSE_NEGATIVE] - not supported in clang

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Function-Names.html#Function-Names
void gf41() {
  printf("__FUNCTION__ = %s\n", __FUNCTION__); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("__PRETTY_FUNCTION__ = %s\n",
         __PRETTY_FUNCTION__); // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference: https://clang.llvm.org/docs/LanguageExtensions.html#builtin-macros
// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html#Other-Builtins
void gf42() {
  __builtin_extract_return_addr(0); // NON_COMPLIANT
  __builtin_frob_return_addr(0);    // NON_COMPLIANT
  __builtin_frame_address(0);       // NON_COMPLIANT
}

struct gf43s {
  int x;
  char y;
} gf43v;

void gf43() {
  __builtin_offsetof(struct gf43s, x); // NON_COMPLIANT
}

struct gf44s {
  int x;
  char y;
} gf44v;

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/_005f_005fsync-Builtins.html#g_t_005f_005fsync-Builtins
void gf44() {
  int i;
  __sync_fetch_and_add(&i, 0);  // NON_COMPLIANT
  __sync_fetch_and_sub(&i, 0);  // NON_COMPLIANT
  __sync_fetch_and_or(&i, 0);   // NON_COMPLIANT
  __sync_fetch_and_and(&i, 0);  // NON_COMPLIANT
  __sync_fetch_and_xor(&i, 0);  // NON_COMPLIANT
  __sync_fetch_and_nand(&i, 0); // NON_COMPLIANT
  __sync_add_and_fetch(&i, 0);  // NON_COMPLIANT
  __sync_sub_and_fetch(&i, 0);  // NON_COMPLIANT
  __sync_or_and_fetch(&i, 0);   // NON_COMPLIANT
  __sync_and_and_fetch(&i, 0);  // NON_COMPLIANT
  __sync_xor_and_fetch(&i, 0);  // NON_COMPLIANT
  __sync_nand_and_fetch(&i, 0); // NON_COMPLIANT

  __sync_bool_compare_and_swap(&i, 0, 0);
  __sync_val_compare_and_swap(&i, 0, 0);
  __sync_lock_test_and_set(&i, 0, 0);
  __sync_lock_release(&i, 0);
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Binary-constants.html#Binary-constants
void gf45() {
  int i = 0b101010; // NON_COMPLIANT[FALSE_NEGATIVE]
}

// Reference: https://gcc.gnu.org/onlinedocs/gcc/Thread-Local.html#Thread-Local
__thread int gf46; // NON_COMPLIANT[FALSE_NEGATIVE]

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Unnamed-Fields.html#Unnamed-Fields
void gf47() { // NON_COMPLIANT in versions < C11.
  struct {
    int a;
    union {
      int b;
      float c;
    };
    int d;
  } f;
}

// Reference:
// https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html#Other-Builtins
void gf48() {
  __builtin_alloca(
      0); // NON_COMPLIANT (all __builtin functions are non-compliant.)
}