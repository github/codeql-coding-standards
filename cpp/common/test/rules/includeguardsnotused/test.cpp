#include "headers/test1.hpp"

#include "headers/test2.hpp"

#include "headers/test3.hpp" //NON_COMPLIANT

#include "headers/test4.hpp" //NON_COMPLIANT
#define HEADER_FOUR

#include "headers/test5.hpp" //COMPLIANT - non unique precedes malformed

#include "headers/test6.hpp" //COMPLIANT - non unique

#include "headers/test7.hpp" //NON_COMPLIANT - missing include guard, not excluded

#include "headers/excluded/test7.hpp" // COMPLIANT - excluded via deviation