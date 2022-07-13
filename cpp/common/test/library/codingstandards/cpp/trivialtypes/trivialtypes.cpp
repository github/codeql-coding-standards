/* Trivial types */

class TrivialClassA {};

struct TrivialStructA {};

class TrivialClassB {
public:
  int x;

private:
  int y;
};
struct TrivialStructB {
  int x;
  int y;
};

class TrivialClassC {
public:
  TrivialClassC(int p_x);
  TrivialClassC() = default;

private:
  int x;
};

class TrivialClassD {
  TrivialClassA x; // trivial because data member is trivial
};

/* Non-trivial types */

class NonTrivialClassA {
public:
  NonTrivialClassA(int p_x); // non-trivial because no default constructor

private:
  int x;
};

struct NonTrivialStructA {
  NonTrivialClassA x{1}; // Non-trivial data member
};