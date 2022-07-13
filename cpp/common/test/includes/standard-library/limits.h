#include <cfloat>

#define CHAR_BIT 8
#define SCHAR_MIN -128
#define SCHAR_MAX 127
#define UCHAR_MIN 0x00
#define UCHAR_MAX 0xff
#define CHAR_MIN -128
#define CHAR_MAX 127
#define SHRT_MIN -32768
#define SHRT_MAX 32767
#define USHRT_MIN 0x0000
#define USHRT_MAX 0xffff
#define INT_MIN (-2147483647 - 1)
#define INT_MAX 2147483647
#define UINT_MIN 0U
#define UINT_MAX 0xffffffff
#define LONG_MIN (-2147483647 - 1)
#define LONG_MAX 2147483647
#define ULONG_MIN 0UL
#define ULONG_MAX 0xffffffff
#define LLONG_MIN (-9223372036854775807 - 1)
#define LLONG_MAX 9223372036854775807
#define ULLONG_MIN 0ULL
#define ULLONG_MAX 0xffffffffffffffff

namespace std {
template <class T> class numeric_limits;

template <> class numeric_limits<signed char> {
public:
  static constexpr signed char min() { return SCHAR_MIN; }
  static constexpr signed char max() { return SCHAR_MAX; }
};

template <> class numeric_limits<unsigned char> {
public:
  static constexpr unsigned char min() { return 0; }
  static constexpr unsigned char max() { return UCHAR_MAX; }
};

template <> class numeric_limits<signed short> {
public:
  static constexpr signed short min() { return SHRT_MIN; }
  static constexpr signed short max() { return SHRT_MAX; }
};

template <> class numeric_limits<unsigned short> {
public:
  static constexpr unsigned short min() { return USHRT_MIN; }
  static constexpr unsigned short max() { return USHRT_MAX; }
};

template <> class numeric_limits<signed int> {
public:
  static constexpr signed int min() { return INT_MIN; }
  static constexpr signed int max() { return INT_MAX; }
};

template <> class numeric_limits<unsigned int> {
public:
  static constexpr unsigned int min() { return UINT_MIN; }
  static constexpr unsigned int max() { return UINT_MAX; }
};

template <> class numeric_limits<signed long> {
public:
  static constexpr signed long min() { return LONG_MIN; }
  static constexpr signed long max() { return LONG_MAX; }
};

template <> class numeric_limits<unsigned long> {
public:
  static constexpr unsigned long min() { return ULONG_MIN; }
  static constexpr unsigned long max() { return ULONG_MAX; }
};

template <> class numeric_limits<signed long long> {
public:
  static constexpr signed long long min() { return LLONG_MIN; }
  static constexpr signed long long max() { return LLONG_MAX; }
};

template <> class numeric_limits<unsigned long long> {
public:
  static constexpr unsigned long long min() { return ULLONG_MIN; }
  static constexpr unsigned long long max() { return ULLONG_MAX; }
};

template <> class numeric_limits<float> {
public:
  static constexpr bool is_iec559 = false; // NON_COMPLIANT
  static constexpr int digits = FLT_DIG;
};

template <> class numeric_limits<double> {
public:
  static constexpr bool is_iec559 = true;
  static constexpr int digits = DBL_DIG;
};

template <> class numeric_limits<long double> {
public:
  static constexpr bool is_iec559 = true;
};
} // namespace std