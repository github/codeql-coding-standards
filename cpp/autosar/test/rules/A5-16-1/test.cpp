
int test_ternary(int x) {

  // COMPLIANT
  int i = (x >= 0 ? x : 0);

  // NON_COMPLIANT
  int j = x + (i == 0 ? (x >= 0 ? x : -x) : i);

  // NON_COMPLIANT
  return (i > 0 ? (j > 0 ? i + j : i) : (j > 0 ? j : 0));

  // NON_COMPLIANT - subexpression of assign expression
  int k;
  k = (x >= 0 ? x : 0);

  struct s {
    int n;
    s &operator=(struct s const &rhs) {
      this->n = rhs.n;
      return *this;
    }
  };
  s s1, s2;
  s s3 = x >= 0 ? s1 : s2; // NON_COMPLIANT - argument to member call
}