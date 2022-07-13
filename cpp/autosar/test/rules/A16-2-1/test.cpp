#include "./string.h" //COMPLIANT
#include "string.h"   //COMPLIANT

#include "'badheader.h" //NON_COMPLIANT
#include "badheade'r.h" //NON_COMPLIANT

// cannot use this filename in Windows
//#include "*.h" //NON_COMPLIANT

// cannot use this filename in Windows
//#include "\\badheader.h" //NON_COMPLIANT

//#include <"badheader.h"> //NON_COMPLIANT[FALSE_NEGATIVE]
//#include <badheader".h> //NON_COMPLIANT[FALSE_NEGATIVE]