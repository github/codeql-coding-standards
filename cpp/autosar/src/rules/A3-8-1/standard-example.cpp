//% $Id: A3-8-1.cpp 305786 2018-01-30 08:58:33Z michal.szczepankiewicz $ 2

//
// 1. Pointer to virtual base is passed as function argument after lifetime of
// object has ended.
//

class B
{
};
class C1 : public virtual B // violates M10-1-1
{
};

class C2 : public virtual B // violates M10-1-1
{
};

class D : public C1, public C2
{
};

void f(B const* b){};

void example1()
{
  D* d = new D(); // lifetime of d starts (violates A18-5-2)
  // Use d
  delete d; // lifetime of d ends (violates A18-5-2)

  f(d); // Non-compliant - Undefined behavior, even if argument is not used
        // by f().
}

//
// 2. Accessing an initializer_list after lifetime of initializing array has
// ended.
//
class E
{
  std::initializer_list<int> lst;

  public:
    // Conceptually, this works as if a temporary array {1, 2, 3} was created
    // and a reference to this array was passed to the initializer_list. The
    // lifetime of the temporary array ends when the constructor finishes.
    E() : lst{1, 2, 3} {}

    int first() const { return *lst.begin(); }
};

void example2()
{
  E e;
  std::out << e.first() << "\n"; // Non-compliant
}

//
// 3. Exiting main while running tasks depend on static objects
//
void initialize_task()
{
  // start some task (separate thread) which depends on some static object.
  // ...
}

int main()
{
  // static constructors are called

  initialize_task();
} // main ends, static destructors are called

// Non-compliant
// Task begins to run and accesses destroyed static object.

//
// 4. Storage reuse without explicit destructor call
//
void example4()
{
  std::string str;
  new (&a) std::vector<int>{}; // Non-compliant: storage of str reused without
                               // calling its non-trivial destructor. 
} // Non-compliant: Destructor of str is implicitly called at scope exit, but
  // storage contains object of different type.