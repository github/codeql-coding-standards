#include <stdbool.h>
#include <stdio.h>
// Note: Clang aims to support both clang and gcc extensions.
// This test case has been designed using lists compiled from:
// - https://clang.llvm.org/docs/LanguageExtensions.html
// - https://gcc.gnu.org/onlinedocs/gcc/C-Extensions.html

#ifdef __has_builtin // NON_COMPLIANT
#endif
#ifdef __has_constexpr_builtin // NON_COMPLIANT
#endif
#ifdef __has_feature // NON_COMPLIANT
#endif
#ifdef __has_extension // NON_COMPLIANT
#endif
#ifdef __has_c_attribute // NON_COMPLIANT
#endif
#ifdef __has_attribute // NON_COMPLIANT
#endif
#ifdef __has_declspec_attribute // NON_COMPLIANT
#endif
#ifdef __is_identifier // NON_COMPLIANT
#endif
#ifdef __has_include // NON_COMPLIANT
#endif
#ifdef __has_include_next // NON_COMPLIANT
#endif
#ifdef __has_warning // NON_COMPLIANT
#endif

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

typedef float float4 __attribute__((ext_vector_type(4))); // NON_COMPLIANT
typedef float float2 __attribute__((ext_vector_type(2))); // NON_COMPLIANT

// Requires additional compiler flags to change the architecture
// typedef __attribute__((neon_vector_type(8))) int8_t int8x8_t;
// typedef __attribute__((neon_polyvector_type(16))) poly8_t poly8x16_t;

typedef int int4 __attribute__((vector_size(4 * sizeof(int)))); // NON_COMPLIANT

typedef int v4si __attribute__((__vector_size__(16)));    // NON_COMPLIANT
typedef float float4 __attribute__((ext_vector_type(4))); // NON_COMPLIANT
typedef float float2 __attribute__((ext_vector_type(2))); // NON_COMPLIANT

//// GCC features
void gf1() {
  ({
    int y = 1;
    int z; // NON_COMPLIANT
    if (y > 0)
      z = y;
    else
      z = -y;
    z;
  });
}

void gf2() {
  // __label__ found; -- local labels not supported by clang
}

void gf3() {
  void *ptr;
  // goto *ptr; -- not supported in clang
}

void gf4() {
  // void gf4a(){  -- not supported in clang
  //
  // }
}

void gf5() {
  __builtin_setjmp(0);     // NON_COMPLIANT
  __builtin_longjmp(0, 1); // NON_COMPLIANT
}

void gf6() {
  // not supported by clang

  //__builtin_apply_args();
  //__builtin_apply(0, 0, 0);
  //__builtin_return(0);
  //__builtin_va_arg_pack();
  //__builtin_va_arg_pack_len();
}

void gf7() {
  int a = 0 ?: 0; // NON_COMPLIANT
}

void gf8() {
  typeof(int *); // NON_COMPLIANT
}

void gf9() {
  __int128 a; // NON_COMPLIANT
}

void gf10() {
  long long int a; // NON_COMPLIANT
}

void gf11() {
  __real__(0); // NON_COMPLIANT
  __imag__(0); // NON_COMPLIANT
}

void gf12() {}

void gf13() {
  // not supported on clang

  //_Decimal32 a;
  //_Decimal64 b;
  //_Decimal128 c;
}

void gf14() {
  // Not sure how to get this to work.
  // typedef _Complex float __attribute__((mode(TC))) _Complex128;
  // typedef _Complex float __attribute__((mode(XC))) _Complex80;
}

void gf15() {
  float f = 0x1.fp3; // NON_COMPLIANT
}

void gf16() {
  char contents[0]; // NON_COMPLIANT
}

void gf17() {
  // const __flash char ** p; // not supported in clang
}

void gf18() {
  // not supported by extractor - checked by looking for flags.

  // short _Fract, _Fract;
  // long _Fract;
}

struct gf19 {}; // NON_COMPLIANT

void gf20(int n) {
  // struct S { int x[n]; }; // will never be supported in clang
}

#define gf21(format, args...)                                                  \
  printf(format, args) // NON_COMPLIANT -- note the issue here is explicitly
                       // naming the arguments.
#define gf21a(format, ...) printf(format, __VA_ARGS__) // COMPLIANT

#define gf22                                                                   \
  "a"                                                                          \
  \     
"b" // NON_COMPLIANT - additional spaces after a backslash
#define gf22a                                                                  \
  "a"                                                                          \
  "b" // COMPLIANT

struct gf23s {
  int a[1];
};
struct gf23s gf23f();
void gf23() {
  gf23f().a[0]; // NON_COMPLIANT in C90
}

void gf24(int f, int g) {
  float beat_freqs[2] = {f - g, f + g}; // NON_COMPLIANT
}

void gf25t(int N, int M, double out[M][N], const double in[N][M]);
void gf25() {
  double x[3][2];
  double y[2][3];
  gf25t(3, 2, y,
        x); // NON_COMPLIANT - in ISO C the const qualifier is formally attached
            // to the element type of the array and not the array itself
}

struct gf26t {
  int a;
  char b[2];
} gf26v;
void gf26(int x, int y) {
  gf26v = ((struct gf26t){x + y, 'z', 0}); // NON_COMPLIANT - compound literal
}

void gf27() {
  int a[6] = {[4] = 29, [2] = 15}; // NON_COMPLIANT in C90.
}

void gf28() {
  int a;

  // switch(a){
  //     case: 0 ... 5:  // Not supported in clang.
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

void gf29() {
  int x;
  int y;
  union gf29u z;
  z = (union gf29u)x; // NON_COMPLIANT
  z = (union gf29u)y; // NON_COMPLIANT
}

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
  // __attribute__((assume(x == 42))); - Not supported in clang

  switch (x) {
  case 1:
    printf("");
    __attribute__((fallthrough)); // NON_COMPLIANT
  case 2:
    break;
  }
}

// Not supported in clang.
// int gf36 (uid_t);

// int
// gf36 (int x)
// {
//   return x == 0;
// }

void gf37() {
  int a$1; // NON_COMPLIANT
}

void gf38() {
  const char *c = "test\e"; // NON_COMPLIANT
}

struct gf39s {
  int x;
  char y;
} gf39v;

void gf39() {
  __alignof__(gf39v.x); // NON_COMPLIANT
}

// enum gf40 {}; // not supported in clang

void gf41() {
  printf("__FUNCTION__ = %s\n", __FUNCTION__);               // NON_COMPLIANT
  printf("__PRETTY_FUNCTION__ = %s\n", __PRETTY_FUNCTION__); // NON_COMPLIANT
}

void gf42() {
  __builtin_extract_return_addr(0);
  __builtin_frob_return_addr(0);
  __builtin_frame_address(0);
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

void gf45() {
  int i = 0b101010; // NON_COMPLIANT
}

__thread int gf46; // NON_COMPLIANT

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

void gf48(){
    __builtin_alloca(0); // NON_COMPLIANT (all __builtin functions are non-compliant.)
}