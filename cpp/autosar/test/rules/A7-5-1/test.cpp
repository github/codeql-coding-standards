int *test_ptr_return(int &x) { // COMPLIANT
  return (&x);
}
const int &test_refconst_return(const int &x) { // NON_COMPLIANT
  return x;
}
const int *test_ptrconst_return(const int &x) { // NON_COMPLIANT
  return (&x);
}
int test_ref_return(int &x) { return x; } // COMPLIANT