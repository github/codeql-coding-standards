#include <any>
#include <array>
#include <bitset>
#include <cstdlib>
#include <deque>
#include <filesystem>
#include <forward_list>
#include <fstream>
#include <functional>
#include <future>
#include <list>
#include <locale>
#include <map>
#include <memory>
#include <new>
#include <optional>
#include <queue>
#include <regex>
#include <set>
#include <sstream>
#include <stack>
#include <string>
#include <string_view>
#include <thread>
#include <tuple>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <valarray>
#include <variant>
#include <vector>

void test_new_delete() {
  int *p1 = new int;     // NON_COMPLIANT: operator new
  int *p2 = new int(42); // NON_COMPLIANT: operator new
  int *p3 = new int[10]; // NON_COMPLIANT: operator new[]

  delete p1;   // NON_COMPLIANT: operator delete
  delete p2;   // NON_COMPLIANT: operator delete
  delete[] p3; // NON_COMPLIANT: operator delete[]
}

void test_placement_new() {
  struct Trivial {
    int value;
  };
  alignas(Trivial) char buffer[sizeof(Trivial)];
  Trivial *p = new (&buffer[0]) Trivial{
      42}; // COMPLIANT: placement new uses provided storage, no heap allocation
  p->~Trivial();
}

void test_c_allocation_std_namespace() {
  void *p1 = std::malloc(100);             // NON_COMPLIANT: malloc
  void *p2 = std::calloc(10, sizeof(int)); // NON_COMPLIANT: calloc
  void *p3 = std::realloc(p1, 200);        // NON_COMPLIANT: realloc
  void *p4 = std::aligned_alloc(16, 64);   // NON_COMPLIANT: aligned_alloc

  std::free(p3); // NON_COMPLIANT: free
  std::free(p2); // NON_COMPLIANT: free
  std::free(p4); // NON_COMPLIANT: free
}

void test_c_allocation_global_namespace() {
  void *p1 = malloc(100);             // NON_COMPLIANT: malloc
  void *p2 = calloc(10, sizeof(int)); // NON_COMPLIANT: calloc
  void *p3 = realloc(p1, 200);        // NON_COMPLIANT: realloc
  void *p4 = aligned_alloc(16, 64);   // NON_COMPLIANT: aligned_alloc

  free(p3); // NON_COMPLIANT: free
  free(p2); // NON_COMPLIANT: free
  free(p4); // NON_COMPLIANT: free
}

void test_smart_pointer_factories() {
  auto p1 = std::make_unique<int>(42);   // NON_COMPLIANT: calls operator new
  auto p2 = std::make_unique<int[]>(10); // NON_COMPLIANT: calls operator new
  auto p3 = std::make_shared<int>(
      42); // NON_COMPLIANT: allocates object + control block

  std::allocator<int> alloc;
  auto p4 = std::allocate_shared<int>(
      alloc, 42); // NON_COMPLIANT: allocates via allocator
}

void test_smart_pointer_constructors() {
  std::unique_ptr<int> p1(new int(42)); // NON_COMPLIANT: operator new
  std::shared_ptr<int> p2(new int(42)); // NON_COMPLIANT: operator new
  std::weak_ptr<int> p3 =
      p2; // COMPLIANT: references existing control block, no new allocation
}

void test_sequence_containers() {
  std::vector<int> v1;          // NON_COMPLIANT: uses std::allocator
  std::vector<int> v2{1, 2, 3}; // NON_COMPLIANT: uses std::allocator
  std::vector<int> v3(10);      // NON_COMPLIANT: uses std::allocator
  std::vector<int> v4(10, 42);  // NON_COMPLIANT: uses std::allocator

  std::deque<int> d1;          // NON_COMPLIANT: uses std::allocator
  std::deque<int> d2{1, 2, 3}; // NON_COMPLIANT: uses std::allocator

  std::list<int> l1;          // NON_COMPLIANT: uses std::allocator
  std::list<int> l2{1, 2, 3}; // NON_COMPLIANT: uses std::allocator

  std::forward_list<int> fl1;          // NON_COMPLIANT: uses std::allocator
  std::forward_list<int> fl2{1, 2, 3}; // NON_COMPLIANT: uses std::allocator
}

void test_associative_containers() {
  std::set<int> s1;          // NON_COMPLIANT: uses std::allocator
  std::set<int> s2{1, 2, 3}; // NON_COMPLIANT: uses std::allocator

  std::map<int, int> m1;                 // NON_COMPLIANT: uses std::allocator
  std::map<int, int> m2{{1, 2}, {3, 4}}; // NON_COMPLIANT: uses std::allocator

  std::multiset<int> ms1;          // NON_COMPLIANT: uses std::allocator
  std::multiset<int> ms2{1, 1, 2}; // NON_COMPLIANT: uses std::allocator

  std::multimap<int, int> mm1;         // NON_COMPLIANT: uses std::allocator
  std::multimap<int, int> mm2{{1, 2}}; // NON_COMPLIANT: uses std::allocator
}

