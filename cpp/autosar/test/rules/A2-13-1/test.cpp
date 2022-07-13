void test_escape_sequences() {
  "\'";         // COMPLIANT
  "\"";         // COMPLIANT
  "\?";         // COMPLIANT
  "\\";         // COMPLIANT
  "\a";         // COMPLIANT
  "\b";         // COMPLIANT
  "\f";         // COMPLIANT
  "\n";         // COMPLIANT
  "\r";         // COMPLIANT
  "\t";         // COMPLIANT
  "\v";         // COMPLIANT
  "\033";       // COMPLIANT - Octal literals
  "\0";         // COMPLIANT - Octal literals
  "\xA2";       // COMPLIANT - Hex literals
  "\U00000024"; // COMPLIANT - Universal character name (8 hex digits)
  "\u0024";     // COMPLIANT - Universal character name (4 hex digits)

  "\c"; // NON_COMPLIANT
  "\d"; // NON_COMPLIANT
  "\e"; // NON_COMPLIANT
  "\g"; // NON_COMPLIANT
  "\h"; // NON_COMPLIANT
  "\i"; // NON_COMPLIANT
  "\j"; // NON_COMPLIANT
  "\k"; // NON_COMPLIANT
  "\l"; // NON_COMPLIANT
  "\m"; // NON_COMPLIANT
  "\o"; // NON_COMPLIANT
  "\p"; // NON_COMPLIANT
  "\q"; // NON_COMPLIANT
  "\s"; // NON_COMPLIANT
  "\w"; // NON_COMPLIANT
  "\y"; // NON_COMPLIANT
  "\z"; // NON_COMPLIANT
}