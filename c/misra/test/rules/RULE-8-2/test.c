// Note: A subset of these cases are also tested in c/misra/test/rules/RULE-1-5
// via a FunctionTypesNotInPrototypeForm.qlref and .expected file in that
// directory. Changes to these tests may require updating the test code or
// expectations in that directory as well.

void f(int x);    // COMPLIANT
void f0(void);    // COMPLIANT
void f1(int);     // NON_COMPLIANT
void f2();        // NON_COMPLIANT
void f3(x);       // NON_COMPLIANT
void f4(const x); // NON_COMPLIANT[FALSE_NEGATIVE]
int f5(x)         // NON_COMPLIANT
int x;
{ return 1; }