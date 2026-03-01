// Test file for MISRA Rule 8-0-1: Parentheses should be used to make the
// meaning of an expression appropriately explicit

void f1() {
  int l1 = 1, l2 = 2, l3 = 3, l4 = 4;
  bool l5 = true, l6 = false;

  int l7;
  bool l8;

  // NON_COMPLIANT: Missing parentheses in expressions with operators of
  // different precedence
  l7 = l1 + l2 * l3;      // NON_COMPLIANT
  l7 = l1 * l2 + l3 * l4; // NON_COMPLIANT
  l7 = l1 << l2 + l3;     // NON_COMPLIANT
  l7 = l1 & l2 | l3;      // NON_COMPLIANT
  l7 = l1 | l2 & l3;      // NON_COMPLIANT
  l8 = l5 && l6 || l5;    // NON_COMPLIANT

  // NON_COMPLIANT: Assignment with complex right-hand side
  l7 = l1 + l2 << l3; // NON_COMPLIANT

  // NON_COMPLIANT: Conditional expressions without parentheses
  l8 = l1 < l2 && l3 > l4; // NON_COMPLIANT

  // NON_COMPLIANT: Bit operations mixed with arithmetic
  l7 = l1 & l2 + l3; // NON_COMPLIANT
  l7 = l1 ^ l2 + l3; // NON_COMPLIANT

  // NON_COMPLIANT: Nested operations of different precedence
  l7 = l1 + l2 * l3 + l4; // NON_COMPLIANT

  // COMPLIANT: Same operators, no precedence confusion
  l7 = l1 + l2 + l3; // COMPLIANT: all same precedence
  l7 = l1 * l2 * l3; // COMPLIANT: all same precedence

  // COMPLIANT: Different operators but with explicit parentheses
  l7 = l1 + (l2 * l3);        // COMPLIANT: parentheses clarify precedence
  l7 = (l1 * l2) + (l3 * l4); // COMPLIANT: parentheses clarify precedence
  l7 = l1 << (l2 + l3);       // COMPLIANT: parentheses clarify precedence
  l7 = (l1 & l2) | l3;        // COMPLIANT: parentheses clarify precedence
  l7 = l1 | (l2 & l3);        // COMPLIANT: parentheses clarify precedence
  l8 = (l5 && l6) || l5;      // COMPLIANT: parentheses clarify precedence

  l7 = (l1 + l2) << l3;        // COMPLIANT: parentheses clarify precedence
  l8 = (l1 < l2) && (l3 > l4); // COMPLIANT: parentheses clarify precedence

  // COMPLIANT: Bit operations with parentheses
  l7 = l1 & (l2 + l3); // COMPLIANT: parentheses clarify precedence
  l7 = l1 ^ (l2 + l3); // COMPLIANT: parentheses clarify precedence

  // COMPLIANT: Nested operations with parentheses
  l7 = l1 + (l2 * l3) + l4; // COMPLIANT: parentheses clarify precedence

  // NON_COMPLIANT: Multiple levels of precedence without clarification
  l7 = l1 + l2 * l3 << l4; // NON_COMPLIANT

  // NON_COMPLIANT: Mixed logical and comparison operators
  l8 = l1 > l2 && l3 < l4 || l1 == l2; // NON_COMPLIANT

  // COMPLIANT: Multiple levels with proper parentheses
  l7 = l1 + ((l2 * l3) << l4); // COMPLIANT: fully parenthesized

  // COMPLIANT: Mixed logical and comparison with parentheses
  l8 = ((l1 > l2) && (l3 < l4)) || (l1 == l2); // COMPLIANT: fully parenthesized
}

