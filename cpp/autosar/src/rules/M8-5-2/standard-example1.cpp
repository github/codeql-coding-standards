int16_t y[3][2] = { 1, 2, 3, 4, 5, 6 };              // Non-compliant
int16_t y[3][2] = { { 1, 2 }, { 3, 4 }, { 5, 6 } };  // Compliant