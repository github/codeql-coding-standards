class Ref {
public:
  Ref() {}
  Ref(const Ref &) {}
  Ref &operator=(Ref) {}
  bool &getX() { return x; }

private:
  bool x = false;
};

void test() {
  Ref r;
  bool b = false;

  ++b;        // NON_COMPLIANT
  b++;        // NON_COMPLIANT
  r.getX()++; // NON_COMPLIANT

  b += 1;    // COMPLIANT
  b = b + 1; // COMPLIANT
}