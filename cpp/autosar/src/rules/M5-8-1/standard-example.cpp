u8a  = (uint8_t) (u8a << 7);            // Compliant
u8a  = (uint8_t) (u8a << 9);            // Non-compliant
u16a = (uint16_t)((uint16_t) u8a << 9); // Compliant