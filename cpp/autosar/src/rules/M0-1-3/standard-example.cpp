extern void usefn(int16_t a, int16_t b);
class C {
  ...
};
C c; // Non-compliant - unused
void withunusedvar(void) {
  int16_t unusedvar; // Non-compliant – unused
  struct s_tag {
    signed int a : 3;
    signed int pad : 1; // Non-compliant – should be unnamed
    signed int b : 2;
  } s_var;

  s_var.a = 0;
  s_var.b = 0;
  usefn(s_var.a, s_var.b);
}