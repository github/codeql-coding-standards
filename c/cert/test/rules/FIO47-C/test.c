#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <wchar.h>

signed int v_signed_int = 42;
short v_short = 42;
signed char v_signed_char = 42;
long v_long = 42;
long long v_long_long = 42;
intmax_t v_intmax_t = 42;
size_t v_size_t = 42;
ptrdiff_t v_ptrdiff_t = 42;
unsigned int v_unsigned_int = 42;
unsigned short v_unsigned_short = 42;
unsigned char v_unsigned_char = 42;
unsigned long v_unsigned_long = 42;
unsigned long long v_unsigned_long_long = 42;
uintmax_t v_uintmax_t = 42;
double v_double = 42.0;
long double v_long_double = 42.0;
int v_int = 42;
wint_t v_wint_t = 42;
char *v_char_ptr = "42";
wchar_t *v_wchar_t_ptr = L"42";
void *v_void_ptr = &v_signed_int;
int *v_int_ptr = &v_int;
short *v_short_ptr = &v_short;
long *v_long_ptr = &v_long;
long long *v_long_long_ptr = &v_long_long;
intmax_t *v_intmax_t_ptr = &v_intmax_t;
size_t *v_size_t_ptr = &v_size_t;
ptrdiff_t *v_ptrdiff_t_ptr = &v_ptrdiff_t;

void f1() {
  const char *s = "Hello";
  printf("Strings - padding:\n");
  printf("\t.%10s.\n\t.%-10s.\n\t.%*s.\n", // COMPLIANT
         s, s, 10, s);
  printf("Strings - truncating:\n");
  printf("\t%.4s\n\t%.*s\n", s, 3, s); // COMPLIANT

  printf("Characters:\t%c %%\n", 65); // COMPLIANT

  printf("Integers\n");
  printf("Decimal:\t%i %d %.6i %i %.0i %+i %i\n", // COMPLIANT
         1, 2, 3, 0, 0, 4, -4);
  printf("Hexadecimal:\t%x %x %X %#x\n", 5, 10, 10, 6); // COMPLIANT
  printf("Octal:\t\t%o %#o %#o\n", 10, 10, 4);          // COMPLIANT

  printf("Floating point\n");
  printf("Rounding:\t%f %.0f %.32f\n", 1.5, 1.5, 1.3);    // COMPLIANT
  printf("Padding:\t%05.2f %.2f %5.2f\n", 1.5, 1.5, 1.5); // COMPLIANT
  printf("Scientific:\t%E %e\n", 1.5, 1.5);               // COMPLIANT
  printf("Hexadecimal:\t%a %A\n", 1.5, 1.5);              // COMPLIANT
}

void test_invalid_specifier() {
  printf("%d", 42); // COMPLIANT
  printf("%b", 42); // NON_COMPLIANT
}

