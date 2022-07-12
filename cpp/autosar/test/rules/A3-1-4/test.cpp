extern int array1[];  // NON_COMPLIANT
extern int array2[2]; // COMPLIANT
constexpr int size1 = 2;
extern int
    array3[size1]; // COMPLIANT; size can be explicitly determined through size1
const int size2 = 2;
extern int
    array4[size2]; // COMPLIANT; size can be explicitly determined through size2