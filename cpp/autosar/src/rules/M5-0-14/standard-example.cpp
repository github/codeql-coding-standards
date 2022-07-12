int32_a = int16_b ? int32_c : int32_d;       // Non-compliant
int32_a = bool_b  ? int32_c : int32_d;       // Compliant
int32_a = (int16_b < 5) ? int32_c : int32_d; // Compliant