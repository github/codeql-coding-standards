void test_unsigned_literals_without_suffix() {
  0xFFFFFFFFU; // COMPLIANT - literal explicitly marked as unsigned
  0xFFFFFFFF;  // NON_COMPLIANT - literal is too large for a signed int, so has
               // type unsigned int
}