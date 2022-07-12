struct S1 {
  S1();
  S1(int);
  S1(int, int);
  int m1;
};

typedef S1 *S1PTR;

int operator++(S1, int);
int operator<<(S1, int);

void test_expression_statements() {
  // Creates a temporary variable, through a functional cast,  with type S1 on
  // which the post-fix increment operator is called.
  S1(1)++;
  // Creates a temporary variable with type S1PTR (S1*) whose member m1 is
  // assigned the value 1.
  S1PTR(1)->m1 = 1;
  // Functional cast with multiple values in the expression list that is
  // equivalent to S1 temp(1,2) for some invented temporary variable temp.
  S1(1, 2) << 1;
  int(1);
}

void test_declarations() {
  // Declares a function pointer that accepts an int and returns a S1.
  S1 (*l1)(int);
  // Declares an array l2 of 5 elements of type S1.
  S1(l2)[5];
  // Declares a variable l3 of type S1 that is directly initialized.
  S1(l3) = {1, 2};
}

int g1 = 0;
void f1() {
  S1(g1);  // NON_COMPLIANT
  S1 l1(); // NON_COMPLIANT
  S1 l2;   // COMPLIANT
  S1 l3{}; // COMPLIANT
}