// Assumed platform in qltest is linux_x86_64, so
// int, long, long long sizes are assumed to be 32, 64, 64 bits respectively

// The type of an integer constant is determined by "6.4.4.1 Integer constants"
// in the C11 Standard. The principle is that any decimal integer constant will
// be signed, unless it has the `U` or `u` suffix. Any hexadecimal integer will
// depend on whether it is larger than the maximum value of the smallest signed
// integer value that can hold the value. So the signedness depends on the
// magnitude of the constant.

void test_decimal_constants() {
  0;          // COMPLIANT
  2147483648; // COMPLIANT - larger than int, but decimal constants never use
              // unsigned without the suffix, so will be `long`
  4294967296; // COMPLIANT - larger than unsigned int, still `long`
  9223372036854775807; // COMPLIANT - max long int
  // 9223372036854775808; Not a valid integer constant, out of signed range
  0U;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648U;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296U;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807U; // COMPLIANT - max long int
  9223372036854775808U; // COMPLIANT - explicitly unsigned, so can go large than
                        // max long int
  0u;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648u;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296u;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807u; // COMPLIANT - max long int
  9223372036854775808u; // COMPLIANT - explicitly unsigned, so can go large than
                        // max long int

  // l suffix
  0l;                   // COMPLIANT
  2147483648l;          // COMPLIANT - within the range of long int
  4294967296l;          // COMPLIANT - within the range of long int
  9223372036854775807l; // COMPLIANT - max long int
  // 9223372036854775808l; Not a valid integer constant, out of signed range
  0lU;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648lU;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296lU;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807lU; // COMPLIANT - max long int
  9223372036854775808lU; // COMPLIANT - explicitly unsigned, so can go large
                         // than max long int
  0lu;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648lu;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296lu;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807lu; // COMPLIANT - max long int
  9223372036854775808lu; // COMPLIANT - explicitly unsigned, so can go large
                         // than max long int

  // L suffix
  0L;                   // COMPLIANT
  2147483648L;          // COMPLIANT - within the range of long int
  4294967296L;          // COMPLIANT - within the range of long int
  9223372036854775807L; // COMPLIANT - max long int
  // 9223372036854775808L; Not a valid integer constant, out of signed range
  0LU;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648LU;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296LU;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807LU; // COMPLIANT - max long int
  9223372036854775808LU; // COMPLIANT - explicitly unsigned, so can go large
                         // than max long int
  0Lu;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648Lu;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296Lu;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807Lu; // COMPLIANT - max long int
  9223372036854775808Lu; // COMPLIANT - explicitly unsigned, so can go large
                         // than max long int

  // ll suffix
  0ll;                   // COMPLIANT
  2147483648ll;          // COMPLIANT - within the range of long long int
  4294967296ll;          // COMPLIANT - within the range of long long int
  9223372036854775807ll; // COMPLIANT - max long long int
  // 9223372036854775808ll; Not a valid integer constant, out of signed range
  0llU;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648llU;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296llU;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807llU; // COMPLIANT - max long long int
  9223372036854775808llU; // COMPLIANT - explicitly unsigned, so can go large
                          // than max long long int
  0llu;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648llu;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296llu;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807llu; // COMPLIANT - max long long int
  9223372036854775808llu; // COMPLIANT - explicitly unsigned, so can go large
                          // than max long long int

  // LL suffix
  0LL;                   // COMPLIANT
  2147483648LL;          // COMPLIANT - within the range of long long int
  4294967296LL;          // COMPLIANT - within the range of long long int
  9223372036854775807LL; // COMPLIANT - max long long int
  // 9223372036854775808LL; Not a valid integer constant, out of signed range
  0LLU;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648LLU;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296LLU;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807LLU; // COMPLIANT - max long long int
  9223372036854775808LLU; // COMPLIANT - explicitly unsigned, so can go large
                          // than max long long int
  0LLu;                   // COMPLIANT - unsigned, but uses the suffix correctly
  2147483648LLu;          // COMPLIANT - unsigned, but uses the suffix correctly
  4294967296LLu;          // COMPLIANT - unsigned, but uses the suffix correctly
  9223372036854775807LLu; // COMPLIANT - max long long int
  9223372036854775808LLu; // COMPLIANT - explicitly unsigned, so can go large
                          // than max long long int
}

