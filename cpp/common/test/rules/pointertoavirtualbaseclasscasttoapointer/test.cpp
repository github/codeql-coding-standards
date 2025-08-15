class C1 {
public:
  virtual ~C1() {}
};
class C2 : public virtual C1 {
public:
  C2() {}
  ~C2() {}
};

void f1() {
  C2 l1;
  C1 *p1 = &l1;

  // C2 *p2 = static_cast<C2 *>(p1);   // NON_COMPLIANT, prohibited by compiler
  C2 *p3 = dynamic_cast<C2 *>(p1);  // COMPLIANT
  C2 &l2 = dynamic_cast<C2 &>(*p1); // COMPLIANT
}
