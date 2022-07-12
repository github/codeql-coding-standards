// abstract class
class C1 {
  virtual C1 &operator=(C1 const &) = 0; // NON_COMPLIANT-pure virtual function
};

class C2 : public C1 {
public:
  /*
      overrides C1::operator= because is has:
      - the same name 'operator=',
      - the same parameter list C1& const (note that the return type is not
     included),
      - the same cv-qualifiers,
      - the same ref-qualifers
  */
  C2 &operator=(C1 const &oth) { return *this; } // COMPLIANT

private:
  int m1;
};

class C3 : public C1 {
  C3 &operator=(C1 const &oth) {
    C3 const &c3 = static_cast<C3 const &>(oth); // downcast C1 to C3
    return *this;
  }

private:
  long long m1;
};