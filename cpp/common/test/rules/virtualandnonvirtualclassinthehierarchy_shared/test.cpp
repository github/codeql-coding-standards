class Base {};                                            // COMPLIANT
class DerivedA : virtual public Base {};                  // COMPLIANT
class DerivedB : public Base {};                          // COMPLIANT
class DerivedC : public DerivedA, public DerivedB {};     // NON_COMPLIANT
class DerivedD : virtual public Base, public DerivedB {}; // NON_COMPLIANT