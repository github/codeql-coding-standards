#include "stddef.h"
#include <exception>

void f() {
  try {
  } catch (std::exception e) { // NON_COMPLIANT - std::exception is not trivial
  }

  try {
  } catch (
      std::exception &e) {     // COMPLIANT - std::exception is a reference type
  } catch (int i) {            // COMPLIANT - int is trivial
  } catch (int i[]) {          // COMPLIANT - int[] is trivial
  } catch (int *i) {           // COMPLIANT - int* is trivial
  } catch (const int *i) {     // COMPLIANT - const int* is trivial
  } catch (std::nullptr_t p) { // COMPLIANT - nullptr_T is trivial
  }
}