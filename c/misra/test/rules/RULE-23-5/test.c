void f1();

void f2() {
  int l1;
  int *l2;
  const int *l3;
  volatile int *l4;
  volatile const int *l5;
  void *l6;
  const void *l7;
  volatile void *l8;
  const volatile void *l9;

  // No violation for missing pointer/integral conversions:
  _Generic(l1, // COMPLIANT
      int *: f1,
      const int *: f1,
      volatile int *: f1,
      void *: f1,
      const void *: f1,
      default: f1);                   // COMPLIANT
  _Generic(l2, int : f1, default : f1); // COMPLIANT
  _Generic(l3, int : f1, default : f1); // COMPLIANT
  _Generic(l4, int : f1, default : f1); // COMPLIANT
  _Generic(l5, int : f1, default : f1); // COMPLIANT

  // Compliant, default case is not matched
  _Generic(l1, int : f1);                   // COMPLIANT
  _Generic(l2, int * : f1);                 // COMPLIANT
  _Generic(l3, const int * : f1);           // COMPLIANT
  _Generic(l4, volatile int * : f1);        // COMPLIANT
  _Generic(l5, volatile const int * : f1);  // COMPLIANT
  _Generic(l6, void * : f1);                // COMPLIANT
  _Generic(l7, const void * : f1);          // COMPLIANT
  _Generic(l8, volatile void * : f1);       // COMPLIANT
  _Generic(l9, const volatile void * : f1); // COMPLIANT

  // Violation, match default case due to lack of pointer to pointer
  // conversions:
  _Generic(l2, int * : f1, default : f1);                 // COMPLIANT
  _Generic(l2, const int * : f1, default : f1);           // NON-COMPLIANT
  _Generic(l2, volatile int * : f1, default : f1);        // NON-COMPLIANT
  _Generic(l2, const volatile int * : f1, default : f1);  // NON-COMPLIANT
  _Generic(l2, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l2, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l2, const volatile void * : f1, default : f1); // NON-COMPLIANT

  _Generic(l3, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l3, const int * : f1, default : f1);           // COMPLIANT
  _Generic(l3, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l3, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l3, const volatile void * : f1, default : f1); // NON-COMPLIANT
  // Obviously not volatile:
  _Generic(l3, volatile int * : f1, default : f1); // COMPLIANT
  // Debatable, but volatile const int* is assignable to const int* so its
  // considered risky
  _Generic(l3, const volatile int * : f1, default : f1); // NON-COMPLIANT

  _Generic(l4, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l4, volatile int * : f1, default : f1);        // COMPLIANT
  _Generic(l4, const volatile int * : f1, default : f1);  // NON-COMPLIANT
  _Generic(l4, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l4, const volatile void * : f1, default : f1); // NON-COMPLIANT
  // Debatable, but volatile int* isn't assignable to const int* or vice versa.
  _Generic(l4, const int * : f1, default : f1); // COMPLIANT
  // Debatable, but volatile int* isn't assignable to const void* or vice versa.
  _Generic(l4, const void * : f1, default : f1); // COMPLIANT

  _Generic(l5, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l5, const int * : f1, default : f1);           // NON-COMPLIANT
  _Generic(l5, volatile int * : f1, default : f1);        // NON-COMPLIANT
  _Generic(l5, const volatile int * : f1, default : f1);  // COMPLIANT
  _Generic(l5, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l5, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l5, const volatile void * : f1, default : f1); // NON-COMPLIANT

  _Generic(l6, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l6, const int * : f1, default : f1);           // NON-COMPLIANT
  _Generic(l6, volatile int * : f1, default : f1);        // NON-COMPLIANT
  _Generic(l6, const volatile int * : f1, default : f1);  // NON-COMPLIANT
  _Generic(l6, void * : f1, default : f1);                // COMPLIANT
  _Generic(l6, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l6, const volatile void * : f1, default : f1); // NON-COMPLIANT

  _Generic(l7, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l7, const int * : f1, default : f1);           // NON-COMPLIANT
  _Generic(l7, const volatile int * : f1, default : f1);  // NON-COMPLIANT
  _Generic(l7, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l7, const void * : f1, default : f1);          // COMPLIANT
  _Generic(l7, const volatile void * : f1, default : f1); // NON-COMPLIANT
  // Debatable, but const void* isn't assignable to volatile int* or vice versa.
  _Generic(l7, volatile int * : f1, default : f1); // COMPLIANT

  _Generic(l9, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l9, const int * : f1, default : f1);           // NON-COMPLIANT
  _Generic(l9, volatile int * : f1, default : f1);        // NON-COMPLIANT
  _Generic(l9, const volatile int * : f1, default : f1);  // NON-COMPLIANT
  _Generic(l9, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l9, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l9, const volatile void * : f1, default : f1); // COMPLIANT

  /**
   * Edge case 1: The controlling expression undergoes lvalue conversion, so
   * arrays become pointers and qualifiers on pointers are stripped.
   */
  int l10[3];
  const int l11[3];
  volatile int l12[3];
  const volatile int l13[3];
  int *const l14;
  const int *const l15;

  _Generic(l10, int * : f1, default : f1);                // COMPLIANT
  _Generic(l11, const int * : f1, default : f1);          // COMPLIANT
  _Generic(l12, volatile int * : f1, default : f1);       // COMPLIANT
  _Generic(l13, const volatile int * : f1, default : f1); // COMPLIANT

  _Generic(l10, int * : f1, default : f1);                 // COMPLIANT
  _Generic(l10, const int * : f1, default : f1);           // NON-COMPLIANT
  _Generic(l10, volatile int * : f1, default : f1);        // NON-COMPLIANT
  _Generic(l10, const volatile int * : f1, default : f1);  // NON-COMPLIANT
  _Generic(l10, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l10, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l10, const volatile void * : f1, default : f1); // NON-COMPLIANT

  _Generic(l11, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l11, const int * : f1, default : f1);           // COMPLIANT
  _Generic(l11, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l11, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l11, const volatile void * : f1, default : f1); // NON-COMPLIANT
  // Obviously not volatile:
  _Generic(l11, volatile int * : f1, default : f1); // COMPLIANT
  // Debatable, but volatile const int* is assignable to const int* so its
  // considered risky
  _Generic(l11, const volatile int * : f1, default : f1); // NON-COMPLIANT

  _Generic(l12, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l12, volatile int * : f1, default : f1);        // COMPLIANT
  _Generic(l12, const volatile int * : f1, default : f1);  // NON-COMPLIANT
  _Generic(l12, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l12, const volatile void * : f1, default : f1); // NON-COMPLIANT
  // Debatab12e, but volatile int* isn't assignable to const int* or vice versa.
  _Generic(l12, const int * : f1, default : f1); // COMPLIANT
  // Debatable, but volatile int* isn't assignable to const void* or vice versa.
  _Generic(l12, const void * : f1, default : f1); // COMPLIANT

  _Generic(l13, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l13, const int * : f1, default : f1);           // NON-COMPLIANT
  _Generic(l13, volatile int * : f1, default : f1);        // NON-COMPLIANT
  _Generic(l13, const volatile int * : f1, default : f1);  // COMPLIANT
  _Generic(l13, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l13, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l13, const volatile void * : f1, default : f1); // NON-COMPLIANT

  _Generic(l14, int * : f1, default : f1);                 // COMPLIANT
  _Generic(l14, const int * : f1, default : f1);           // NON-COMPLIANT
  _Generic(l14, volatile int * : f1, default : f1);        // NON-COMPLIANT
  _Generic(l14, const volatile int * : f1, default : f1);  // NON-COMPLIANT
  _Generic(l14, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l14, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l14, const volatile void * : f1, default : f1); // NON-COMPLIANT

  _Generic(l15, int * : f1, default : f1);                 // NON-COMPLIANT
  _Generic(l15, const int * : f1, default : f1);           // COMPLIANT
  _Generic(l15, void * : f1, default : f1);                // NON-COMPLIANT
  _Generic(l15, const void * : f1, default : f1);          // NON-COMPLIANT
  _Generic(l15, const volatile void * : f1, default : f1); // NON-COMPLIANT
  // Obviously not volatile:
  _Generic(l15, volatile int * : f1, default : f1); // COMPLIANT
  // Debatable, but volatile const int* is assignable to const int* so its
  // considered risky
  _Generic(l15, const volatile int * : f1, default : f1); // NON-COMPLIANT

  /**
   * Edge case 2: Types don't have to be identical to be compatible.
   */
  int(*l16)[3];

  // This is a risky conversion that should be reported:
  _Generic(l16, int(*const)[3] : f1, default : f1); // NON-COMPLIANT
  // However, in this one, there is a match on the second selector, because it
  // it is an array type with a compatible element type, and sizes only have to
  // match if both arrays have a constant size. Therefore, the default selector
  // is not chosen and this is not a violation.
  _Generic(l16, int(*const)[3] : f1, int(*)[] : f1, default : f1); // COMPLIANT
  // In this case, the second selector is not a compatible type because the
  // array has a constant size that doesn't match, and this should be reported.
  _Generic(l16, int(*const)[3]
           : f1, int(*)[4]
           : f1,
             default
           : f1); // NON-COMPLIANT

  /**
   * Edge case 3: Conversion on _Generic, make sure we use the fully converted
   * type when considering compliance.
   */
  int *l17;
  void *l18;
  _Generic((void *)l17, void * : f1, default : f1); // COMPLIANT
  _Generic((void *)l17, int * : f1, default : f1);  // NON-COMPLIANT
  _Generic((int *)l18, void * : f1, default : f1);  // NON-COMPLIANT
  _Generic((int *)l18, int * : f1, default : f1);   // COMPLIANT

  /**
   * Edge case 4: Typedefs must be resolved properly.
   */
  typedef int int_t;
  const typedef int c_int_t;
  int_t *l19;
  c_int_t *l20;
  volatile c_int_t *l21;

  _Generic(l2, int * : f1, default : f1);         // COMPLIANT
  _Generic(l2, int_t * : f1, default : f1);       // COMPLIANT
  _Generic(l2, const int * : f1, default : f1);   // NON-COMPLIANT
  _Generic(l2, const int_t * : f1, default : f1); // NON-COMPLIANT
  _Generic(l2, c_int_t * : f1, default : f1);     // NON-COMPLIANT

  _Generic(l19, int * : f1, default : f1);         // COMPLIANT
  _Generic(l19, int_t * : f1, default : f1);       // COMPLIANT
  _Generic(l19, const int * : f1, default : f1);   // NON-COMPLIANT
  _Generic(l19, const int_t * : f1, default : f1); // NON-COMPLIANT
  _Generic(l19, c_int_t * : f1, default : f1);     // NON-COMPLIANT

  _Generic(l3, int * : f1, default : f1);         // NON-COMPLIANT
  _Generic(l3, int_t * : f1, default : f1);       // NON-COMPLIANT
  _Generic(l3, const int * : f1, default : f1);   // COMPLIANT
  _Generic(l3, const int_t * : f1, default : f1); // COMPLIANT
  _Generic(l3, c_int_t * : f1, default : f1);     // COMPLIANT

  _Generic(l20, int * : f1, default : f1);         // NON-COMPLIANT
  _Generic(l20, int_t * : f1, default : f1);       // NON-COMPLIANT
  _Generic(l20, const int * : f1, default : f1);   // COMPLIANT
  _Generic(l20, const int_t * : f1, default : f1); // COMPLIANT
  _Generic(l20, c_int_t * : f1, default : f1);     // COMPLIANT
}