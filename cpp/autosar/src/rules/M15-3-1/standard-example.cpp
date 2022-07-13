class C {
public:
  C() {
    throw(0); // Non-compliant – thrown before main starts
    ~C()

    {
      throw(0); // Non-compliant – thrown after main exits
    }
  };
}

C c; // An exception thrown in C's constructor or destructor will
// cause the program to terminate, and will not be caught by
// the handler in main

int main(...) {
  try {
    // program code
    return 0;
  }
  // The following catch-all exception handler can only
  // catch exceptions thrown in the above program code
  catch (...) {
    // Handle exception
    return 0;
  }
}