if(ishigh && (x == i++))  // Non-compliant
...
if(ishigh && (x == f(x))) // Only acceptable if f(x) is
                          // known to have no side effects