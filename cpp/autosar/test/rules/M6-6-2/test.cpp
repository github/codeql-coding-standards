void test_goto_jump_forward_back() {
  int i = 5;
bad:
  if (i < 10) {
    goto good; // GOOD
  }
  goto bad; // BAD

good:
  i++;
}

void test_goto_mix_validity() {
  int i = 5;
sobad:
  i = i * i;
bad:
  if (i < 10) {
    goto good; // GOOD
  }
  goto bad; // BAD
good:
  i++;
  goto sobad; // BAD
}

void test_goto_jumpsameline_invalid() {
  int i = 3;
bad:
  i = 4;
  goto bad; // BAD
}