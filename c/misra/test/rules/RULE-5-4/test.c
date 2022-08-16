#define iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjyszmcsylyohvqaosjbqyyA // NON_COMPLIANT
#define iltiqzxgfqsgigwfuyntzghvzltueatcxqnqofnnvjyszmcsylyohvqaosjbqyyB // NON_COMPLIANT

#define MACRO1 // COMPLIANT
#define MACRO2 // COMPLIANT

#define FUNCTION_MACRO(FUNCTION_MACRO) FUNCTION_MACRO + 1 // NON_COMPLIANT
#define FUNCTION_MACRO(X) X + 1                           // NON_COMPLIANT
#define FUNCTION_MACRO2(X) X + 1                          // COMPLIANT