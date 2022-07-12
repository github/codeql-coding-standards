//% $Id: A15-3-3.cpp 309502 2018-02-28 09:17:39Z michal.szczepankiewicz $
#include <stdexcept>

// base exception class from external library that is used
class ExtLibraryBaseException {};

int MainGood(int, char **) // Compliant
{
  try {
    // program code
  } catch (std::runtime_error &e) {
    // Handle runtime errors
  } catch (std::logic_error &e) {
    // Handle logic errors
  } catch (ExtLibraryBaseException &e) {
    // Handle all expected exceptions
    // from an external library
  } catch (std::exception &e) {
    // Handle all expected exceptions
  } catch (...) {
    // Handle all unexpected exceptions
  }

  return 0;
}
int MainBad(int, char **) // Non-compliant - neither unexpected exceptions
                          // nor external libraries exceptions are caught
{
  try {
    // program code
  } catch (std::runtime_error &e) {
    // Handle runtime errors
  } catch (std::logic_error &e) {
    // Handle logic errors
  } catch (std::exception &e) {
    // Handle all expected exceptions
  }

  return 0;
}
void ThreadMainGood() // Compliant
{
  try {
    // thread code
  } catch (ExtLibraryBaseException &e) {
    // Handle all expected exceptions
    // from an external library
  } catch (std::exception &e) {
    // Handle all expected exception
  } catch (...) {
    // Handle all unexpected exception
  }
}

void ThreadMainBad() // Non-compliant - neither unexpected exceptions
                     // nor external libraries exceptions are caught
{
  try {
    // thread code
  } catch (std::exception &e) {
    // Handle all expected exceptions
  }
  // Uncaught unexpected exception will cause an immediate program termination
}