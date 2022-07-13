void f1(void) {
  char ch;
  ch = (char)getchar();
  /*
   * The following test is non-compliant. It will not be reliable as the
   * return value is cast to a narrower type before checking for EOF.
   */
  if (EOF != (int32_t)ch) {
  }
}