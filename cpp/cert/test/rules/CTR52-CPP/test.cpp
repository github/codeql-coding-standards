#include <algorithm>
#include <deque>
#include <iterator>
#include <vector>

void test_basic(std::vector<int> from) {
  std::vector<int> to;
  std::copy(from.begin(), from.end(), to.begin()); // NON_COMPLIANT
}

void test_basic_good(std::vector<int> &src) {
  std::vector<int> dest(src.size());
  std::copy(src.begin(), src.end(), dest.begin()); // COMPLIANT
}

void test_non_local_bad(std::vector<int> &src, std::vector<int> &dest) {
  std::copy(src.begin(), src.end(), dest.begin()); // NON_COMPLIANT
}

void test_non_local_good_range_check(std::vector<int> &src,
                                     std::vector<int> &dest) {
  if (dest.size() < src.size()) {
    return;
  }
  std::copy(src.begin(), src.end(), dest.begin()); // COMPLIANT
}

void test_non_local_good_range_check_two(std::vector<int> &src,
                                         std::vector<int> &dest) {
  if (dest.size() >= src.size()) {
    std::copy(src.begin(), src.end(), dest.begin()); // COMPLIANT
  }
}

void test_front_inserter(std::vector<int> &src) {
  std::deque<int> dest;
  std::copy(src.begin(), src.end(), std::front_inserter(dest)); // COMPLIANT
}

void test_back_inserter(std::vector<int> &src) {
  std::vector<int> dest;
  std::copy(src.begin(), src.end(),
            std::back_inserter(dest)); // COMPLIANT
}

void test_fixed_size_correct() {
  std::vector<int> dest(10);
  std::vector<int> src(10);
  std::copy(src.begin(), src.end(), dest.begin()); // COMPLIANT
}

void test_fixed_size_broken() {
  std::vector<int> dest(5);
  std::vector<int> src(10);
  std::copy(src.begin(), src.end(), dest.begin()); // NON_COMPLIANT
}

void test_apis(std::vector<int> &src, std::vector<int> &dest) {
  std::copy_n(src.begin(), 5, dest.begin()); // NON_COMPLIANT
  std::copy_if(src.begin(), src.end(), dest.begin(),
               [](int) { return false; });                  // NON_COMPLIANT
  std::copy_backward(src.begin(), src.end(), dest.begin()); // NON_COMPLIANT
  std::move(src.begin(), src.end(), dest.begin());          // NON_COMPLIANT
  std::move_backward(src.begin(), src.end(), dest.begin()); // NON_COMPLIANT
  std::transform(src.begin(), src.end(), dest.begin(),      // NON_COMPLIANT
                 [](int i) { return i; });
  std::transform(src.begin(), src.end(), src.end(),
                 dest.begin(), // NON_COMPLIANT
                 [](int i, int) { return i; });
  const int x = 0;
  const int y = 1;
  std::replace_copy(src.begin(), src.end(), dest.begin(), x, // NON_COMPLIANT
                    y);
  std::replace_copy_if(
      src.begin(), src.end(), dest.begin(), // NON_COMPLIANT
      [](auto) { return true; }, y);
  std::remove_copy(src.begin(), src.end(), dest.begin(), x); // NON_COMPLIANT
  std::remove_copy_if(src.begin(), src.end(), dest.begin(),  // NON_COMPLIANT
                      [](auto) { return true; });
  std::unique_copy(src.begin(), src.end(), dest.begin());  // NON_COMPLIANT
  std::reverse_copy(src.begin(), src.end(), dest.begin()); // NON_COMPLIANT
  std::partition_copy(src.begin(), src.end(), dest.begin(),
                      dest.begin(), // NON_COMPLIANT
                      [](auto) { return true; });
  std::partial_sort_copy(src.begin(), src.end(), dest.begin(), // NON_COMPLIANT
                         dest.end());
  std::partial_sort_copy(src.begin(), src.end(), dest.begin(), // NON_COMPLIANT
                         dest.end(), [](auto, auto) { return true; });
  std::rotate_copy(src.begin(), src.end(), src.end(),
                   dest.begin()); // NON_COMPLIANT
  std::merge(src.begin(), src.end(), src.begin(), src.end(),
             dest.begin()); // NON_COMPLIANT
  std::merge(src.begin(), src.end(), src.begin(), src.end(),
             dest.begin(), // NON_COMPLIANT
             [](auto, auto) { return true; });
  std::set_union(src.begin(), src.end(), src.begin(), src.end(),
                 dest.begin()); // NON_COMPLIANT
  std::set_union(src.begin(), src.end(), src.begin(), src.end(),
                 dest.begin(), // NON_COMPLIANT
                 [](auto, auto) { return true; });
  std::set_intersection(src.begin(), src.end(), src.begin(), src.end(),
                        dest.begin()); // NON_COMPLIANT
  std::set_intersection(src.begin(), src.end(), src.begin(), src.end(),
                        dest.begin(),
                        [](auto, auto) { return true; }); // NON_COMPLIANT
  std::set_difference(src.begin(), src.end(), src.begin(), src.end(),
                      dest.begin()); // NON_COMPLIANT
  std::set_difference(src.begin(), src.end(), src.begin(), src.end(),
                      dest.begin(),
                      [](auto, auto) { return true; }); // NON_COMPLIANT
  std::set_symmetric_difference(src.begin(), src.end(), src.begin(), src.end(),
                                dest.begin()); // NON_COMPLIANT
  std::set_symmetric_difference(
      src.begin(), src.end(), src.begin(), src.end(), dest.begin(),
      [](auto, auto) { return true; }); // NON_COMPLIANT
}