struct s1 {
  int m1;
  const int const_arr[10];
  int arr[10];
};

struct s1 get_s1();

struct s2 {
  struct s1 member_s1;
  struct s1 const const_s1_arr[10];
  struct s1 *s1ptr;
  struct s1 s1_arr[10];
};

struct s2 get_s2();
struct s2 *get_s2_ptr();

void use_int(int x) {}
void use_int_ptr(int *x) {}

void f(void) {
  struct s1 l1;

  // Auto lifetime, allowed:
  l1.const_arr + 1;          // COMPLIANT
  l1.const_arr - 1;          // COMPLIANT
  &l1.const_arr;             // COMPLIANT
  use_int_ptr(l1.const_arr); // COMPLIANT
  l1.arr[0] = 1;             // COMPLIANT

  // Extern lifetime, allowed:
  extern struct s1 g1;
  g1.const_arr + 1;          // COMPLIANT
  g1.const_arr - 1;          // COMPLIANT
  &g1.const_arr;             // COMPLIANT
  use_int_ptr(g1.const_arr); // COMPLIANT
  g1.arr[0] = 1;             // COMPLIANT

  // Temporary lifetime, no conversion:
  get_s1().const_arr; // COMPLIANT - not used as a value.
  get_s1().m1 + 1;    // COMPLIANT - not an array.

  // Temporary lifetime, array to pointer conversions:
  get_s1().const_arr + 1;                  // NON-COMPLIANT
  get_s1().const_arr - 1;                  // NON-COMPLIANT
  1 + get_s1().const_arr;                  // NON-COMPLIANT
  *get_s1().const_arr;                     // NON-COMPLIANT
  !get_s1().const_arr;                     // NON-COMPLIANT
  get_s1().const_arr < 1;                  // NON-COMPLIANT
  get_s1().const_arr <= 1;                 // NON-COMPLIANT
  get_s1().const_arr > 1;                  // NON-COMPLIANT
  get_s1().const_arr >= 1;                 // NON-COMPLIANT
  get_s1().const_arr == 1;                 // NON-COMPLIANT
  1 == get_s1().const_arr;                 // NON-COMPLIANT
  get_s1().const_arr && 1;                 // NON-COMPLIANT
  1 && get_s1().const_arr;                 // NON-COMPLIANT
  get_s1().const_arr || 1;                 // NON-COMPLIANT
  get_s1().const_arr ? 1 : 1;              // NON-COMPLIANT
  use_int_ptr(get_s1().const_arr);         // NON-COMPLIANT
  use_int_ptr((get_s1().const_arr));       // NON-COMPLIANT
  use_int_ptr((void *)get_s1().const_arr); // NON-COMPLIANT
  (1, get_s1().const_arr) + 1;             // NON-COMPLIANT
  int *local = get_s1().const_arr;         // NON-COMPLIANT
  (struct s1){get_s1().const_arr};         // NON-COMPLIANT
  (struct s2){{get_s1().const_arr}};       // NON-COMPLIANT
  struct s1 local2 = {get_s1().const_arr}; // NON-COMPLIANT

  // Results are not 'used' as a value.
  (void *)get_s1().const_arr; // COMPLIANT
  sizeof(get_s1().const_arr); // COMPLIANT
  get_s1().const_arr, 1;      // COMPLIANT
  1, get_s1().const_arr;      // COMPLIANT
  (get_s1().const_arr);       // COMPLIANT

  get_s1().const_arr[0]; // COMPLIANT - subscripted value not modifiable
  get_s1().arr[0];       // COMPLIANT - subscripted value not used as modifiable
  use_int(get_s1().const_arr[0]); // COMPLIANT
  use_int(get_s1().arr[0]);       // COMPLIANT
  get_s1().arr[0] = 1;            // NON-COMPLIANT
  get_s1().arr[0] -= 1;           // NON-COMPLIANT
  get_s1().arr[0]--;              // NON-COMPLIANT
  get_s1().arr[0]++;              // NON-COMPLIANT
  &(get_s1().arr[0]);             // NON-COMPLIANT

  struct s2 l2;

  // Deeper accesses:
  get_s2().member_s1.const_arr + 1;                // NON-COMPLIANT
  get_s2().const_s1_arr[0].const_arr + 1;          // NON-COMPLIANT
  use_int_ptr(get_s2().member_s1.const_arr);       // NON-COMPLIANT
  use_int_ptr(get_s2().const_s1_arr[0].const_arr); // NON-COMPLIANT
  get_s2().member_s1.arr[0] = 1;                   // NON-COMPLIANT
  get_s2().s1_arr[0].arr[0] = 1;                   // NON-COMPLIANT
  get_s2().member_s1.const_arr[0];                 // COMPLIANT
  get_s2().const_s1_arr[0].const_arr[0];           // COMPLIANT
  get_s2().s1_arr[0].const_arr[0];                 // COMPLIANT
  get_s2().s1ptr->const_arr[0];                    // COMPLIANT
  use_int(get_s2().member_s1.const_arr[0]);        // COMPLIANT
  use_int(get_s2().const_s1_arr[0].const_arr[0]);  // COMPLIANT
  use_int(get_s2().s1ptr->const_arr[0]);           // COMPLIANT

  // Pointer members of a struct don't have temporary lifetime.
  get_s2().s1ptr->const_arr + 1;          // COMPLIANT
  use_int_ptr(get_s2().s1ptr->const_arr); // COMPLIANT
  get_s2().s1ptr->arr[0] = 1;             // COMPLIANT
  get_s2_ptr()->member_s1.const_arr + 1;  // COMPLIANT
  get_s2_ptr()->member_s1.arr[0] = 1;     // COMPLIANT

  // Other types of non-lvalue types
  struct {
    int arr[10];
  } l3;
  use_int_ptr((l3 = l3).arr);             // NON-COMPLIANT
  use_int_ptr(((struct s1)l1).const_arr); // NON-COMPLIANT[FALSE_NEGATIVE]
  use_int_ptr((1 ? l1 : l1).const_arr);   // NON-COMPLIANT
  use_int_ptr((0, l1).const_arr);         // NON-COMPLIANT
  use_int_ptr((l2.s1ptr++)->const_arr);   // COMPLIANT
  use_int_ptr((--l2.s1ptr)->const_arr);   // COMPLIANT
}

