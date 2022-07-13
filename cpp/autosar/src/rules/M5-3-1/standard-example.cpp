if((a < b) && (c < d)) // Compliant
if(1 && (c < d))       // Non-compliant
if((a < b) && (c + d)) // Non-compliant
if(u8_a && (c + d))    // Non-compliant
if(!0)                 // Non-compliant -
                       //   also breaks other rules
if(!ptr)               // Non-compliant
if(!false)             // Compliant with this rule,
                       //   but breaks others