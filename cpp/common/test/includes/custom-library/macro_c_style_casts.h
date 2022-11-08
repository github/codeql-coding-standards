// Macros used in test for A5-2-2
#define LIBRARY_ADD_TWO(x) ((int)x) + 2
#define LIBRARY_NESTED_ADD_TWO(x) LIBRARY_ADD_TWO(x)
#define LIBRARY_NO_CAST_ADD_TWO(x) x + 1