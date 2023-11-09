#include "test.hpp" //NON_COMPLIANT
#include <algorithm> //NON_COMPLIANT - redundant but not useless on real compilers
#include <vector>    //COMPLIANT

std::vector<int> v;