void test_incompatible_flag() {
  printf("%'-d", v_signed_int);  // COMPLIANT
  printf("%'-#d", v_signed_int); // NON_COMPLIANT

  printf("%'d", v_signed_int); // COMPLIANT
  printf("%-d", v_signed_int); // COMPLIANT
  printf("%+d", v_signed_int); // COMPLIANT
  printf("% d", v_signed_int); // COMPLIANT
  printf("%#d", v_signed_int); // NON_COMPLIANT
  printf("%0d", v_signed_int); // COMPLIANT

  printf("%'i", v_signed_int); // COMPLIANT
  printf("%-i", v_signed_int); // COMPLIANT
  printf("%+i", v_signed_int); // COMPLIANT
  printf("% i", v_signed_int); // COMPLIANT
  printf("%#i", v_signed_int); // NON_COMPLIANT
  printf("%0i", v_signed_int); // COMPLIANT

  printf("%'o", v_unsigned_int); // NON_COMPLIANT
  printf("%-o", v_unsigned_int); // COMPLIANT
  printf("%+o", v_unsigned_int); // COMPLIANT
  printf("% o", v_unsigned_int); // COMPLIANT
  printf("%#o", v_unsigned_int); // COMPLIANT
  printf("%0o", v_unsigned_int); // COMPLIANT

  printf("%'u", v_unsigned_int); // COMPLIANT
  printf("%-u", v_unsigned_int); // COMPLIANT
  printf("%+u", v_unsigned_int); // COMPLIANT
  printf("% u", v_unsigned_int); // COMPLIANT
  printf("%#u", v_unsigned_int); // NON_COMPLIANT
  printf("%0u", v_unsigned_int); // COMPLIANT

  printf("%'x", v_unsigned_int); // NON_COMPLIANT
  printf("%-x", v_unsigned_int); // COMPLIANT
  printf("%+x", v_unsigned_int); // COMPLIANT
  printf("% x", v_unsigned_int); // COMPLIANT
  printf("%#x", v_unsigned_int); // COMPLIANT
  printf("%0x", v_unsigned_int); // COMPLIANT

  printf("%'X", v_unsigned_int); // NON_COMPLIANT
  printf("%-X", v_unsigned_int); // COMPLIANT
  printf("%+X", v_unsigned_int); // COMPLIANT
  printf("% X", v_unsigned_int); // COMPLIANT
  printf("%#X", v_unsigned_int); // COMPLIANT
  printf("%0X", v_unsigned_int); // COMPLIANT

  printf("%'f", v_double); // COMPLIANT
  printf("%-f", v_double); // COMPLIANT
  printf("%+f", v_double); // COMPLIANT
  printf("% f", v_double); // COMPLIANT
  printf("%#f", v_double); // COMPLIANT
  printf("%0f", v_double); // COMPLIANT

  printf("%'F", v_double); // COMPLIANT
  printf("%-F", v_double); // COMPLIANT
  printf("%+F", v_double); // COMPLIANT
  printf("% F", v_double); // COMPLIANT
  printf("%#F", v_double); // COMPLIANT
  printf("%0F", v_double); // COMPLIANT

  printf("%'e", v_double); // NON_COMPLIANT
  printf("%-e", v_double); // COMPLIANT
  printf("%+e", v_double); // COMPLIANT
  printf("% e", v_double); // COMPLIANT
  printf("%#e", v_double); // COMPLIANT
  printf("%0e", v_double); // COMPLIANT

  printf("%'E", v_double); // NON_COMPLIANT
  printf("%-E", v_double); // COMPLIANT
  printf("%+E", v_double); // COMPLIANT
  printf("% E", v_double); // COMPLIANT
  printf("%#E", v_double); // COMPLIANT
  printf("%0E", v_double); // COMPLIANT

  printf("%'g", v_double); // COMPLIANT
  printf("%-g", v_double); // COMPLIANT
  printf("%+g", v_double); // COMPLIANT
  printf("% g", v_double); // COMPLIANT
  printf("%#g", v_double); // COMPLIANT
  printf("%0g", v_double); // COMPLIANT

  printf("%'G", v_double); // COMPLIANT
  printf("%-G", v_double); // COMPLIANT
  printf("%+G", v_double); // COMPLIANT
  printf("% G", v_double); // COMPLIANT
  printf("%#G", v_double); // COMPLIANT
  printf("%0G", v_double); // COMPLIANT

  printf("%'a", v_double); // COMPLIANT
  printf("%-a", v_double); // COMPLIANT
  printf("%+a", v_double); // COMPLIANT
  printf("% a", v_double); // COMPLIANT
  printf("%#a", v_double); // COMPLIANT
  printf("%0a", v_double); // COMPLIANT

  printf("%'A", v_double); // COMPLIANT
  printf("%-A", v_double); // COMPLIANT
  printf("%+A", v_double); // COMPLIANT
  printf("% A", v_double); // COMPLIANT
  printf("%#A", v_double); // COMPLIANT
  printf("%0A", v_double); // COMPLIANT

  printf("%'c", v_int); // NON_COMPLIANT
  printf("%-c", v_int); // COMPLIANT
  printf("%+c", v_int); // COMPLIANT
  printf("% c", v_int); // COMPLIANT
  printf("%#c", v_int); // NON_COMPLIANT
  printf("%0c", v_int); // NON_COMPLIANT

  printf("%'s", v_char_ptr); // NON_COMPLIANT
  printf("%-s", v_char_ptr); // COMPLIANT
  printf("%+s", v_char_ptr); // COMPLIANT
  printf("% s", v_char_ptr); // COMPLIANT
  printf("%#s", v_char_ptr); // NON_COMPLIANT
  printf("%0s", v_char_ptr); // NON_COMPLIANT

  printf("%'p", v_void_ptr); // NON_COMPLIANT
  printf("%-p", v_void_ptr); // COMPLIANT
  printf("%+p", v_void_ptr); // COMPLIANT
  printf("% p", v_void_ptr); // COMPLIANT
  printf("%#p", v_void_ptr); // NON_COMPLIANT
  printf("%0p", v_void_ptr); // NON_COMPLIANT

  printf("%'n", v_int_ptr); // NON_COMPLIANT
  printf("%-n", v_int_ptr); // NON_COMPLIANT
  printf("%+n", v_int_ptr); // NON_COMPLIANT
  printf("% n", v_int_ptr); // NON_COMPLIANT
  printf("%#n", v_int_ptr); // NON_COMPLIANT
  printf("%0n", v_int_ptr); // NON_COMPLIANT

  printf("%'C", v_wint_t); // NON_COMPLIANT
  printf("%-C", v_wint_t); // COMPLIANT
  printf("%+C", v_wint_t); // COMPLIANT
  printf("% C", v_wint_t); // COMPLIANT
  printf("%#C", v_wint_t); // NON_COMPLIANT
  printf("%0C", v_wint_t); // NON_COMPLIANT

  printf("%'S", v_wchar_t_ptr); // NON_COMPLIANT
  printf("%-S", v_wchar_t_ptr); // COMPLIANT
  printf("%+S", v_wchar_t_ptr); // COMPLIANT
  printf("% S", v_wchar_t_ptr); // COMPLIANT
  printf("%#S", v_wchar_t_ptr); // NON_COMPLIANT
  printf("%0S", v_wchar_t_ptr); // NON_COMPLIANT

  printf("%%");  // COMPLIANT
  printf("%'%"); // NON_COMPLIANT
  printf("%-%"); // NON_COMPLIANT
  printf("%+%"); // NON_COMPLIANT
  printf("% %"); // NON_COMPLIANT
  printf("%#%"); // NON_COMPLIANT
  printf("%0%"); // NON_COMPLIANT
  printf("%0%"); // NON_COMPLIANT
}

