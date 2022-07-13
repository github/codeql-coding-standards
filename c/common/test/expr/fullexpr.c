struct foo {
  int i;
  int j;
};

void full_expr() {
  int i;
  struct foo f = (struct foo){// Compound expression is a full expression.
                              .i = 0, // Assignments not a full expression, part
                                      // of a compound expression.
                              .j = 0};

  i++; // Full expression, part of expression statement

  if (i) { // i is a full expression
  }
  while (i) { // i is a full expression
  }
  do {
  } while (i); // i is a full expression

  for (i = 0; i < 10; ++i) { // i is a full expression in clause 1-3.
  }

  return i; // i is a full expression
}