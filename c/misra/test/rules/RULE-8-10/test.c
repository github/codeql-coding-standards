static inline void f();  // COMPLIANT
extern inline void f1(); // NON_COMPLIANT
inline void f2();        // NON_COMPLIANT
extern inline void f(); // NON_COMPLIANT -while this will be internal linkage it
                        // is less clear than explicitly specifying static
