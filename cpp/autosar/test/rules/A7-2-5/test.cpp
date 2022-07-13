enum class Color { // Flagged for audit to confirm related constants
  Green,
  Red,
  Blue
};

enum FooBars { // Flagged for audit to confirm related constants
  Car,
  Tree,
  July
};

enum class RelatedEnum { // Flagged for audit to confirm related constants
  Constant1 = 1,
  Constant2 = 0xFF
};

enum RelatedEnum2 { // Flagged for audit to confirm related constants
  Enum2Constant1 = 1,
  Enum2Constant2 = 0xFF
};

const int constant_one = 1;
const int constant_two = 0xFF;

constexpr int constexpr_constant_one = 1;
constexpr int constexpr_constant_two = 0xFF;

void test_switch() {
  int value;       // int could be replaced with enum
  switch (value) { // NON_COMPLIANT
  case constant_one:
  case constant_two:
  default:;
  }

  int value1;      // int could be replaced with enum
  switch (value) { // NON_COMPLIANT
  case constexpr_constant_one:
  case constexpr_constant_two:
  default:;
  }

  RelatedEnum value2;
  switch (value2) { // COMPLIANT
  case RelatedEnum::Constant1:
  case RelatedEnum::Constant2:
  default:;
  }

  RelatedEnum2 value3;
  switch (value3) { // COMPLIANT
  case Enum2Constant1:
  case Enum2Constant2:
  default:;
  }
}
