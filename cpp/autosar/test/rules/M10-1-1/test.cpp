class A {};                       // COMPLIANT
class B : virtual A {};           // NON_COMPLIANT
class C : A {};                   // COMPLIANT
class D : B {};                   // COMPLIANT
class E {};                       // COMPLIANT
class F : public virtual B, E {}; // NON_COMPLIANT