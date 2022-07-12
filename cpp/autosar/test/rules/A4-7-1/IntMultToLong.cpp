int i = 2000000000;
long j = i * i;                    // NON_COMPLIANT
long k = (long)i * i;              // COMPLIANT
long l = (long)(i * i);            // permitted as the conversion is explicit
long m = static_cast<long>(i) * i; // COMPLIANT
long n = static_cast<long>(i * i); // permitted as the conversion is explicit