// Test conditional expressions
void f2() {
  int l1 = 1, l2 = 2, l3 = 3;
  bool l4 = true;

  // NON_COMPLIANT: Conditional expression without clarifying parentheses
  int l5 = l4 ? l1 + l2 * l3 : l1; // NON_COMPLIANT

  // COMPLIANT: Conditional expression with clarifying parentheses
  l5 = l4 ? (l2 * l3) : l1; // COMPLIANT: multiplication is parenthesized

  // NON_COMPLIANT: Nested conditional without clarifying parentheses
  l5 = l4 ? l1 + l2 : l3 * l1; // NON_COMPLIANT

  // COMPLIANT: Nested conditional with clarifying parentheses
  l5 = l4 ? (l1 + l2) : (l3 * l1); // COMPLIANT
}

// Test assignment expressions
void f3() {
  int l1 = 1, l2 = 2, l3 = 3, l4 = 4;

  // COMPLIANT: Assignment is excluded and compliant
  l1 += l2 * l3; // COMPLIANT

  // COMPLIANT: Chained assignment without clarifying parentheses
  l1 = l2 = l3;
}

int f4(int l1) { return l1 * 2; }

// Test expressions with function calls
void f5() {
  int l1 = 1, l2 = 2, l3 = 3;

  // NON_COMPLIANT: Function call in complex expression without parentheses
  int l4 = l1 + f4(l2) * l3; // NON_COMPLIANT

  // COMPLIANT: Function call in complex expression with parentheses
  l4 = l1 + (f4(l2) * l3); // COMPLIANT: multiplication is parenthesized

  // NON_COMPLIANT: Complex argument without parentheses
  l4 = f4(l1 + l2 * l3); // NON_COMPLIANT

  l4 = f4((l1 + l2 * l3)); // NON_COMPLIANT: inner expression
  l4 = f4(l1 + (l2 * l3)); // COMPLIANT: multiplication is parenthesized
}

// Test unary operators (excluded, always compliant)
void f6() {
  int l1 = 1, l2 = 2, l3 = 3;
  int *l4 = &l1;

  // COMPLIANT: Unary plus and minus (excluded from rule)
  int l5 = -l1 + l2; // COMPLIANT: unary minus is excluded
  l5 = +l1 * l2;     // COMPLIANT: unary plus is excluded
  l5 = -l1 * +l2;    // COMPLIANT: unary operators are excluded

  // COMPLIANT: Unary pointer operations (excluded from rule)
  int l6 = *l4 + l2; // COMPLIANT: pointer dereference is excluded
  l4 = &l4[0] + l2;  // COMPLIANT: address-of is excluded
  l6 = *l4 * +l4[0]; // COMPLIANT: unary operators are excluded

  // Combinations with binary operators
  l6 = -l1 + l2 * l3; // NON_COMPLIANT: binary operators still need parentheses
  l6 = -l1 + (l2 * l3); // COMPLIANT: binary operation is parenthesized
  l6 = *l4 + l2 * l3; // NON_COMPLIANT: binary operators still need parentheses
  l6 = *l4 + (l2 * l3); // COMPLIANT: binary operation is parenthesized
}

// Test throw and comma operator (excluded and compliant)
void f7() {
  int l1 = 1, l2 = 2, l3 = 3;

  // COMPLIANT: Throw expression (excluded from rule)
  try {
    throw l1 + l2;      // COMPLIANT: throw is excluded
    throw l1 + l2 * l3; // NON_COMPLIANT: expression inside throw
  } catch (int) {
  }

  // COMPLIANT: Comma operator (excluded from rule)
  int l4 = (l1 + l2, l3); // COMPLIANT: comma operator is excluded

  // But binary operators in these contexts still need parentheses
  l4 = (l1++, l2 + l3 * l1); // NON_COMPLIANT: expression inside comma operator
  l4 = (l1++, l2 + (l3 * l1)); // COMPLIANT: multiplication is parenthesized
}

