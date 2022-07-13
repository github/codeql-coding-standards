// $Id: A5-3-3.cpp 309184 2018-02-26 20:38:28Z jan.babst $

// Non-compliant: At the point of deletion, pimpl points
// to an incomplete class type.
class Bad {
  class Impl;
  Impl *pimpl;

public:
  // ...
  ~Bad() { delete pimpl; } // violates A18-5-2
};

// Compliant: At the point of deletion, pimpl points to
// a complete class type.

// In a header file ...
class Good {
  class Impl;
  Impl *pimpl;

public:
  // ...
  ~Good();
};
// In an implementation file ...
class Good::Impl {
  // ...
};
// Good::Impl is a complete type now

Good::~Good() {
  delete pimpl; // violates A18-5-2
}

// Compliant: Contemporary solution using std::unique_ptr
// and conforming to A18-5-2.
// Note that std::unique_ptr<Impl> requires Impl to be a complete type
// at the point where pimpl is deleted and thus automatically enforces
// A5-3-3. This is the reason why the destructor of Better must be defined in an
// implementation file when Better::Impl is a complete type, even if the
// definition is just the default one.

// In a header file ...
#include <memory>
class Better {
  class Impl;
  std::unique_ptr<Impl> pimpl;

public:
  // ...
  ~Better();
};

// In an implementation file ...
class Better::Impl {
  // ...
};
// Better::Impl is a complete type now

Better::~Better() = default;