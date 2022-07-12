class Dog {
  const char *name;

public:
  Dog(const char *name) : name(name) {}
  virtual void const print_info() const;
};

class Chihuahua : public Dog {
  Dog rival;

public:
  Chihuahua(const char *name, const Dog &rival) : Dog(name), rival(rival) {}
  const Dog &get_rival() { return rival; }
};

void f(Dog e) { e.print_info(); }

void f_ref(const Dog &e) { e.print_info(); }

void f_ptr(const Dog *e) { e->print_info(); }

void test() {
  Dog d1("Rex");                                              // COMPLIANT
  Dog d2("Princess");                                         // COMPLIANT
  Chihuahua c1("Ingenius Balduin von den Koenigswiesen", d2); // COMPLIANT
  Dog d3(Chihuahua("Spike", c1));                             // NON_COMPLIANT
  Dog d4 = c1;                                                // NON_COMPLIANT

  f(d1);      // COMPLIANT
  f(c1);      // NON_COMPLIANT
  f_ptr(&c1); // COMPLIANT
  f_ref(c1);  // COMPLIANT
}