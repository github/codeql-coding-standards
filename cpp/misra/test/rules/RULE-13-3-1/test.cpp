class VirtualMemberBase {
public:
  virtual void m1_virtual() {} // COMPLIANT
};

class NonvirtualMemberBase {
public:
  void m1_nonvirtual() {} // COMPLIANT
};

// Invalid base class declarations
class InvalidBaseClass {
public:
  virtual void f1() final = 0; // NON_COMPLIANT
  virtual void f2() final {}   // NON_COMPLIANT

  // Does not compile: final nonvirtual function
  // void f3() final {}        // NON_COMPLIANT
};

class C1 : public VirtualMemberBase {
public:
  void m1_virtual() override {} // COMPLIANT
};

class C2 : public VirtualMemberBase {
public:
  void m1_virtual() final {} // COMPLIANT
};

class C3 : public VirtualMemberBase {
public:
  virtual void m1_virtual() {} // NON_COMPLIANT
};

class C4 : public VirtualMemberBase {
public:
  virtual void m1_virtual() override {} // NON_COMPLIANT
};

class C5 : public VirtualMemberBase {
public:
  virtual void m1_virtual() final {} // NON_COMPLIANT
};

class C6 : public VirtualMemberBase {
public:
  void m1_virtual() final override {} // NON_COMPLIANT
};

class C7 : public VirtualMemberBase {
public:
  void m1_virtual() {} // NON_COMPLIANT
};

class C8 : public NonvirtualMemberBase {
public:
  void m1_nonvirtual() {} // COMPLIANT
};

class C9 : public NonvirtualMemberBase {
public:
  virtual void m1_nonvirtual() {
  } // COMPLIANT: Note that this violates rule 6.4.2
};

class C10 : public NonvirtualMemberBase {
public:
  virtual void m1_nonvirtual() final {
  } // NON_COMPLIANT: Note that this also violates rule 6.4.2
};

class VirtualDestructorBase {
public:
  virtual ~VirtualDestructorBase() = default; // COMPLIANT
};

class NonvirtualDestructorBase {
public:
  ~NonvirtualDestructorBase() = default; // COMPLIANT
};

class C11 : public VirtualDestructorBase {
public:
  ~C11() override = default; // COMPLIANT
};

class C12 : public VirtualDestructorBase {
public:
  ~C12(); // NON_COMPLIANT
};

class C13 : public VirtualDestructorBase {
public:
  virtual ~C13() override = default; // NON_COMPLIANT
};

class C14 : public NonvirtualDestructorBase {
public:
  ~C14() = default; // COMPLIANT
};

class C15 : public NonvirtualDestructorBase {
public:
  virtual ~C15() =
      default; // COMPLIANT: Note that this does not violate rule 6.4.2
};