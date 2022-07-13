class A {};
class B1: public virtual A {};  // Compliant – A is a common base for C
class B2: public virtual A {};  // Compliant – A is a common base for C
class C:  public B1, B2 {};
class D: public virtual A {};   // Non-compliant