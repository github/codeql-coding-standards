typedef int MYINT;

/**
 * @HardwareOrProtocolInterface
 */
class HW_A {};

/**
 * @HardwareOrProtocolInterface
 */
class HW_A1 : HW_A {
public:
  int a1;
  int a2;
};

/**
 * @HardwareOrProtocolInterface
 */
class HW_A2 : HW_A {
public:
  int a1 : 2; // NON_COMPLIANT
  int a2;
};

/**
 * @HardwareOrProtocolInterface
 */
class HW_B {};

class B {};

/**
 * @HardwareOrProtocolInterface
 */
class HW_B1 : HW_B {
public:
  int a;
};

/**
 * @HardwareOrProtocolInterface
 */
class HW_B2 : HW_B {
public:
  int a1;
  MYINT a2 : 2; // NON_COMPLIANT

  char b1;
  char c1 : 2; // NON_COMPLIANT
};

class B2 : B {
public:
  int a;
  char b;
  char c : 2; // NON_COMPLIANT
};
