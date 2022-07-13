    int8_t  a = 'a';  // Non-compliant – explicitly signed
    uint8_t b = '\r'; // Non-compliant – explicitly unsigned
    int8_t  c = 10;   // Compliant
    uint8_t d = 12U;  // Compliant
signed char e = 11;   // Compliant with this rule, but breaks Rule 3–9–2
