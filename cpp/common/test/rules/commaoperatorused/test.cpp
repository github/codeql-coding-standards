
int f() { return 1; }

int g() { return 2; }

// NON_COMPLIANT -  comma operator
int test_comma() { int x = (f(), g()); }
