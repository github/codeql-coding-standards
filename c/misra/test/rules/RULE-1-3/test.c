int main(void) { // COMPLIANT
}

void ____codeql_coding_standards_main1(void) { // NON_COMPLIANT
  return 0;
}

int ____codeql_coding_standards_main2() { // NON_COMPLIANT
  return 0;
}

int ____codeql_coding_standards_main3(int argc, char **argv) { // COMPLIANT
  return 0;
}

int ____codeql_coding_standards_main4(int argc, char argv[][]) { // COMPLIANT
  return 0;
}

int ____codeql_coding_standards_main5(int argc, char *argv[]) { // COMPLIANT
  return 0;
}

typedef int MY_INT;
typedef char *MY_CHAR_PTR;

int ____codeql_coding_standards_main6(MY_INT argc,
                                      MY_CHAR_PTR argv[]) { // COMPLIANT
  return 0;
}

void ____codeql_coding_standards_main7(char *argc,
                                       char **argv) { // NON_COMPLIANT
}

int ____codeql_coding_standards_main8(int argc, char *argv) { // NON_COMPLIANT
  return 0;
}

int ____codeql_coding_standards_main9() { // NON_COMPLIANT
  return 0;
}

int ____codeql_coding_standards_main10(int argc, int *argv) { // NON_COMPLIANT
  return 0;
}

int ____codeql_coding_standards_main11(int argc, int **argv) { // NON_COMPLIANT
  return 0;
}
