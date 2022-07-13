bool   b1 = true;
bool   b2 = false;
int8_t s8a;
 
if ( b1 & b2 )     // Non-compliant
if ( b1 < b2 )     // Non-compliant
if ( ~b1 )         // Non-compliant
if ( b1 ^ b2 )     // Non-compliant
if ( b1 == false ) // Compliant
if ( b1 == b2 )    // Compliant
if ( b1 != b2 )    // Compliant
if ( b1 && b2 )    // Compliant
if ( !b1 )         // Compliant
s8a = b1 ? 3 : 7;  // Compliant