// Test other excluded operators and expressions
void f8() {
  struct S {
    int l1;
    int l2;
    int arr[5];
  };

  S l1 = {1, 2, {1, 2, 3, 4, 5}};
  S *l2 = &l1;
  int l3 = 1, l4 = 2;

  // COMPLIANT: Member access, subscript, inc/dec (excluded from rule)
  int l5 = l1.l1 + l3; // COMPLIANT: member access is excluded
  l5 = l2->l2 * l4;    // COMPLIANT: member access is excluded
  l5 = l1.arr[0] + l4; // COMPLIANT: subscript is excluded
  l5 = l3++ + l4;      // COMPLIANT: increment is excluded
  l5 = --l4 * l3;      // COMPLIANT: decrement is excluded

  // COMPLIANT: Structure literals (excluded from rule)
  S l6 = {l3 + l4, l3 * l4}; // COMPLIANT: initializer is excluded

  // COMPLIANT: C-style casts (excluded from rule)
  l5 = (int)3.14 + l3; // COMPLIANT: cast is excluded

  // COMPLIANT: Literals (excluded from rule)
  l5 = 42 + l3; // COMPLIANT: literals are excluded

  // COMPLIANT: sizeof (excluded from rule)
  l5 = sizeof(int) * l3; // COMPLIANT: sizeof is excluded

  // COMPLIANT: new/delete (excluded from rule)
  int *l7 = new int(l3 + l4); // COMPLIANT: new is excluded
  delete l7;                  // COMPLIANT: delete is excluded

  // Binary operators still need parentheses
  l5 = l1.l1 + l3 * l4;   // NON_COMPLIANT: multiplication has higher precedence
  l5 = l1.l1 + (l3 * l4); // COMPLIANT: multiplication is parenthesized
}

// Test lambdas (excluded and compliant)
void f9() {
  int l1 = 1, l2 = 2;

  // COMPLIANT: Lambda expressions (excluded from rule)
  auto l4 = [&]() {
    return l1 + l2 * 2; // NON_COMPLIANT: lambda body still checked
  }();                  // COMPLIANT: lambda definition is always compliant
}

// Test macros
#define UNSAFE_MACRO(x, y, z) x + y *z  // Non compliant at usage sites
#define SAFE_MACRO(x, y, z) x + (y * z) // Compliant at usage sites

void f10() {
  int l1 = 1, l2 = 2, l3 = 3;

  // Macro usage
  int l4 = UNSAFE_MACRO(l1, l2, l3); // NON_COMPLIANT
  l4 = SAFE_MACRO(l1, l2, l3);       // COMPLIANT

  // Additional macro usage
  l4 = UNSAFE_MACRO(l1, l2, l3) + l1; // NON_COMPLIANT
  l4 = SAFE_MACRO(l1, l2, l3) + l1;   // COMPLIANT
}

// Test templates
template <typename T> T unsafe_template(T x, T y, T z) {
  return x + y * z; // NON_COMPLIANT: template function without parentheses
}

template <typename T> T safe_template(T x, T y, T z) {
  return x + (y * z); // COMPLIANT: template function with parentheses
}

void f11() {
  int l1 = 1, l2 = 2, l3 = 3;

  // Template usage
  int l4 = unsafe_template(l1, l2, l3); // NON_COMPLIANT
  l4 = safe_template(l1, l2, l3);       // COMPLIANT

  // Additional template usage
  l4 = unsafe_template(l1, l2, l3) + l1; // NON_COMPLIANT
  l4 = safe_template(l1, l2, l3) + l1;   // COMPLIANT
}

void f12() {
  int l1;
  sizeof l1;   // NON_COMPLIANT: sizeof without parentheses
  sizeof(l1);  // COMPLIANT: sizeof with parentheses
  sizeof(int); // COMPLIANT: sizeof with type always has parentheses
  // sizeof int; -- not valid C++

  // Since we're using locations to check this, add stress checks:
  // clang-format off
  sizeof l1 ;     // NON_COMPLIANT
  sizeof ( l1 );  // COMPLIANT
  sizeof ( int) ; // COMPLIANT
  sizeof          // NON_COMPLIANT
    l1
  ;
  sizeof (        // COMPLIANT
    l1
  );
  // clang-format on
}