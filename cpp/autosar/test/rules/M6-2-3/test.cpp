

void test_empty_stmts(int x) {
  ;           // COMPLIANT
  ;           // COMPLIANT
  /* sdfsd*/; // NON_COMPLIANT

  // Disable clang-format to ensure we can place adjacent statements and
  // comments on the same line.

  // clang-format off
  0; ;  // NON_COMPLIANT
  ; 0;  // NON_COMPLIANT
  ;// NON_COMPLIANT - must be at least one whitespace char between the empty statement and comment

  { ; }       // NON_COMPLIANT
  { ;         // NON_COMPLIANT
  }
  {
    ; }       // NON_COMPLIANT
  if (x) ;    // NON_COMPLIANT
  while (x) ; // NON_COMPLIANT
  label: ;    // NON_COMPLIANT
  if
    (x) ;     // NON_COMPLIANT
  if
    (x
    ) ;       // NON_COMPLIANT[FALSE_NEGATIVE] - this can't be found because we don't have a location for the `(` token
  if (x)
    ; 0;      // NON_COMPLIANT
  try
  { ;         // NON_COMPLIANT
  }
  catch (int x)
  { ;         // NON_COMPLIANT
  }
  catch (...)
  {
    ; }       // NON_COMPLIANT
  try { }
  catch (...) {
  } ;         // NON_COMPLIANT
  if (x)
    if (x+1)
      if (x+2)
        ; 0;  // NON_COMPLIANT
  {
    if (x)
      if (x+1)
        if (x+2)
          ; } // NON_COMPLIANT

  {
    ;         // COMPLIANT
  }
  if (x)
    ;         // COMPLIANT
  while (x)
    ;         // COMPLIANT
  label2:
    ;         // COMPLIANT
   // test
  ;           // COMPLIANT
  // clang-format on
}