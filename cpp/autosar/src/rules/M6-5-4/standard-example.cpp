for(x = 0; x < 10; ++x)       // Compliant
for(T x = thing.start();
      x != thing.end(); 
      ++x)                    // Compliant
for(x = 0; x < 10; x += 1)    // Compliant
for(x = 0; x < 10; x += n)    // Compliant if n is not modified
                              // within the body of the loop.
for(x = 0; x < 10; x += fn()) // Non-compliant