#include <limits>
#include <string>
#include <string_view>

void f1(int &x) {}       // Function that takes a non-const integer reference
void g1(int *x) {}       // Function that takes a non-const integer pointer
void f2(const int &x) {} // Function that takes a non-const integer reference
void g2(const int *x) {} // Function that takes a non-const integer pointer
void f3(int *const x) {}
void f4(int *x...) {}       // Function that takes a non-const integer pointer
void g4(int &x...) {}       // Function that takes a non-const integer pointer
void f5(const int *x...) {} // Function that takes a non-const integer pointer
void g5(const int &x...) {} // Function that takes a non-const integer pointer

int h1() { return 1; }
constexpr int h2() { return 1; }

int h3(int x) { return x; }

void h4(int &args...) {}
void h5(const int &args...) {}

int main() {
  int j = 5;
  int k = 10;
  int l = 2;

  /* ========== 1. Type of the initialized counter variable ========== */

  for (int i = 0; i < 10; i++) { // COMPLIANT: `i` has an integer type
  }

  for (float i = 0.0; i < 10;
       i++) { // NON_COMPLIANT: `i` has a non-integer type
  }

  /* ========== 2. Termination condition ========== */

  for (int i = 0; i < 10; i++) { // COMPLIANT: `<` is a relational operator
  }

  for (int i = 0; i == 10;
       i++) { // NON_COMPLIANT: `==` is not a relational operator
  }

  for (int i = 0; j < 10; i++) { // NON_COMPLIANT: `j` is not the loop counter
    j++;
  }

  /*
   * The following test cases in this section document our stance on arithmetic
   * operations on loop counters appearing as an operand of the loop condition.
   * Our stance is that such conditions are non-compliant cases according to
   * this part of the rule.
   *
   * Why we think they are non-compliant is as follows: We interpret the rule as
   * having the loop counter be an index that are meant to be used directly as
   * is, by their value. Therefore, performing arithmetic and comparing the
   * result to a loop bound goes against the interpretation.
   */

  for (int i = 0; i + 10 < j;
       ++i) { // NON_COMPLIANT: The loop condition does not directly compare
              // loop counter `i` to the loop bound `j`
  }

  for (int i = 0; h3(i) < j;
       ++i) { // NON_COMPLIANT: The loop condition does not directly compare
              // loop counter `i` to the loop bound `j`
  }

  for (int i = 0; i++ < j++;
       i++) { // NON_COMPLIANT: The loop condition does not directly compare
              // loop counter `i` to the loop bound `j`
  }

  /* ========== 3. Updating expression ========== */

  for (int i = 0; i < 10;
       ++i) { // COMPLIANT: Pre-increment operator used as the update expression
  }

  for (int i = 0; i < 10; i++) { // COMPLIANT: Post-increment operator used as
                                 // the update expression
  }

  for (int i = 20; i > 10;
       --i) { // COMPLIANT: Pre-increment operator used as the update expression
  }

  for (int i = 20; i > 10; i--) { // COMPLIANT: Post-increment operator used as
                                  // the update expression
  }

  for (int i = 0; i < 10; i += 3) { // COMPLIANT: Add-and-assign operator used
                                    // as the update expression with loop step 3
  }

  for (int i = 20; i > 10;
       i -= 3) { // COMPLIANT: Add-and-assign operator used
                 // as the update expression with loop step 3
  }

  for (int i = 0; i < 10;
       i = i +
           3) { // COMPLIANT: Direct assignment with addition with loop step 3
  }

  for (int i = 20; i < 10;
       i = i -
           3) { // COMPLIANT: Direct assignment with addition with loop step 3
  }

  for (int i = 0; i < 10;
       i *= 2) { // NON_COMPLIANT: Mutiplication is not incrementing
  }

  /* ========== 4. Type of the loop counter and the loop bound ========== */

  for (int i = 0; i < 10; i++) { // COMPLIANT: 0 and 10 are of same type
  }

  for (unsigned long long int i = 0; i < 10;
       i++) { // COMPLIANT: The loop counter has type bigger than that of the
              // loop bound
  }

  for (short i = 0; i < std::numeric_limits<int>::max();
       i++) { // NON_COMPLIANT: The type of the loop counter is not bigger
              // than that of the loop bound
  }

  for (int i = 0; i < j;
       i++) { // COMPLIANT: The loop step and the loop bound has the same type
  }

  /* ========== 5. Immutability of the loop bound and the loop step ==========
   */

  for (int i = 0; i < 10;
       i++) { // COMPLIANT: The update expression is an post-increment operation
              // and its loop step is always 1
  }

  for (int i = 0; i < 10; i += 2) { // COMPLIANT: The loop step is always 2
  }

  for (int i = 0; i < 10;
       i +=
       j) { // COMPLIANT: The loop step `j` is not mutated anywhere in the loop
  }

  for (int i = 0; i < 10;
       i += j) { // NON_COMPLIANT: The loop step `j` is mutated in the loop
    j++;
  }

  for (int i = 0; i < 10;
       i += j, j++) { // NON_COMPLIANT: The loop step `j` is mutated in the loop
  }

  for (int i = 0; i < j; i++) { // COMPLIANT: The loop bound `j` is not mutated
                                // anywhere in the loop
  }

  for (int i = 0; i < j; i++) { // COMPLIANT: The loop bound `j` is not mutated
                                // anywhere in the loop
  }

  for (int i = 0; i < j;
       i++) { // NON_COMPLIANT: The loop bound `j` is mutated in the loop
    j++;
  }

  for (int i = 0; i < j++;
       i++) { // NON_COMPLIANT: The loop bound `j` is mutated in the loop
  }

  for (int i = 0; i++ < j++;
       i++) { // NON_COMPLIANT: The loop bound `j` is mutated in the loop
  }

  int n = 0;

  for (int i = 0; i < k;
       i += l) { // NON_COMPLIANT: The loop bound is mutated through an address
    *(true ? &k : &n) += 1;
  }

  for (int i = 0; i < k;
       i += l) { // NON_COMPLIANT: The loop step is mutated through an address
    *(true ? &l : &n) += 1;
  }

  for (int i = 0; i < h1();
       i++) { // NON_COMPLIANT: The loop bound is not a constant expression
  }

  for (int i = 0; i < h2();
       i++) { // COMPLIANT: The loop bound is a constant expression
  }

  for (int i = 0; i < j;
       i += h1()) { // NON_COMPLIANT: The loop step is not a constant expression
  }

  for (int i = 0; i < j;
       i += h2()) { // COMPLIANT: The loop step is a constant expression
  }

  /* ========== 6. Existence of pointers to the loop counter, loop bound, and
   * loop step ========== */

  for (int i = 0; i < k; i += l) { // COMPLIANT: The loop counter, bound, and
                                   // step are not taken addresses of
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is taken
                                   // as a non-const reference
    int &m = i;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is taken
                                   // as a non-const pointer
    int *m = &i;
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop counter is taken
                                   // as a const reference
    const int &m = i;
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop counter is taken
                                   // as a const pointer
    const int *m = &i;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is taken
                                   // as a const but mutable pointer
    int *const m = &i;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop bound is taken as
                                   // a non-const reference
    int &m = k;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop bound is taken as
                                   // a non-const pointer
    int *m = &k;
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop bound is taken
                                   // as a const reference
    const int &m = k;
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop bound is taken
                                   // as a const pointer
    const int *m = &k;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop bound is taken as
                                   // a const but mutable pointer
    int *const m = &k;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop step is taken as
                                   // a non-const reference
    int &m = l;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop step is taken as
                                   // a non-const pointer
    int *m = &l;
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop step is taken as
                                   // a const reference
    const int &m = l;
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop step is taken as
                                   // a const pointer
    const int *m = &l;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop step is taken as
                                   // a const but mutable pointer
    int *const m = &l;
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is passed
                                   // to a non-const reference parameter
    f1(i);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is passed
                                   // to a non-const pointer parameter
    g1(&i);
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop counter is passed
                                   // to a const reference parameter
    f2(i);
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop counter is passed
                                   // to a const pointer parameter
    g2(&i);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is passed
                                   // to a const but mutable pointer parameter
    f3(&i);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is passed
                                   // to a non-const variadic reference argument
    f4(&i);
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop counter is passed to a
                                   // const variadic reference argument
    f5(&i);
  }

  for (int i = 0; i < k; i += l) { // NON_COMPLIANT: The loop counter is passed
                                   // to a non-const variadic reference argument
    g4(i);
  }

  for (int i = 0; i < k; i += l) { // COMPLIANT: The loop counter is passed to a
                                   // const variadic reference argument
    g5(i);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop bound is passed to
                                   // a non-const reference parameter
    f1(k);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop bound is passed to
                                   // a non-const pointer parameter
    g1(&k);
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop bound is passed to a
                                   // const reference parameter
    f2(k);
  }

  for (int i = j; i < k;
       i +=
       l) { // COMPLIANT: The loop bound is passed to a const pointer parameter
    g2(&k);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop bound is passed to
                                   // a const but mutable pointer parameter
    f3(&k);
  }

  for (int i = 0; i < k; i += l) { // NON_COMPLIANT: The loop bound is passed to
                                   // a non-const variadic reference argument
    f4(&k);
  }

  for (int i = 0; i < k; i += l) { // COMPLIANT: The loop bound is passed to a
                                   // const variadic reference argument
    f5(&k);
  }

  for (int i = 0; i < k; i += l) { // NON_COMPLIANT: The loop bound is passed to
                                   // a non-const variadic reference argument
    g4(k);
  }

  for (int i = 0; i < k; i += l) { // COMPLIANT: The loop bound is passed to a
                                   // const variadic reference argument
    g5(k);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop step is passed to
                                   // a non-const reference parameter
    f1(l);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop step is passed to
                                   // a non-const pointer parameter
    g1(&l);
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop step is passed to
                                   // a const reference parameter
    f2(l);
  }

  for (int i = j; i < k; i += l) { // COMPLIANT: The loop step is passed to
                                   // a const pointer parameter
    g2(&l);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop step is passed to
                                   // a const but mutable pointer parameter
    f3(&l);
  }

  for (int i = 0; i < k; i += l) { // NON_COMPLIANT: The loop step is passed to
                                   // a non-const variadic reference argument
    f4(&l);
  }

  for (int i = 0; i < k; i += l) { // COMPLIANT: The loop step is passed to a
                                   // const variadic reference argument
    f5(&l);
  }

  for (int i = 0; i < k; i += l) { // NON_COMPLIANT: The loop step is passed to
                                   // a non-const variadic reference argument
    g4(l);
  }

  for (int i = 0; i < k; i += l) { // COMPLIANT: The loop step is passed to a
                                   // const variadic reference argument
    g5(l);
  }
}
