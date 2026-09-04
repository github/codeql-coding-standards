#include "headers/test1.h"

#include "headers/test2.h"

#include "headers/test3.h" //NON_COMPLIANT

#include "headers/test4.h" //NON_COMPLIANT
#define HEADER_FOUR

#include "headers/test5.h" //NON_COMPLIANT

#include "headers/test6.h" //NON_COMPLIANT - non unique and reported in alert for the next

#include "headers/test7.h" //NON_COMPLIANT - non unique