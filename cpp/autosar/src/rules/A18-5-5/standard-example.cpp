//% $Id: A18-5-5.cpp 289815 2017-10-06 11:19:11Z michal.szczepankiewicz $
#define __GNU_SOURCE 
#include <dlfcn.h> 
#include <cstddef>
void* MallocBad(size_t size) // Non-compliant, malloc from libc does not
                             // guarantee deterministic execution time 
{
  void* (*libcMalloc)(size_t) = (void* (*)(size_t))dlsym(RTLD_NEXT, "malloc"); 
  return libcMalloc(size);
}

void FreeBad(void* ptr) // Non-compliant, malloc from libc does not guarantee
                        // deterministic execution time
{
  void (*libcFree)(void*) = (void (*)(void*))dlsym(RTLD_NEXT, "free"); 
  libcFree(ptr);
}

void* MallocGood(size_t size) // Compliant - custom malloc implementation that
                              // will guarantee deterministic execution time 
{
  // Custom implementation that provides deterministic worst-case execution
  // time
}

void FreeGood(void* ptr) // Compliant - custom malloc implementation that will
                         // guarantee deterministic execution time
{
  // Custom implementation that provides deterministic worst-case execution
  // time
}