void test_hexadecimal_constants() {
  0x0;        // COMPLIANT - uses signed int
  0x7FFFFFFF; // COMPLIANT - max value held by signed int
  0x80000000; // NON_COMPLIANT - larger than max signed int, so will be unsigned
              // int
  0x100000000; // COMPLIANT - larger than unsigned int, but smaller than long
               // int
  0x7FFFFFFFFFFFFFFF;  // COMPLIANT - max long int
  0x8000000000000000;  // NON_COMPLIANT - larger than long int, so will be
                       // unsigned long int
  0x0U;                // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFU;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000U;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000U;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000U; // COMPLIANT - unsigned, but uses the suffix correctly
  0x0u;                // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000u;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000u;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFu; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000u; // COMPLIANT - unsigned, but uses the suffix correctly

  // Use of the `l` suffix
  0x0l;         // COMPLIANT - uses signed int
  0x7FFFFFFFl;  // COMPLIANT - max value held by signed int
  0x80000000l;  // COMPLIANT - larger than max signed int, but smaller than long
                // int
  0x100000000l; // COMPLIANT - larger than unsigned int, but smaller than long
                // int
  0x7FFFFFFFFFFFFFFFl;  // COMPLIANT - max long int
  0x8000000000000000l;  // NON_COMPLIANT - larger than long int, so will be
                        // unsigned long int
  0x0lU;                // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFlU;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000lU;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000lU;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFlU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000lU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x0lu;                // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFlu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000lu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000lu;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFlu; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000lu; // COMPLIANT - unsigned, but uses the suffix correctly

  // Use of the `L` suffix
  0x0L;         // COMPLIANT - uses signed int
  0x7FFFFFFFL;  // COMPLIANT - max value held by signed int
  0x80000000L;  // COMPLIANT - larger than max signed int, but smaller than long
                // int
  0x100000000L; // COMPLIANT - larger than unsigned int, but smaller than long
                // int
  0x7FFFFFFFFFFFFFFFL;  // COMPLIANT - max long int
  0x8000000000000000L;  // NON_COMPLIANT - larger than long int, so will be
                        // unsigned long int
  0x0LU;                // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFLU;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000LU;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000LU;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFLU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000LU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x0Lu;                // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFLu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000Lu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000Lu;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFLu; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000Lu; // COMPLIANT - unsigned, but uses the suffix correctly

  // Use of the `ll` suffix
  0x0ll;        // COMPLIANT - uses signed int
  0x7FFFFFFFll; // COMPLIANT - max value held by signed int
  0x80000000ll; // COMPLIANT - larger than max signed int, but smaller than long
                // long int
  0x100000000ll; // COMPLIANT - larger than unsigned int, but smaller than long
                 // long int
  0x7FFFFFFFFFFFFFFFll; // COMPLIANT - max long long int
  0x8000000000000000ll; // NON_COMPLIANT - larger than long long int, so will be
                        // unsigned long long int
  0x0llU;               // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFllU;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000llU;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000llU;       // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFllU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000llU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x0llu;                // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFllu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000llu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000llu;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFllu; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000llu; // COMPLIANT - unsigned, but uses the suffix correctly

  // Use of the `LL` suffix
  0x0LL;        // COMPLIANT - uses signed int
  0x7FFFFFFFLL; // COMPLIANT - max value held by signed int
  0x80000000LL; // COMPLIANT - larger than max signed int, but smaller than long
                // long int
  0x100000000LL; // COMPLIANT - larger than unsigned int, but smaller than long
                 // long int
  0x7FFFFFFFFFFFFFFFLL; // COMPLIANT - max long long int
  0x8000000000000000LL; // NON_COMPLIANT - larger than long long int, so will be
                        // unsigned long long int
  0x0LLU;               // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFLLU;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000LLU;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000LLU;       // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFLLU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000LLU; // COMPLIANT - unsigned, but uses the suffix correctly
  0x0LLu;                // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFLLu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x80000000LLu;         // COMPLIANT - unsigned, but uses the suffix correctly
  0x100000000LLu;        // COMPLIANT - unsigned, but uses the suffix correctly
  0x7FFFFFFFFFFFFFFFLLu; // COMPLIANT - unsigned, but uses the suffix correctly
  0x8000000000000000LLu; // COMPLIANT - unsigned, but uses the suffix correctly
}

