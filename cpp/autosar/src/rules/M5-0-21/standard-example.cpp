if((uint16_a & int16_b ) == 0x1234U) // Non-compliant
if((uint16_a | uint16_b) == 0x1234U) // Compliant
if(~int16_a == 0x1234U)              // Non-compliant
if(~uint16_a == 0x1234U)             // Compliant