// Additional modifiable lvalue tests
struct s3 {
  struct s4 {
    struct s5 {
      struct s6 {
        int x;
      } m1;
    } m1;
  } arr_struct[1];

  union u1 {
    int x;
  } arr_union[1];

  int arr2d[1][1];
} get_s3();

void f2(void) {
  get_s3().arr_union[0].x = 1;                   // NON_COMPLIANT
  get_s3().arr_struct[0] = (struct s4){0};       // NON_COMPLIANT
  get_s3().arr_struct[0].m1 = (struct s5){0};    // NON_COMPLIANT
  get_s3().arr_struct[0].m1.m1 = (struct s6){0}; // NON_COMPLIANT
  get_s3().arr_struct[0].m1.m1.x = 1;            // NON_COMPLIANT
  &get_s3().arr_struct[0].m1.m1.x;               // NON_COMPLIANT
  get_s3().arr_struct[0].m1.m1.x + 1;            // COMPLIANT

  get_s3().arr2d[1][1] + 1; // COMPLIANT
  get_s3().arr2d[1][1] = 1; // NON_COMPLIANT
  &get_s3().arr2d[1];       // NON_COMPLIANT
  // The following cases are missing an ArrayToPointerConversion
  use_int_ptr(get_s3().arr2d[1]); // NON_COMPLIANT[FALSE NEGATIVE]
  get_s3().arr2d[1] + 1;          // NON_COMPLIANT[FALSE NEGATIVE]
}