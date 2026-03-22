#include "test.hpp"

/*
 * This file demonstrates that anonymous namespace variables
 * in headers create translation-unit-local copies.
 */

void setValues() {
  x = 42;              // Sets file1.cpp's copy of x
  MyNamespace::y = 42; // Sets the shared y
  z = 42;              // Sets the shared z
  Outer::nested = 42;  // Sets file1.cpp's copy of nested
}

std::int32_t getX_File1() {
  return x; // Returns file1.cpp's copy of x
}

std::int32_t getNested_File1() {
  return Outer::nested; // Returns file1.cpp's copy of nested
}
