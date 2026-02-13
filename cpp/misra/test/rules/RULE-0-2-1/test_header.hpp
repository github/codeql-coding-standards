const int cg1 =
    3; // COMPLIANT - unused constant variable defined in header file.
constexpr int cg2 =
    4; // COMPLIANT - unused constant variable defined in header file.
extern const int cg3;     // COMPLIANT - unused constant variable with external
                          // linkage, defined in header file.
inline const int cg4 = 5; // COMPLIANT - unused constant variable defined in
                          // header file, with inline specifier.
static const int cg5 = 6; // COMPLIANT - unused constant variable defined in
                          // header file, with static specifier.

template <typename T>
constexpr int cg6 = 7; // COMPLIANT - unused constant variable defined in header
                       // file, with template.

namespace cg8ns {
const int cg8 = 8; // COMPLIANT - unused constant variable defined in header
                   // file, in a namespace.
}

class HeaderClass {
  const int m1 = 9;            // NON_COMPLIANT -- not namespace scope
  static const int m2 = 30234; // NON_COMPLIANT -- not namespace scope
};