void test_unordered_containers() {
  std::unordered_set<int> us1;          // NON_COMPLIANT: uses std::allocator
  std::unordered_set<int> us2{1, 2, 3}; // NON_COMPLIANT: uses std::allocator

  std::unordered_map<int, int> um1; // NON_COMPLIANT: uses std::allocator
  std::unordered_map<int, int> um2{
      {1, 2}, {3, 4}}; // NON_COMPLIANT: uses std::allocator

  std::unordered_multiset<int> ums1; // NON_COMPLIANT: uses std::allocator
  std::unordered_multiset<int> ums2{1, 1,
                                    2}; // NON_COMPLIANT: uses std::allocator

  std::unordered_multimap<int, int> umm1; // NON_COMPLIANT: uses std::allocator
  std::unordered_multimap<int, int> umm2{
      {1, 2}}; // NON_COMPLIANT: uses std::allocator
}

void test_valarray() {
  std::valarray<int> va1;     // NON_COMPLIANT: allocates for element storage
  std::valarray<int> va2(10); // NON_COMPLIANT: allocates for element storage
  std::valarray<int> va3{1, 2,
                         3}; // NON_COMPLIANT: allocates for element storage
}

void test_strings() {
  std::string s1;           // NON_COMPLIANT: uses std::allocator
  std::string s2 = "hello"; // NON_COMPLIANT: uses std::allocator
  std::string s3("hello");  // NON_COMPLIANT: uses std::allocator
  std::string s4(10, 'x');  // NON_COMPLIANT: uses std::allocator

  std::wstring ws1;            // NON_COMPLIANT: uses std::allocator
  std::wstring ws2 = L"hello"; // NON_COMPLIANT: uses std::allocator

  std::u16string u16s1;            // NON_COMPLIANT: uses std::allocator
  std::u16string u16s2 = u"hello"; // NON_COMPLIANT: uses std::allocator

  std::u32string u32s1;            // NON_COMPLIANT: uses std::allocator
  std::u32string u32s2 = U"hello"; // NON_COMPLIANT: uses std::allocator
}

void test_container_adaptors() {
  std::stack<int> st1; // NON_COMPLIANT: contains std::deque

  std::queue<int> q1; // NON_COMPLIANT: contains std::deque

  std::priority_queue<int> pq1; // NON_COMPLIANT: contains std::vector
}

void test_string_streams() {
  std::stringstream ss1;          // NON_COMPLIANT: contains std::string
  std::stringstream ss2("hello"); // NON_COMPLIANT: contains std::string

  std::istringstream iss1;          // NON_COMPLIANT: contains std::string
  std::istringstream iss2("hello"); // NON_COMPLIANT: contains std::string

  std::ostringstream oss1; // NON_COMPLIANT: contains std::string

  std::wstringstream wss1;   // NON_COMPLIANT: contains std::wstring
  std::wistringstream wiss1; // NON_COMPLIANT: contains std::wstring
  std::wostringstream woss1; // NON_COMPLIANT: contains std::wstring
}

void test_file_streams() {
  std::fstream fs1;             // NON_COMPLIANT: allocates internal buffer
  std::fstream fs2("file.txt"); // NON_COMPLIANT: allocates internal buffer

  std::ifstream ifs1;             // NON_COMPLIANT: allocates internal buffer
  std::ifstream ifs2("file.txt"); // NON_COMPLIANT: allocates internal buffer

  std::ofstream ofs1;             // NON_COMPLIANT: allocates internal buffer
  std::ofstream ofs2("file.txt"); // NON_COMPLIANT: allocates internal buffer

  std::wfstream wfs1;   // NON_COMPLIANT: allocates internal buffer
  std::wifstream wifs1; // NON_COMPLIANT: allocates internal buffer
  std::wofstream wofs1; // NON_COMPLIANT: allocates internal buffer
}

void test_regex() {
  std::regex r1;            // NON_COMPLIANT: allocates compiled pattern
  std::regex r2("pattern"); // NON_COMPLIANT: allocates compiled pattern
  std::regex r3("[a-z]+");  // NON_COMPLIANT: allocates compiled pattern

  std::wregex wr1;             // NON_COMPLIANT: allocates compiled pattern
  std::wregex wr2(L"pattern"); // NON_COMPLIANT: allocates compiled pattern
}

void test_function() {
  std::function<void()> f1; // NON_COMPLIANT: may allocate via type erasure
  std::function<void()> f2 = []() {
  }; // NON_COMPLIANT: may allocate via type erasure
  std::function<int(int)> f3 = [](int x) {
    return x;
  }; // NON_COMPLIANT: may allocate via type erasure

  int a, b, c, d, e, f, g, h;
  std::function<void()> f4 =
      [=]() { // NON_COMPLIANT: may allocate via type erasure
        (void)(a + b + c + d + e + f + g + h);
      };
}

