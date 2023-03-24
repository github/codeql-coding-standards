void main(void) { // COMPLIANT
}

int ____codeql_coding_standards_m1(int argc, char **argv) { // NON_COMPLIANT
  return 0;
}

void ____codeql_coding_standards_m2(char *argc, char **argv) { // NON_COMPLIANT
}

int ____codeql_coding_standards_m3(int argc, char *argv) { // NON_COMPLIANT
  return 0;
}

int ____codeql_coding_standards_m4() { // NON_COMPLIANT
  return 0;
}

int ____codeql_coding_standards_m5(int argc, int *argv) { // NON_COMPLIANT
  return 0;
}

int ____codeql_coding_standards_m6(int argc, int **argv) { // NON_COMPLIANT
  return 0;
}
