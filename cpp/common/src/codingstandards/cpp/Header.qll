/**
 * A module to reason about C++ Standard Library header files.
 */

import cpp

module Header {
  module Cpp14 {
    /** Holds if `s` is the name of a standard library header file as returned by `getIncludeText` */
    predicate hasStandardLibraryHeaderFileName(string s) {
      s in [
          "<algorithm>", "<allocators>", "<array>", "<atomic>", "<bitset>", "<cassert>",
          "<ccomplex>", "<cctype>", "<cerrno>", "<cfenv>", "<cfloat>", "<chrono>", "<cinttypes>",
          "<ciso646>", "<climits>", "<clocale>", "<cmath>", "<codecvt>", "<complex>",
          "<condition_variable>", "<csetjmp>", "<csignal>", "<cstdalign>", "<cstdarg>",
          "<cstdbool>", "<cstddef>", "<cstdint>", "<cstdio>", "<cstdlib>", "<cstring>", "<ctgmath>",
          "<ctime>", "<cuchar>", "<cvt/wbuffer>", "<cvt/wstring>", "<cwchar>", "<cwctype>",
          "<deque>", "<exception>", "<forward_list>", "<fstream>", "<functional>", "<future>",
          "<initializer_list>", "<iomanip>", "<ios>", "<iosfwd>", "<iostream>", "<istream>",
          "<iterator>", "<limits>", "<list>", "<locale>", "<map>", "<memory>", "<mutex>", "<new>",
          "<numeric>", "<ostream>", "<queue>", "<random>", "<ratio>", "<regex>",
          "<scoped_allocator>", "<set>", "<shared_mutex>", "<sstream>", "<stack>", "<stdexcept>",
          "<stdlib.h>", "<streambuf>", "<string>", "<strstream>", "<system_error>", "<thread>",
          "<tuple>", "<type_traits>", "<typeindex>", "<typeinfo>", "<unordered_map>",
          "<unordered_set>", "<utility>", "<valarray>", "<vector>"
        ]
    }
  }
}
