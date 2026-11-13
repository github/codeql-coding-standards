// semmle-extractor-options:--clang -std=c++14 -nostdinc
#include "headers/stdlib.h"

using std::abort;
using std::exit;
using std::system;

void qualified_library_calls() {
  application::abort();    // COMPLIANT
  application::exit(0);    // COMPLIANT
  application::system(""); // COMPLIANT
  abort();                 // NON_COMPLIANT
  exit(0);                 // NON_COMPLIANT
  system("");              // NON_COMPLIANT
}
