// $Id: A17-1-1.cpp 289436 2017-10-04 10:45:23Z michal.szczepankiewicz $
#include <cerrno>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <stdexcept>

void Fn1(const char *filename) // Compliant - C code is isolated; fn1()
                               // function is a wrapper.
{
  FILE *handle = fopen(filename, "rb");
  if (handle == NULL) {
    throw std::system_error(errno, std::system_category());
  }
  // ...
  fclose(handle);
}

void Fn2() noexcept {
  try {
    Fn1("filename.txt"); // Compliant - fn1() allows you to use C code like
                         // C++ code

    // ...
  } catch (std::system_error &e) {
    std::cerr << "Error: " << e.code() << " - " << e.what() << ’\n’;
  }
}

std::int32_t Fn3(const char *filename) noexcept // Non-compliant - placing C
// functions calls along with C++
// code forces a developer to be
// responsible for C-specific error
// handling, explicit resource
// cleanup, etc.
{
  FILE *handle = fopen(filename, "rb");
  if (handle == NULL) {
    std::cerr << "An error occured: " << errno << " - " << strerror(errno)
              << ’\n’;
    return errno;
  }

  try {
    // ...
    fclose(handle);
  } catch (std::system_error &e) {
    fclose(handle);
  } catch (std::exception &e) {
    fclose(handle);
  }

  return errno;
}