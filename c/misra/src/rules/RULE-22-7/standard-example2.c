void f2(void) {
  char ch;
  ch = (char)getchar();
  if (!feof(stdin)) {
  }
}

void f3(void) {
  int32_t i_ch;
  i_ch = getchar();
  /*
   * The following test is compliant. It will be reliable as the
   * unconverted return value is used when checking for EOF.
   */
  if (EOF != i_ch) {
    char ch;
    ch = (char)i_ch;
  }
}