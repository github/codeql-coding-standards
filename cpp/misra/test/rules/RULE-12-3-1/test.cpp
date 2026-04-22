struct union_with_tag {
  enum class TYPE { integer, floating };

  union u { // NON_COMPLIANT: unions, whether tagged or not, are not permitted
    int i;
    float f;
  };

  TYPE tag;
};

struct union_sans_tag {
  union u { // NON_COMPLIANT
    int i;
    float f;
  };
  int x;
};

union u { // NON_COMPLIANT
  int i;
  float f;
};

void test_unions() {
  union_with_tag u1;
  union_sans_tag u2;
  u u3;
}
