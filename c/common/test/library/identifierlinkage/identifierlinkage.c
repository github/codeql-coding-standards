// Simple external linkage
int g_ext1;
extern int g_ext2;

// Simple internal linkage
static int g_int1;

// Redefined maintaining linkage
int g_ext3;
extern int g_ext3;

static int g_int2;
extern int g_int2;

void f(int p) {
  int l_none1;
  static int l_none2;
  extern int l_ext1;
}

// Structs are not variables
struct s {
  // Struct members are variables with no linkage.
  int m;
};

// Enums and enum constants are not variables and have no linkage.
enum e { E1 };