void test_any() {
  std::any a1;      // NON_COMPLIANT: may allocate via type erasure
  std::any a2 = 42; // NON_COMPLIANT: may allocate via type erasure
  std::any a3 =
      std::string("hello"); // NON_COMPLIANT: may allocate via type erasure

  struct Large {
    char data[1000];
  };
  std::any a4 = Large{}; // NON_COMPLIANT: may allocate via type erasure
}

void test_promise_future() {
  std::promise<int> p1; // NON_COMPLIANT: allocates shared state
  std::future<int> f1 =
      p1.get_future(); // NON_COMPLIANT: references allocated shared state

  std::promise<void> p2; // NON_COMPLIANT: allocates shared state
  std::shared_future<int> sf1 =
      std::promise<int>{}.get_future(); // NON_COMPLIANT: allocates shared state

  std::packaged_task<int()> pt1(
      [] { return 42; }); // NON_COMPLIANT: allocates shared state
}

void test_locale() {
  std::locale loc1;      // NON_COMPLIANT: allocates facet storage
  std::locale loc2("C"); // NON_COMPLIANT: allocates facet storage
  std::locale loc3 =
      std::locale::classic(); // NON_COMPLIANT: allocates facet storage
}

void test_thread() {
  std::thread t1([]() {}); // NON_COMPLIANT: allocates callable storage
  t1.join();

  int x = 42;
  std::thread t2(
      [x]() { (void)x; }); // NON_COMPLIANT: allocates callable storage
  t2.join();
}

void test_async() {
  auto f1 = std::async(
      [] { return 42; }); // NON_COMPLIANT: allocates callable + shared state
  auto f2 = std::async(std::launch::async, [] {
    return 42;
  }); // NON_COMPLIANT: allocates callable + shared state
  auto f3 = std::async(std::launch::deferred, [] {
    return 42;
  }); // NON_COMPLIANT: allocates callable + shared state
}

void test_filesystem() {
  std::filesystem::path p1;              // NON_COMPLIANT: contains string
  std::filesystem::path p2 = "/usr/bin"; // NON_COMPLIANT: contains string
  std::filesystem::path p3("file.txt");  // NON_COMPLIANT: contains string
  std::filesystem::path p4 = p3 / "sub"; // NON_COMPLIANT: contains string
}

void test_containers_with_explicit_allocator() {
  std::vector<int, std::allocator<int>>
      v1; // NON_COMPLIANT: explicit std::allocator template argument
  std::deque<int, std::allocator<int>>
      d1; // NON_COMPLIANT: explicit std::allocator template argument
  std::list<int, std::allocator<int>>
      l1; // NON_COMPLIANT: explicit std::allocator template argument
  std::forward_list<int, std::allocator<int>>
      fl1; // NON_COMPLIANT: explicit std::allocator template argument
}

void test_compliant_views() {
  std::string_view sv =
      "hello"; // COMPLIANT: non-owning view, just pointer + size, no allocation
}

void test_compliant_stack_allocated() {
  std::array<int, 10> arr; // COMPLIANT: fixed-size, elements embedded directly
                           // in object, no allocator
  std::bitset<64>
      bs; // COMPLIANT: fixed-size, bits stored internally, no heap allocation
}

void test_compliant_internal_storage() {
  std::optional<int>
      opt1; // COMPLIANT: uses aligned internal buffer, no heap allocation
  std::optional<int> opt2{
      42}; // COMPLIANT: uses aligned internal buffer, no heap allocation

  std::variant<int, double> var1; // COMPLIANT: uses internal buffer sized to
                                  // largest alternative, no heap
  std::variant<int, double> var2 =
      3.14; // COMPLIANT: uses internal buffer sized to largest alternative, no
            // heap

  std::pair<int, int> pair1; // COMPLIANT: simple aggregate, members stored
                             // directly, no allocation
  std::pair<int, int> pair2{
      1,
      2}; // COMPLIANT: simple aggregate, members stored directly, no allocation

  std::tuple<int, double>
      tup1; // COMPLIANT: members stored directly in object, no allocation
  std::tuple<int, double> tup2{
      1, 2.0}; // COMPLIANT: members stored directly in object, no allocation
}

void test_compliant_reference_wrapper() {
  int x = 42;
  std::reference_wrapper<int> ref =
      x; // COMPLIANT: just wraps a pointer, no ownership, no allocation
}

void test_compliant_iterators() {
  std::array<int, 3> a{1, 2, 3};
  auto it = a.begin(); // COMPLIANT: iterator is typically a pointer or small
                       // object, no allocation
}

void test_compliant_pointers() {
  int x = 42;
  int *p = &x; // COMPLIANT: raw pointer to stack variable, no heap involved

  static int y = 42;
  int *q = &y; // COMPLIANT: raw pointer to static storage, no heap involved
}

int main() { return 0; }
