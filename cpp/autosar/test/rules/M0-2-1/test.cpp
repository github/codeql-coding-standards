
struct s1 {
  int m1[10];
};
struct s2 {
  int m1;
  struct s1 m2;
};

union u {
  struct s1 m1;
  struct s2 m2;
};

typedef struct {
  char buf[8];
} Union_t;

typedef union {

  unsigned char uc[24];

  struct {
    Union_t prefix;
    Union_t suffix;
  } fnv;

  struct {
    unsigned char padding[16];
    Union_t suffix;
  } diff;

} UnionSecret_t;

void overlapping_access() {
  u u1;
  u1.m2.m2 = u1.m1; // NON_COMPLIANT, different struct. u1.m2 and u1.m1
}

void cross_copy() {
  UnionSecret_t hash1;
  hash1.diff.suffix =
      hash1.fnv.suffix; // COMPLIANT (copy across structs), but safe.
}

void internal_shift() {
  UnionSecret_t hash1;
  hash1.fnv.prefix = hash1.fnv.suffix; // COMPLIANT, same struct.
}

void separate_access() {
  UnionSecret_t hash1, hash2;
  hash2.diff.suffix = hash1.fnv.suffix; // COMPLIANT, different union.
}