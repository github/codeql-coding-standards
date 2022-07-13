class A {};
class B1: public virtual A {};
class B2: public virtual A {};
class B3: public         A {};
class C:  public B1, B2, B3 {}; // Non-compliant –
                                // C has two A sub-objects