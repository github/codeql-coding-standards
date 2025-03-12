typedef struct {
} empty_struct_t;
struct empty_struct {};
typedef union {
} empty_union_t;
union empty_union {};

void f() {
  _Generic(1,
           int : 1,                   // COMPLIANT
           const int : 1,             // NON-COMPLIANT
           volatile int : 1,          // NON-COMPLIANT
           _Atomic int : 1,           // NON-COMPLIANT
           int * : 1,                 // COMPLIANT
           int const * : 1,           // COMPLIANT
           const volatile int : 1,    // NON-COMPLIANT
           int volatile const * : 1,  // COMPLIANT
           struct {} : 1,             // NON-COMPLIANT
           struct {} * : 1,           // NON-COMPLIANT
           empty_struct_t : 1,        // COMPLIANT
           struct empty_struct : 1,   // COMPLIANT
           empty_struct_t * : 1,      // COMPLIANT
           struct empty_struct * : 1, // COMPLIANT
           union {} : 1,              // NON-COMPLIANT
           union {} * : 1,            // NON-COMPLIANT
           empty_union_t : 1,         // COMPLIANT
           union empty_union : 1,     // COMPLIANT
           empty_union_t * : 1,       // COMPLIANT
           union empty_union * : 1,   // COMPLIANT
           // int[]: 1,              // compile error
           int[3] : 1,    // NON-COMPLIANT
           int(*)[3] : 1, // COMPLIANT: pointer to array OK
           // int (int*): 1,  // compile error
           int (*)(int *) : 1, // COMPLIANT: function pointers OK
           default : 1         // COMPLIANT
  );
}

// NON-COMPLIANT
#define M1(X) _Generic((X), const int : 1, default : 0)
// NON-COMPLIANT
#define M2(X) _Generic(1, X[3] : 1, default : 0)
// COMPLIANT
#define M3(X) _Generic(1, X : 1, default : 0)

void f2() {
  M1(1);
  M2(int);
  M2(char);

  M3(int);       // COMPLIANT
  M3(const int); // NON-COMPLIANT
}

typedef int int_t;
typedef int *int_ptr;
const typedef int const_int;
const typedef int *const_int_ptr;
typedef long const *long_const_ptr;

void f3() {
  _Generic(1,
           int_t : 1,          // COMPLIANT
           const_int : 1,      // NON-COMPLIANT
           const_int_ptr : 1,  // COMPLIANT
           long_const_ptr : 1, // COMPLIANT
           const int_ptr : 1,  // COMPLIANT
           default : 1         // COMPLIANT
  );
}

// Type written here so it gets added to the database, see LvalueConversion.qll.
char *g;