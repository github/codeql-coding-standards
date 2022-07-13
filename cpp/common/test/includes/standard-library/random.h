#ifndef _GHLIBCPP_RANDOM
#define _GHLIBCPP_RANDOM
#include "cstdint.h"
#include "stddef.h"
#include "string.h"

namespace std {
template <class UIntType, UIntType a, UIntType c, UIntType m>
class linear_congruential_engine {
public:
  typedef UIntType result_type;
  static constexpr result_type default_seed = 1u;
  explicit linear_congruential_engine(result_type s = default_seed);
  template <class Sseq> explicit linear_congruential_engine(Sseq &q);
  void seed(result_type s = default_seed);
  template <class Sseq> void seed(Sseq &q);
  result_type operator()();
};
template <class UIntType, size_t w, size_t n, size_t m, size_t r, UIntType a,
          size_t u, UIntType d, size_t s, UIntType b, size_t t, UIntType c,
          size_t l, UIntType f>
class mersenne_twister_engine {
public:
  typedef UIntType result_type;
  static constexpr result_type default_seed = 5489u;
  explicit mersenne_twister_engine(result_type value = default_seed);
  template <class Sseq> explicit mersenne_twister_engine(Sseq &q);
  void seed(result_type value = default_seed);
  template <class Sseq> void seed(Sseq &q);
  result_type operator()();
};
template <class UIntType, size_t w, size_t s, size_t r>
class subtract_with_carry_engine {
public:
  typedef UIntType result_type;
  static constexpr result_type default_seed = 19780503u;
  explicit subtract_with_carry_engine(result_type value = default_seed);
  template <class Sseq> explicit subtract_with_carry_engine(Sseq &q);
  void seed(result_type value = default_seed);
  template <class Sseq> void seed(Sseq &q);
  result_type operator()();
};
template <class Engine, size_t p, size_t r> class discard_block_engine {
public:
  typedef typename Engine::result_type result_type;
  discard_block_engine();
  explicit discard_block_engine(const Engine &e);
  explicit discard_block_engine(Engine &&e);
  explicit discard_block_engine(result_type s);
  template <class Sseq> explicit discard_block_engine(Sseq &q);
  void seed();
  void seed(result_type s);
  template <class Sseq> void seed(Sseq &q);
  result_type operator()();
};
template <class Engine, size_t w, class UIntType>
class independent_bits_engine {
public:
  typedef UIntType result_type;
  independent_bits_engine();
  explicit independent_bits_engine(const Engine &e);
  explicit independent_bits_engine(Engine &&e);
  explicit independent_bits_engine(result_type s);
  template <class Sseq> explicit independent_bits_engine(Sseq &q);
  void seed();
  void seed(result_type s);
  template <class Sseq> void seed(Sseq &q);
  result_type operator()();
};
template <class Engine, size_t k> class shuffle_order_engine {
public:
  typedef typename Engine::result_type result_type;
  shuffle_order_engine();
  explicit shuffle_order_engine(const Engine &e);
  explicit shuffle_order_engine(Engine &&e);
  explicit shuffle_order_engine(result_type s);
  template <class Sseq> explicit shuffle_order_engine(Sseq &q);
  void seed();
  void seed(result_type s);
  template <class Sseq> void seed(Sseq &q);
  result_type operator()();
};

typedef linear_congruential_engine<uint_fast32_t, 16807, 0, 2147483647>
    minstd_rand0;
typedef linear_congruential_engine<uint_fast32_t, 48271, 0, 2147483647>
    minstd_rand;
typedef mersenne_twister_engine<uint_fast32_t, 32, 624, 397, 31, 0x9908b0df, 11,
                                0xffffffff, 7, 0x9d2c5680, 15, 0xefc60000, 18,
                                1812433253>
    mt19937;
typedef mersenne_twister_engine<
    uint_fast64_t, 64, 312, 156, 31, 0xb5026f5aa96619e9, 29, 0x5555555555555555,
    17, 0x71d67fffeda60000, 37, 0xfff7eee000000000, 43, 6364136223846793005>
    mt19937_64;
typedef subtract_with_carry_engine<uint_fast32_t, 24, 10, 24> ranlux24_base;
typedef subtract_with_carry_engine<uint_fast64_t, 48, 5, 12> ranlux48_base;
typedef discard_block_engine<ranlux24_base, 223, 23> ranlux24;
typedef discard_block_engine<ranlux48_base, 389, 11> ranlux48;
typedef shuffle_order_engine<minstd_rand0, 256> knuth_b;
typedef minstd_rand0 default_random_engine;

class random_device {
public:
  typedef unsigned int result_type;
  // constructors
  random_device();
  explicit random_device(const std::string &__token);
  result_type operator()();
  // no copy functions
  random_device(const random_device &) = delete;
  void operator=(const random_device &) = delete;
};
} // namespace std

#endif // _GHLIBCPP_RANDOM