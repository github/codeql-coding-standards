// NOTICE: THE TEST CASES BELOW ARE ALSO INCLUDED IN THE C++ TEST CASE AND
// CHANGES SHOULD BE REFLECTED THERE AS WELL.

int test_used(int x) { return x; } // COMPLIANT

void test_unused(int x) {} // NON_COMPLIANT

void test_no_def(int x); // COMPLIANT - no definition, so cannot be "unused"