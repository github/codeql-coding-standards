int32_t i;
int32_t j;
volatile int32_t k;
j = sizeof(i = 1234); // Non-compliant - j is set to the sizeof the
                      // type of i which is an int32_t.
                      // i is not set to 1234.
j = sizeof(k);        // Compliant by exception.