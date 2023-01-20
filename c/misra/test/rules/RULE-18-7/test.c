struct s {
  int a;
  int b[1]; // COMPLIANT
};

struct s1 {
  int a;
  int b[]; // NON_COMPLIANT
};

struct s2 {
  int a;
  int b[2]; // COMPLIANT
};

struct s3 {
  int a;
  int b[1]; // COMPLIANT
  int a1;
};