void test_octal_constants() {
  00;           // COMPLIANT - uses signed int
  017777777777; // COMPLIANT - max value held by signed int
  020000000000; // NON_COMPLIANT - larger than max signed int, so will be
                // unsigned int
  040000000000; // COMPLIANT - larger than unsigned int, but smaller than long
                // int
  0777777777777777777777;  // COMPLIANT - max long int
  01000000000000000000000; // NON_COMPLIANT - larger than long int, so will be
                           // unsigned long int
  00U;           // COMPLIANT - unsigned, but uses the suffix correctly
  017777777777U; // COMPLIANT - unsigned, but uses the suffix correctly
  020000000000U; // COMPLIANT - unsigned, but uses the suffix correctly
  040000000000U; // COMPLIANT - unsigned, but uses the suffix correctly
  0777777777777777777777U;  // COMPLIANT - unsigned, but uses the suffix
                            // correctly
  01000000000000000000000U; // COMPLIANT - unsigned, but uses the suffix
                            // correctly

  // Use of the `l` suffix
  00l;                      // COMPLIANT - uses signed long
  017777777777l;            // COMPLIANT - uses signed long
  020000000000l;            // COMPLIANT - uses signed long
  040000000000l;            // COMPLIANT - uses signed long
  0777777777777777777777l;  // COMPLIANT - max long int
  01000000000000000000000l; // NON_COMPLIANT - larger than long int, so will be
                            // unsigned long int
  00Ul;           // COMPLIANT - unsigned, but uses the suffix correctly
  017777777777Ul; // COMPLIANT - unsigned, but uses the suffix correctly
  020000000000Ul; // COMPLIANT - unsigned, but uses the suffix correctly
  040000000000Ul; // COMPLIANT - unsigned, but uses the suffix correctly
  0777777777777777777777Ul;  // COMPLIANT - unsigned, but uses the suffix
                             // correctly
  01000000000000000000000Ul; // COMPLIANT - unsigned, but uses the suffix
                             // correctly

  // Use of the `L` suffix
  00L;                      // COMPLIANT - uses signed long
  017777777777L;            // COMPLIANT - uses signed long
  020000000000L;            // COMPLIANT - uses signed long
  040000000000L;            // COMPLIANT - uses signed long
  0777777777777777777777L;  // COMPLIANT - COMPLIANT - uses signed long
  01000000000000000000000L; // NON_COMPLIANT - larger than long int, so will be
                            // unsigned long int
  00UL;           // COMPLIANT - unsigned, but uses the suffix correctly
  017777777777UL; // COMPLIANT - unsigned, but uses the suffix correctly
  020000000000UL; // COMPLIANT - unsigned, but uses the suffix correctly
  040000000000UL; // COMPLIANT - unsigned, but uses the suffix correctly
  0777777777777777777777UL;  // COMPLIANT - unsigned, but uses the suffix
                             // correctly
  01000000000000000000000UL; // COMPLIANT - unsigned, but uses the suffix
                             // correctly

  // Use of the `ll` suffix
  00ll;                      // COMPLIANT - uses signed long long
  017777777777ll;            // COMPLIANT - uses signed long long
  020000000000ll;            // COMPLIANT - uses signed long long
  040000000000ll;            // COMPLIANT - uses signed long long
  0777777777777777777777ll;  // COMPLIANT - max long int
  01000000000000000000000ll; // NON_COMPLIANT - larger than long int, so will be
                             // unsigned long int
  00Ull;           // COMPLIANT - unsigned, but uses the suffix correctly
  017777777777Ull; // COMPLIANT - unsigned, but uses the suffix correctly
  020000000000Ull; // COMPLIANT - unsigned, but uses the suffix correctly
  040000000000Ull; // COMPLIANT - unsigned, but uses the suffix correctly
  0777777777777777777777Ull;  // COMPLIANT - unsigned, but uses the suffix
                              // correctly
  01000000000000000000000Ull; // COMPLIANT - unsigned, but uses the suffix
                              // correctly

  // Use of the `LL` suffix
  00LL;                      // COMPLIANT - uses signed long long
  017777777777LL;            // COMPLIANT - uses signed long long
  020000000000LL;            // COMPLIANT - uses signed long long
  040000000000LL;            // COMPLIANT - uses signed long long
  0777777777777777777777LL;  // COMPLIANT - max long int
  01000000000000000000000LL; // NON_COMPLIANT - larger than long int, so will be
                             // unsigned long int
  00ULL;           // COMPLIANT - unsigned, but uses the suffix correctly
  017777777777ULL; // COMPLIANT - unsigned, but uses the suffix correctly
  020000000000ULL; // COMPLIANT - unsigned, but uses the suffix correctly
  040000000000ULL; // COMPLIANT - unsigned, but uses the suffix correctly
  0777777777777777777777ULL;  // COMPLIANT - unsigned, but uses the suffix
                              // correctly
  01000000000000000000000ULL; // COMPLIANT - unsigned, but uses the suffix
                              // correctly
}

#define COMPLIANT_VAL 0x80000000U
#define NON_COMPLIANT_VAL 0x80000000

void test_macro() {
  COMPLIANT_VAL;     // COMPLIANT
  NON_COMPLIANT_VAL; // NON_COMPLIANT[FALSE_NEGATIVE] - cannot determine suffix
                     // in macro expansions
}