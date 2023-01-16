enum e { c = 3 };                   // COMPLIANT
enum e1 { c1 = 3, c2 };             // COMPLIANT
enum e3 { c3 = 3, c4, c5 = 4 };     // NON_COMPLIANT
enum e4 { c6 = 3, c7, c8, c9 = 6 }; // COMPLIANT