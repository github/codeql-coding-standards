#include <stdexcept>

// @checkedException
class DivByZero // NON_COMPLIANT - divide by zero is typically not recoverable
    : public std::logic_error {};

// @checkedException
class NoSuchFileException // COMPLIANT[FALSE_POSITIVE] - no such file is
                          // something that may be recoverable
    : public std::exception {};

/*
 * @checkedException
 */
class CheckedException // COMPLIANT[FALSE_POSITIVE]
    : public std::exception {};

class OtherException // not a checked exception
    : public std::exception {};