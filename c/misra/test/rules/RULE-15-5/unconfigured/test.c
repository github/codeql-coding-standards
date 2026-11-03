void multiple_exits(
    int condition) { // COMPLIANT: the guideline is Disapplied by default.
  if (condition) {
    return;
  }
  return;
}

void single_exit(void) { // COMPLIANT
  return;
}