void test_incompatible_length() {
  printf("%hd", v_short);        // COMPLIANT
  printf("%hhd", v_signed_char); // COMPLIANT
  printf("%ld", v_long);         // COMPLIANT
  printf("%lld", v_long_long);   // COMPLIANT
  printf("%jd", v_intmax_t);     // COMPLIANT
  printf("%zd", v_size_t);       // COMPLIANT
  printf("%td", v_ptrdiff_t);    // COMPLIANT
  printf("%Ld", v_long_long);    // NON_COMPLIANT

  printf("%hi", v_short);        // COMPLIANT
  printf("%hhi", v_signed_char); // COMPLIANT
  printf("%li", v_long);         // COMPLIANT
  printf("%lli", v_long_long);   // COMPLIANT
  printf("%ji", v_intmax_t);     // COMPLIANT
  printf("%zi", v_size_t);       // COMPLIANT
  printf("%ti", v_ptrdiff_t);    // COMPLIANT
  printf("%Li", v_long_long);    // NON_COMPLIANT

  printf("%ho", v_unsigned_short);      // COMPLIANT
  printf("%hho", v_unsigned_char);      // COMPLIANT
  printf("%lo", v_unsigned_long);       // COMPLIANT
  printf("%llo", v_unsigned_long_long); // COMPLIANT
  printf("%jo", v_uintmax_t);           // COMPLIANT
  printf("%zo", v_size_t);              // COMPLIANT
  printf("%to", v_ptrdiff_t);           // COMPLIANT
  printf("%Lo", v_unsigned_long_long);  // NON_COMPLIANT

  printf("%hu", v_unsigned_short);      // COMPLIANT
  printf("%hhu", v_unsigned_char);      // COMPLIANT
  printf("%lu", v_unsigned_long);       // COMPLIANT
  printf("%llu", v_unsigned_long_long); // COMPLIANT
  printf("%ju", v_uintmax_t);           // COMPLIANT
  printf("%zu", v_size_t);              // COMPLIANT
  printf("%tu", v_ptrdiff_t);           // COMPLIANT
  printf("%Lu", v_unsigned_long_long);  // NON_COMPLIANT

  printf("%hx", v_unsigned_short);      // COMPLIANT
  printf("%hhx", v_unsigned_char);      // COMPLIANT
  printf("%lx", v_unsigned_long);       // COMPLIANT
  printf("%llx", v_unsigned_long_long); // COMPLIANT
  printf("%jx", v_uintmax_t);           // COMPLIANT
  printf("%zx", v_size_t);              // COMPLIANT
  printf("%tx", v_ptrdiff_t);           // COMPLIANT
  printf("%Lx", v_unsigned_long_long);  // NON_COMPLIANT

  printf("%hX", v_unsigned_short);      // COMPLIANT
  printf("%hhX", v_unsigned_char);      // COMPLIANT
  printf("%lX", v_unsigned_long);       // COMPLIANT
  printf("%llX", v_unsigned_long_long); // COMPLIANT
  printf("%jX", v_uintmax_t);           // COMPLIANT
  printf("%zX", v_size_t);              // COMPLIANT
  printf("%tX", v_ptrdiff_t);           // COMPLIANT
  printf("%LX", v_unsigned_long_long);  // NON_COMPLIANT

  printf("%hf", v_double);       // NON_COMPLIANT
  printf("%hhf", v_double);      // NON_COMPLIANT
  printf("%lf", v_double);       // COMPLIANT
  printf("%llf", v_long_double); // COMPLIANT
  printf("%jf", v_double);       // NON_COMPLIANT
  printf("%zf", v_double);       // NON_COMPLIANT
  printf("%tf", v_double);       // NON_COMPLIANT
  printf("%Lf", v_long_double);  // COMPLIANT

  printf("%hF", v_double);       // NON_COMPLIANT
  printf("%hhF", v_double);      // NON_COMPLIANT
  printf("%lF", v_double);       // COMPLIANT
  printf("%llF", v_long_double); // COMPLIANT
  printf("%jF", v_double);       // NON_COMPLIANT
  printf("%zF", v_double);       // NON_COMPLIANT
  printf("%tF", v_double);       // NON_COMPLIANT
  printf("%LF", v_long_double);  // COMPLIANT

  printf("%he", v_double);       // NON_COMPLIANT
  printf("%hhe", v_double);      // NON_COMPLIANT
  printf("%le", v_double);       // COMPLIANT
  printf("%lle", v_long_double); // COMPLIANT
  printf("%je", v_double);       // NON_COMPLIANT
  printf("%ze", v_double);       // NON_COMPLIANT
  printf("%te", v_double);       // NON_COMPLIANT
  printf("%Le", v_long_double);  // COMPLIANT

  printf("%hE", v_double);       // NON_COMPLIANT
  printf("%hhE", v_double);      // NON_COMPLIANT
  printf("%lE", v_double);       // COMPLIANT
  printf("%llE", v_long_double); // COMPLIANT
  printf("%jE", v_double);       // NON_COMPLIANT
  printf("%zE", v_double);       // NON_COMPLIANT
  printf("%tE", v_double);       // NON_COMPLIANT
  printf("%LE", v_long_double);  // COMPLIANT

  printf("%hg", v_double);       // NON_COMPLIANT
  printf("%hhg", v_double);      // NON_COMPLIANT
  printf("%lg", v_double);       // COMPLIANT
  printf("%llg", v_long_double); // COMPLIANT
  printf("%jg", v_double);       // NON_COMPLIANT
  printf("%zg", v_double);       // NON_COMPLIANT
  printf("%tg", v_double);       // NON_COMPLIANT
  printf("%Lg", v_long_double);  // COMPLIANT

  printf("%hG", v_double);       // NON_COMPLIANT
  printf("%hhG", v_double);      // NON_COMPLIANT
  printf("%lG", v_double);       // COMPLIANT
  printf("%llG", v_long_double); // COMPLIANT
  printf("%jG", v_double);       // NON_COMPLIANT
  printf("%zG", v_double);       // NON_COMPLIANT
  printf("%tG", v_double);       // NON_COMPLIANT
  printf("%LG", v_long_double);  // COMPLIANT

  printf("%ha", v_double);       // NON_COMPLIANT
  printf("%hha", v_double);      // NON_COMPLIANT
  printf("%la", v_double);       // COMPLIANT
  printf("%lla", v_long_double); // COMPLIANT
  printf("%ja", v_double);       // NON_COMPLIANT
  printf("%za", v_double);       // NON_COMPLIANT
  printf("%ta", v_double);       // NON_COMPLIANT
  printf("%La", v_long_double);  // COMPLIANT

  printf("%hA", v_double);       // NON_COMPLIANT
  printf("%hhA", v_double);      // NON_COMPLIANT
  printf("%lA", v_double);       // COMPLIANT
  printf("%llA", v_long_double); // COMPLIANT
  printf("%jA", v_double);       // NON_COMPLIANT
  printf("%zA", v_double);       // NON_COMPLIANT
  printf("%tA", v_double);       // NON_COMPLIANT
  printf("%LA", v_long_double);  // COMPLIANT

  printf("%hc", v_int);    // NON_COMPLIANT
  printf("%hhc", v_int);   // NON_COMPLIANT
  printf("%lc", v_wint_t); // COMPLIANT
  printf("%llc", v_int);   // NON_COMPLIANT
  printf("%jc", v_int);    // NON_COMPLIANT
  printf("%zc", v_int);    // NON_COMPLIANT
  printf("%tc", v_int);    // NON_COMPLIANT
  printf("%Lc", v_int);    // NON_COMPLIANT

  printf("%hs", v_char_ptr);    // NON_COMPLIANT
  printf("%hhs", v_char_ptr);   // NON_COMPLIANT
  printf("%ls", v_wchar_t_ptr); // COMPLIANT
  printf("%lls", v_char_ptr);   // NON_COMPLIANT
  printf("%js", v_char_ptr);    // NON_COMPLIANT
  printf("%zs", v_char_ptr);    // NON_COMPLIANT
  printf("%ts", v_char_ptr);    // NON_COMPLIANT
  printf("%Ls", v_char_ptr);    // NON_COMPLIANT

  printf("%hp", v_void_ptr);  // NON_COMPLIANT
  printf("%hhp", v_void_ptr); // NON_COMPLIANT
  printf("%lp", v_void_ptr);  // NON_COMPLIANT
  printf("%llp", v_void_ptr); // NON_COMPLIANT
  printf("%jp", v_void_ptr);  // NON_COMPLIANT
  printf("%zp", v_void_ptr);  // NON_COMPLIANT
  printf("%tp", v_void_ptr);  // NON_COMPLIANT
  printf("%Lp", v_void_ptr);  // NON_COMPLIANT

  printf("%hn", v_short_ptr);      // COMPLIANT
  printf("%hhn", v_char_ptr);      // COMPLIANT
  printf("%ln", v_long_ptr);       // COMPLIANT
  printf("%lln", v_long_long_ptr); // COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%jn", v_intmax_t_ptr); // COMPLIANT[FALSE_POSITIVE]
  // FP from WrongTypeFormatArguments.ql
  printf("%zn", v_size_t_ptr); // COMPLIANT[FALSE_POSITIVE]
  // FP from WrongTypeFormatArguments.ql
  printf("%tn", v_ptrdiff_t_ptr); // COMPLIANT[FALSE_POSITIVE]
  printf("%Ln", v_long_long_ptr); // NON_COMPLIANT

  printf("%hC", v_wint_t);  // NON_COMPLIANT
  printf("%hhC", v_wint_t); // NON_COMPLIANT
  printf("%lC", v_wint_t);  // NON_COMPLIANT
  printf("%llC", v_wint_t); // NON_COMPLIANT
  printf("%jC", v_wint_t);  // NON_COMPLIANT
  printf("%zC", v_wint_t);  // NON_COMPLIANT
  printf("%tC", v_wint_t);  // NON_COMPLIANT
  printf("%LC", v_wint_t);  // NON_COMPLIANT

  printf("%hS", v_char_ptr);     // NON_COMPLIANT
  printf("%hhS", v_wchar_t_ptr); // NON_COMPLIANT
  printf("%lS", v_wchar_t_ptr);  // NON_COMPLIANT
  printf("%llS", v_wchar_t_ptr); // NON_COMPLIANT
  printf("%jS", v_wchar_t_ptr);  // NON_COMPLIANT
  printf("%zS", v_wchar_t_ptr);  // NON_COMPLIANT
  printf("%tS", v_wchar_t_ptr);  // NON_COMPLIANT
  printf("%LS", v_wchar_t_ptr);  // NON_COMPLIANT

  printf("%h%");  // NON_COMPLIANT
  printf("%hh%"); // NON_COMPLIANT
  printf("%l%");  // NON_COMPLIANT
  printf("%ll%"); // NON_COMPLIANT
  printf("%j%");  // NON_COMPLIANT
  printf("%z%");  // NON_COMPLIANT
  printf("%t%");  // NON_COMPLIANT
  printf("%L%");  // NON_COMPLIANT
}
void test_incompatible_conversion() {
  printf(""); // COMPLIANT
  printf(""); // NON_COMPLIANT
}
void test_wrong_arg_type() {
  // wrong width type
  printf("%*d", 2, 42);          // COMPLIANT
  printf("%*d", v_char_ptr, 42); // NON_COMPLIANT

  // wrong precision type
  printf("%.*d", 2, 42);          // COMPLIANT
  printf("%.*d", v_char_ptr, 42); // NON_COMPLIANT

  // compliant cases are in test_incompatible_flag() and
  // test_incompatible_length()
  printf("%d", v_char_ptr);   // NON_COMPLIANT
  printf("%hd", v_char_ptr);  // NON_COMPLIANT
  printf("%hhd", v_char_ptr); // NON_COMPLIANT
  printf("%ld", v_char_ptr);  // NON_COMPLIANT
  printf("%lld", v_char_ptr); // NON_COMPLIANT
  printf("%jd", v_char_ptr);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%zd", v_char_ptr);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%td", v_char_ptr);  // NON_COMPLIANT

  printf("%i", v_char_ptr);   // NON_COMPLIANT
  printf("%hi", v_char_ptr);  // NON_COMPLIANT
  printf("%hhi", v_char_ptr); // NON_COMPLIANT
  printf("%li", v_char_ptr);  // NON_COMPLIANT
  printf("%lli", v_char_ptr); // NON_COMPLIANT
  printf("%ji", v_char_ptr);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%zi", v_char_ptr);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%ti", v_char_ptr);  // NON_COMPLIANT

  printf("%o", v_char_ptr);   // NON_COMPLIANT
  printf("%ho", v_char_ptr);  // NON_COMPLIANT
  printf("%hho", v_char_ptr); // NON_COMPLIANT
  printf("%lo", v_char_ptr);  // NON_COMPLIANT
  printf("%llo", v_char_ptr); // NON_COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%jo", v_char_ptr); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%zo", v_char_ptr); // NON_COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%to", v_char_ptr); // NON_COMPLIANT[FALSE_NEGATIVE]

  printf("%u", v_char_ptr);   // NON_COMPLIANT
  printf("%hu", v_char_ptr);  // NON_COMPLIANT
  printf("%hhu", v_char_ptr); // NON_COMPLIANT
  printf("%lu", v_char_ptr);  // NON_COMPLIANT
  printf("%llu", v_char_ptr); // NON_COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%ju", v_char_ptr); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%zu", v_char_ptr); // NON_COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%tu", v_char_ptr); // NON_COMPLIANT[FALSE_NEGATIVE]

  printf("%x", v_char_ptr);   // NON_COMPLIANT
  printf("%hx", v_char_ptr);  // NON_COMPLIANT
  printf("%hhx", v_char_ptr); // NON_COMPLIANT
  printf("%lx", v_char_ptr);  // NON_COMPLIANT
  printf("%llx", v_char_ptr); // NON_COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%jx", v_char_ptr); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%zx", v_char_ptr); // NON_COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%tx", v_char_ptr); // NON_COMPLIANT[FALSE_NEGATIVE]

  printf("%X", v_char_ptr);   // NON_COMPLIANT
  printf("%hX", v_char_ptr);  // NON_COMPLIANT
  printf("%hhX", v_char_ptr); // NON_COMPLIANT
  printf("%lX", v_char_ptr);  // NON_COMPLIANT
  printf("%llX", v_char_ptr); // NON_COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%jX", v_char_ptr); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%zX", v_char_ptr); // NON_COMPLIANT
  // FP from WrongTypeFormatArguments.ql
  printf("%tX", v_char_ptr); // NON_COMPLIANT[FALSE_NEGATIVE]

  printf("%f", v_char_ptr);   // NON_COMPLIANT
  printf("%lf", v_char_ptr);  // NON_COMPLIANT
  printf("%llf", v_char_ptr); // NON_COMPLIANT
  printf("%Lf", v_char_ptr);  // NON_COMPLIANT

  printf("%F", v_char_ptr);   // NON_COMPLIANT
  printf("%lF", v_char_ptr);  // NON_COMPLIANT
  printf("%llF", v_char_ptr); // NON_COMPLIANT
  printf("%LF", v_char_ptr);  // NON_COMPLIANT

  printf("%e", v_char_ptr);   // NON_COMPLIANT
  printf("%le", v_char_ptr);  // NON_COMPLIANT
  printf("%lle", v_char_ptr); // NON_COMPLIANT
  printf("%Le", v_char_ptr);  // NON_COMPLIANT

  printf("%E", v_char_ptr);   // NON_COMPLIANT
  printf("%lE", v_char_ptr);  // NON_COMPLIANT
  printf("%llE", v_char_ptr); // NON_COMPLIANT
  printf("%LE", v_char_ptr);  // NON_COMPLIANT

  printf("%g", v_char_ptr);   // NON_COMPLIANT
  printf("%lg", v_char_ptr);  // NON_COMPLIANT
  printf("%llg", v_char_ptr); // NON_COMPLIANT
  printf("%Lg", v_char_ptr);  // NON_COMPLIANT

  printf("%G", v_char_ptr);   // NON_COMPLIANT
  printf("%lG", v_char_ptr);  // NON_COMPLIANT
  printf("%llG", v_char_ptr); // NON_COMPLIANT
  printf("%LG", v_char_ptr);  // NON_COMPLIANT

  printf("%a", v_char_ptr);   // NON_COMPLIANT
  printf("%la", v_char_ptr);  // NON_COMPLIANT
  printf("%lla", v_char_ptr); // NON_COMPLIANT
  printf("%La", v_char_ptr);  // NON_COMPLIANT

  printf("%A", v_char_ptr);   // NON_COMPLIANT
  printf("%lA", v_char_ptr);  // NON_COMPLIANT
  printf("%llA", v_char_ptr); // NON_COMPLIANT
  printf("%LA", v_char_ptr);  // NON_COMPLIANT

  printf("%c", v_char_ptr);  // NON_COMPLIANT
  printf("%lc", v_char_ptr); // NON_COMPLIANT

  printf("%s", v_int);  // NON_COMPLIANT
  printf("%ls", v_int); // NON_COMPLIANT

  printf("%p", v_int); // NON_COMPLIANT

  printf("%n", v_int);   // NON_COMPLIANT
  printf("%hn", v_int);  // NON_COMPLIANT
  printf("%hhn", v_int); // NON_COMPLIANT
  printf("%ln", v_int);  // NON_COMPLIANT
  printf("%lln", v_int); // NON_COMPLIANT
  printf("%jn", v_int);  // NON_COMPLIANT
  printf("%zn", v_int);  // NON_COMPLIANT
  printf("%tn", v_int);  // NON_COMPLIANT

  printf("%C", v_char_ptr); // NON_COMPLIANT

  printf("%S", v_int); // NON_COMPLIANT
}

void test_wrong_arg_number() {
  printf("%d", 42);       // COMPLIANT
  printf("%d, %s\n", 42); // NON_COMPLIANT

  printf("%*d", 2, 42); // COMPLIANT
  printf("%*d", 42);    // NON_COMPLIANT
}
