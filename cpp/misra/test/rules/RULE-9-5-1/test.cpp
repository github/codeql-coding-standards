void f(int &x) {} // Function that takes a non-const integer reference
void g(int *x) {} // Function that takes a non-const integer pointer

int main() {
  int j = 5;

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

  /* ========== 3. Updating expression ========== */

  for (int i = 0; i < 10;
       ++i) { // COMPLIANT: Pre-increment operator used as the update expression
  }

  for (int i = 0; i < 10; i++) { // COMPLIANT: Post-increment operator used as
                                 // the update expression
  }

  for (int i = 0; i < 10; i += 3) { // COMPLIANT: Add-and-assign operator used
                                    // as the update expression with loop step 3
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

  for (int i = 0; i < 10ull;
       i++) { // NON_COMPLIANT: The type of the loop counter is not bigger
              // than that of the loop bound
  }

  for (int i = 0; i < j;
       i++) { // NON_COMPLIANT: The loop bound is not a constant
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

  /* ========== 6. Existence of pointers to the loop counter, loop bound, and
   * loop step ========== */

  int k = 10;
  int l = 2;

  for (int i = 0; i < k; i += l) { // COMPLIANT: The loop counter, bound, and
                                   // step are not taken addresses of
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is passed
                                   // as a non-const reference
    f(j);
  }

  for (int i = j; i < k; i += l) { // NON_COMPLIANT: The loop counter is passed
                                   // as a non-const pointer
    g(&j);
  }

  for (int i = j; i < k;
       i +=
       l) { // NON_COMPLIANT: The loop bound is passed as a non-const pointer
    f(k);
  }

  for (int i = j; i < k;
       i +=
       l) { // NON_COMPLIANT: The loop bound is passed as a non-const pointer
    g(&k);
  }

  for (int i = j; i < k;
       i +=
       l) { // NON_COMPLIANT: The loop step is passed as a non-const pointer
    f(l);
  }

  for (int i = j; i < k;
       i +=
       l) { // NON_COMPLIANT: The loop step is passed as a non-const pointer
    g(&l);
  }
}