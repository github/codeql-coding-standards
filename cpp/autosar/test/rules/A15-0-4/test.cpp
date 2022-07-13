#include <stdexcept>

class DivByZero // COMPLIANT[FALSE_POSITIVE] - divide by zero is typically not
                // recoverable
    : public std::logic_error {};

class NoSuchFileException // NON_COMPLIANT - no such file is something that may
                          // be recoverable
    : public std::exception {};