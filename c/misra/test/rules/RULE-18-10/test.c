#define CONSTANT 1

int g1[3];           // COMPLIANT
int (*g2)[3];        // COMPLIANT
int (*g3)[CONSTANT]; // COMPLIANT

void f1(
    int p0,

    // Basic fixed length array types:
    int p1[3],           // COMPLIANT
    int (*p2)[3],        // COMPLIANT
    int (*p3)[2][3],     // COMPLIANT
    int (*p4)[CONSTANT], // COMPLIANT

    // Basic pointers to VMTs:
    int (*p5)[p0],     // NON-COMPLIANT
    int (*p6)[2][p0],  // NON-COMPLIANT
    int (*p7)[p0][2],  // NON-COMPLIANT
    int (*p8)[p0][p0], // NON-COMPLIANT

    // Types referring to pointers to VMTs:
    // - pointer to pointer to VMT
    int(*(*p9)[p0]),   // NON-COMPLIANT
    int(*(**p10)[p0]), // NON-COMPLIANT

    // - array of pointers to VMT
    int (*(p11[3]))[p0], // NON-COMPLIANT

    // - const VMTs, const array-to-pointer adjustment
    const int p12[p0],    // COMPLIANT
    const int (*p13)[p0], // NON-COMPLIANT
    int (*const p14)[p0], // NON-COMPLIANT

    // - function types with argument that is a pointer to a VMT
    int p15(int (*inner)[p0]),    // NON-COMPLIANT[FALSE_NEGATIVE]
    int (*p16)(int (*inner)[p0]), // NON-COMPLIANT[FALSE_NEGATIVE]

    // - function types that returns a pointer to a VMT
    int (*(p17(void)))[p0],    // NON-COMPLIANT
    int (*((*p18)(void)))[p0], // NON-COMPLIANT

    // - structs cannot contain a VMT as a member.
    struct {
      int g1[3];          // COMPLIANT
      int(*g2)[3];        // COMPLIANT
      int(*g3)[CONSTANT]; // COMPLIANT
                          // Pointer to VMT (`int (*g4)[p0]`) is not allowed.
    } p19,

    // - unions cannot contain a VMT as a member.
    union {
      int g1[3];          // COMPLIANT
      int(*g2)[3];        // COMPLIANT
      int(*g3)[CONSTANT]; // COMPLIANT
                          // Pointer to VMT (`int (*g4)[p0]`) is not allowed.
    } p20,

    // Unknown array length types:
    int p21[],    // COMPLIANT
    int p22[][2], // COMPLIANT
    int (*p23)[], // COMPLIANT
    // int (*p24)[2][], // doesn't compile
    int (*p25)[][2], // COMPLIANT

    // VLA types that are rewritten as pointers:
    int p26[p0],    // COMPLIANT
    int p27[p0][p0] // NON-COMPLIANT
) {
  // Local variables may contain pointers to VMTs:
  int l0[p0];   // COMPLIANT
  int(*l1)[];   // COMPLIANT
  int(*l2)[3];  // COMPLIANT
  int(*l3)[p0]; // NON-COMPLIANT

  int l6[10];

  // A pointer to a VMT may be declared `static`.
  static int(*l4)[p0]; // NON-COMPLIANT

  // Block scope typedefs may refer to VMTs
  typedef int(*td1)[3];  // COMPLIANT
  typedef int(*td2)[];   // COMPLIANT
  typedef int(*td3)[p0]; // NON-COMPLIANT

  td3 l5; // NON-COMPLIANT
}

// Function prototypes may contain VMTs using '*' syntax:
void f2(int (*p1)[3],    // COMPLIANT
        int (*p2)[*],    // NON-COMPLIANT[FALSE_NEGATIVE]
        int (*p3)[2][*], // NON-COMPLIANT[FALSE_NEGATIVE]
        int (*p4)[*][2], // NON-COMPLIANT[FALSE_NEGATIVE]
        int (*p5)[*][*]  // NON-COMPLIANT[FALSE_NEGATIVE]
);

#define CONFUSING_MACRO()                                                      \
  int x;                                                                       \
  int(*vla)[x];                                                                \
  int(*not_vla)[];

void f3() {
  // We cannot report `vla` in this macro without a false positive for
  // `not_vla`.
  CONFUSING_MACRO() // COMPLIANT
}