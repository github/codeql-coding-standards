#include <stdio.h>

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
  printf("%'-d", 42);  // COMPLIANT
  printf("%'-#d", 42); // NON_COMPLIANT

  printf("%'d", 42); // COMPLIANT
  printf("%-d", 42); // COMPLIANT
  printf("%+d", 42); // COMPLIANT
  printf("% d", 42); // COMPLIANT
  printf("%#d", 42); // NON_COMPLIANT
  printf("%0d", 42); // COMPLIANT

  printf("%'i", 42); // COMPLIANT
  printf("%-i", 42); // COMPLIANT
  printf("%+i", 42); // COMPLIANT
  printf("% i", 42); // COMPLIANT
  printf("%#i", 42); // NON_COMPLIANT
  printf("%0i", 42); // COMPLIANT

  printf("%'o", 42); // NON_COMPLIANT
  printf("%-o", 42); // COMPLIANT
  printf("%+o", 42); // COMPLIANT
  printf("% o", 42); // COMPLIANT
  printf("%#o", 42); // COMPLIANT
  printf("%0o", 42); // COMPLIANT

  printf("%'u", 42); // COMPLIANT
  printf("%-u", 42); // COMPLIANT
  printf("%+u", 42); // COMPLIANT
  printf("% u", 42); // COMPLIANT
  printf("%#u", 42); // NON_COMPLIANT
  printf("%0u", 42); // COMPLIANT

  printf("%'x", 42); // NON_COMPLIANT
  printf("%-x", 42); // COMPLIANT
  printf("%+x", 42); // COMPLIANT
  printf("% x", 42); // COMPLIANT
  printf("%#x", 42); // COMPLIANT
  printf("%0x", 42); // COMPLIANT

  printf("%'X", 42); // NON_COMPLIANT
  printf("%-X", 42); // COMPLIANT
  printf("%+X", 42); // COMPLIANT
  printf("% X", 42); // COMPLIANT
  printf("%#X", 42); // COMPLIANT
  printf("%0X", 42); // COMPLIANT

  printf("%'f", 42); // COMPLIANT
  printf("%-f", 42); // COMPLIANT
  printf("%+f", 42); // COMPLIANT
  printf("% f", 42); // COMPLIANT
  printf("%#f", 42); // COMPLIANT
  printf("%0f", 42); // COMPLIANT

  printf("%'F", 42); // COMPLIANT
  printf("%-F", 42); // COMPLIANT
  printf("%+F", 42); // COMPLIANT
  printf("% F", 42); // COMPLIANT
  printf("%#F", 42); // COMPLIANT
  printf("%0F", 42); // COMPLIANT

  printf("%'e", 42); // NON_COMPLIANT
  printf("%-e", 42); // COMPLIANT
  printf("%+e", 42); // COMPLIANT
  printf("% e", 42); // COMPLIANT
  printf("%#e", 42); // COMPLIANT
  printf("%0e", 42); // COMPLIANT

  printf("%'E", 42); // NON_COMPLIANT
  printf("%-E", 42); // COMPLIANT
  printf("%+E", 42); // COMPLIANT
  printf("% E", 42); // COMPLIANT
  printf("%#E", 42); // COMPLIANT
  printf("%0E", 42); // COMPLIANT

  printf("%'g", 42); // COMPLIANT
  printf("%-g", 42); // COMPLIANT
  printf("%+g", 42); // COMPLIANT
  printf("% g", 42); // COMPLIANT
  printf("%#g", 42); // COMPLIANT
  printf("%0g", 42); // COMPLIANT

  printf("%'G", 42); // COMPLIANT
  printf("%-G", 42); // COMPLIANT
  printf("%+G", 42); // COMPLIANT
  printf("% G", 42); // COMPLIANT
  printf("%#G", 42); // COMPLIANT
  printf("%0G", 42); // COMPLIANT

  printf("%'a", 42); // COMPLIANT
  printf("%-a", 42); // COMPLIANT
  printf("%+a", 42); // COMPLIANT
  printf("% a", 42); // COMPLIANT
  printf("%#a", 42); // COMPLIANT
  printf("%0a", 42); // COMPLIANT

  printf("%'A", 42); // COMPLIANT
  printf("%-A", 42); // COMPLIANT
  printf("%+A", 42); // COMPLIANT
  printf("% A", 42); // COMPLIANT
  printf("%#A", 42); // COMPLIANT
  printf("%0A", 42); // COMPLIANT

  printf("%'c", 42); // NON_COMPLIANT
  printf("%-c", 42); // COMPLIANT
  printf("%+c", 42); // COMPLIANT
  printf("% c", 42); // COMPLIANT
  printf("%#c", 42); // NON_COMPLIANT
  printf("%0c", 42); // NON_COMPLIANT

  printf("%'s", 42); // NON_COMPLIANT
  printf("%-s", 42); // COMPLIANT
  printf("%+s", 42); // COMPLIANT
  printf("% s", 42); // COMPLIANT
  printf("%#s", 42); // NON_COMPLIANT
  printf("%0s", 42); // NON_COMPLIANT

  printf("%'p", 42); // NON_COMPLIANT
  printf("%-p", 42); // COMPLIANT
  printf("%+p", 42); // COMPLIANT
  printf("% p", 42); // COMPLIANT
  printf("%#p", 42); // NON_COMPLIANT
  printf("%0p", 42); // NON_COMPLIANT

  printf("%'n", 42); // NON_COMPLIANT
  printf("%-n", 42); // COMPLIANT
  printf("%+n", 42); // COMPLIANT
  printf("% n", 42); // COMPLIANT
  printf("%#n", 42); // NON_COMPLIANT
  printf("%0n", 42); // NON_COMPLIANT

  printf("%'C", 42); // NON_COMPLIANT
  printf("%-C", 42); // COMPLIANT
  printf("%+C", 42); // COMPLIANT
  printf("% C", 42); // COMPLIANT
  printf("%#C", 42); // NON_COMPLIANT
  printf("%0C", 42); // NON_COMPLIANT

  printf("%'S", 42); // NON_COMPLIANT
  printf("%-S", 42); // COMPLIANT
  printf("%+S", 42); // COMPLIANT
  printf("% S", 42); // COMPLIANT
  printf("%#S", 42); // NON_COMPLIANT
  printf("%0S", 42); // NON_COMPLIANT

  printf("%%", 42);  // COMPLIANT
  printf("%'%", 42); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%-%", 42); // COMPLIANT
  printf("%+%", 42); // COMPLIANT
  printf("% %", 42); // COMPLIANT
  printf("%#%", 42); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%0%", 42); // NON_COMPLIANT[FALSE_NEGATIVE]
}
void test_incompatible_length() {
  printf("%hd", 42);  // COMPLIANT
  printf("%hhd", 42); // COMPLIANT
  printf("%ld", 42);  // COMPLIANT
  printf("%lld", 42); // COMPLIANT
  printf("%jd", 42);  // COMPLIANT
  printf("%zd", 42);  // COMPLIANT
  printf("%td", 42);  // COMPLIANT
  printf("%Ld", 42);  // NON_COMPLIANT

  printf("%hi", 42);  // COMPLIANT
  printf("%hhi", 42); // COMPLIANT
  printf("%li", 42);  // COMPLIANT
  printf("%lli", 42); // COMPLIANT
  printf("%ji", 42);  // COMPLIANT
  printf("%zi", 42);  // COMPLIANT
  printf("%ti", 42);  // COMPLIANT
  printf("%Li", 42);  // NON_COMPLIANT

  printf("%ho", 42);  // COMPLIANT
  printf("%hho", 42); // COMPLIANT
  printf("%lo", 42);  // COMPLIANT
  printf("%llo", 42); // COMPLIANT
  printf("%jo", 42);  // COMPLIANT
  printf("%zo", 42);  // COMPLIANT
  printf("%to", 42);  // COMPLIANT
  printf("%Lo", 42);  // NON_COMPLIANT

  printf("%hu", 42);  // COMPLIANT
  printf("%hhu", 42); // COMPLIANT
  printf("%lu", 42);  // COMPLIANT
  printf("%llu", 42); // COMPLIANT
  printf("%ju", 42);  // COMPLIANT
  printf("%zu", 42);  // COMPLIANT
  printf("%tu", 42);  // COMPLIANT
  printf("%Lu", 42);  // NON_COMPLIANT

  printf("%hx", 42);  // NON_COMPLIANT
  printf("%hhx", 42); // NON_COMPLIANT
  printf("%lx", 42);  // COMPLIANT
  printf("%llx", 42); // COMPLIANT
  printf("%jx", 42);  // NON_COMPLIANT
  printf("%zx", 42);  // NON_COMPLIANT
  printf("%tx", 42);  // NON_COMPLIANT
  printf("%Lx", 42);  // NON_COMPLIANT

  printf("%hX", 42);  // NON_COMPLIANT
  printf("%hhX", 42); // NON_COMPLIANT
  printf("%lX", 42);  // COMPLIANT
  printf("%llX", 42); // COMPLIANT
  printf("%jX", 42);  // NON_COMPLIANT
  printf("%zX", 42);  // NON_COMPLIANT
  printf("%tX", 42);  // NON_COMPLIANT
  printf("%LX", 42);  // NON_COMPLIANT

  printf("%hf", 42);  // NON_COMPLIANT
  printf("%hhf", 42); // NON_COMPLIANT
  printf("%lf", 42);  // COMPLIANT
  printf("%llf", 42); // COMPLIANT
  printf("%jf", 42);  // NON_COMPLIANT
  printf("%zf", 42);  // NON_COMPLIANT
  printf("%tf", 42);  // NON_COMPLIANT
  printf("%Lf", 42);  // COMPLIANT

  printf("%hF", 42);  // NON_COMPLIANT
  printf("%hhF", 42); // NON_COMPLIANT
  printf("%lF", 42);  // COMPLIANT
  printf("%llF", 42); // COMPLIANT
  printf("%jF", 42);  // NON_COMPLIANT
  printf("%zF", 42);  // NON_COMPLIANT
  printf("%tF", 42);  // NON_COMPLIANT
  printf("%LF", 42);  // COMPLIANT

  printf("%he", 42);  // NON_COMPLIANT
  printf("%hhe", 42); // NON_COMPLIANT
  printf("%le", 42);  // COMPLIANT
  printf("%lle", 42); // COMPLIANT
  printf("%je", 42);  // NON_COMPLIANT
  printf("%ze", 42);  // NON_COMPLIANT
  printf("%te", 42);  // NON_COMPLIANT
  printf("%Le", 42);  // COMPLIANT

  printf("%hE", 42);  // NON_COMPLIANT
  printf("%hhE", 42); // NON_COMPLIANT
  printf("%lE", 42);  // COMPLIANT
  printf("%llE", 42); // COMPLIANT
  printf("%jE", 42);  // NON_COMPLIANT
  printf("%zE", 42);  // NON_COMPLIANT
  printf("%tE", 42);  // NON_COMPLIANT
  printf("%LE", 42);  // COMPLIANT

  printf("%hg", 42);  // NON_COMPLIANT
  printf("%hhg", 42); // NON_COMPLIANT
  printf("%lg", 42);  // COMPLIANT
  printf("%llg", 42); // COMPLIANT
  printf("%jg", 42);  // NON_COMPLIANT
  printf("%zg", 42);  // NON_COMPLIANT
  printf("%tg", 42);  // NON_COMPLIANT
  printf("%Lg", 42);  // COMPLIANT

  printf("%hG", 42);  // NON_COMPLIANT
  printf("%hhG", 42); // NON_COMPLIANT
  printf("%lG", 42);  // COMPLIANT
  printf("%llG", 42); // COMPLIANT
  printf("%jG", 42);  // NON_COMPLIANT
  printf("%zG", 42);  // NON_COMPLIANT
  printf("%tG", 42);  // NON_COMPLIANT
  printf("%LG", 42);  // COMPLIANT

  printf("%ha", 42);  // NON_COMPLIANT
  printf("%hha", 42); // NON_COMPLIANT
  printf("%la", 42);  // COMPLIANT
  printf("%lla", 42); // COMPLIANT
  printf("%ja", 42);  // NON_COMPLIANT
  printf("%za", 42);  // NON_COMPLIANT
  printf("%ta", 42);  // NON_COMPLIANT
  printf("%La", 42);  // COMPLIANT

  printf("%hA", 42);  // NON_COMPLIANT
  printf("%hhA", 42); // NON_COMPLIANT
  printf("%lA", 42);  // COMPLIANT
  printf("%llA", 42); // COMPLIANT
  printf("%jA", 42);  // NON_COMPLIANT
  printf("%zA", 42);  // NON_COMPLIANT
  printf("%tA", 42);  // NON_COMPLIANT
  printf("%LA", 42);  // COMPLIANT

  printf("%hc", 42);  // NON_COMPLIANT
  printf("%hhc", 42); // NON_COMPLIANT
  printf("%lc", 42);  // COMPLIANT
  printf("%llc", 42); // NON_COMPLIANT
  printf("%jc", 42);  // NON_COMPLIANT
  printf("%zc", 42);  // NON_COMPLIANT
  printf("%tc", 42);  // NON_COMPLIANT
  printf("%Lc", 42);  // NON_COMPLIANT

  printf("%hs", 42);  // NON_COMPLIANT
  printf("%hhs", 42); // NON_COMPLIANT
  printf("%ls", 42);  // COMPLIANT
  printf("%lls", 42); // NON_COMPLIANT
  printf("%js", 42);  // NON_COMPLIANT
  printf("%zs", 42);  // NON_COMPLIANT
  printf("%ts", 42);  // NON_COMPLIANT
  printf("%Ls", 42);  // NON_COMPLIANT

  printf("%hp", 42);  // NON_COMPLIANT
  printf("%hhp", 42); // NON_COMPLIANT
  printf("%lp", 42);  // NON_COMPLIANT
  printf("%llp", 42); // NON_COMPLIANT
  printf("%jp", 42);  // NON_COMPLIANT
  printf("%zp", 42);  // NON_COMPLIANT
  printf("%tp", 42);  // NON_COMPLIANT
  printf("%Lp", 42);  // NON_COMPLIANT

  printf("%hn", 42);  // COMPLIANT
  printf("%hhn", 42); // COMPLIANT
  printf("%ln", 42);  // COMPLIANT
  printf("%lln", 42); // COMPLIANT
  printf("%jn", 42);  // COMPLIANT
  printf("%zn", 42);  // COMPLIANT
  printf("%tn", 42);  // COMPLIANT
  printf("%Ln", 42);  // NON_COMPLIANT

  printf("%hC", 42);  // NON_COMPLIANT
  printf("%hhC", 42); // NON_COMPLIANT
  printf("%lC", 42);  // NON_COMPLIANT
  printf("%llC", 42); // NON_COMPLIANT
  printf("%jC", 42);  // NON_COMPLIANT
  printf("%zC", 42);  // NON_COMPLIANT
  printf("%tC", 42);  // NON_COMPLIANT
  printf("%LC", 42);  // NON_COMPLIANT

  printf("%hS", 42);  // NON_COMPLIANT
  printf("%hhS", 42); // NON_COMPLIANT
  printf("%lS", 42);  // NON_COMPLIANT
  printf("%llS", 42); // NON_COMPLIANT
  printf("%jS", 42);  // NON_COMPLIANT
  printf("%zS", 42);  // NON_COMPLIANT
  printf("%tS", 42);  // NON_COMPLIANT
  printf("%LS", 42);  // NON_COMPLIANT

  printf("%h%", 42);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%hh%", 42); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%l%", 42);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%ll%", 42); // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%j%", 42);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%z%", 42);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%t%", 42);  // NON_COMPLIANT[FALSE_NEGATIVE]
  printf("%L%", 42);  // NON_COMPLIANT[FALSE_NEGATIVE]
}
void test_wrong_width_type() {
  printf("%*d", 2, 42);   // COMPLIANT
  printf("%*d", "2", 42); // NON_COMPLIANT
}
void test_wrong_precision_type() {
  printf("%.*d", 2, 42);   // COMPLIANT
  printf("%.*d", "2", 42); // NON_COMPLIANT
}
void test_incompatible_conversion() {
  printf(""); // COMPLIANT
  printf(""); // NON_COMPLIANT
}
void test_wrong_arg_type() {
  printf("%d", 42); // COMPLIANT
  printf("%s", 42); // NON_COMPLIANT
}
void test_wrong_arg_number() {
  printf("%d", 42);       // COMPLIANT
  printf("%d, %s\n", 42); // NON_COMPLIANT

  printf("%*d", 2, 42); // COMPLIANT
  printf("%*d", 42);    // NON_COMPLIANT
}
