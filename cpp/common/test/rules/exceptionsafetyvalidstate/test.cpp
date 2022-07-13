#include <cstdint>
#include <fstream>
#include <memory>
#include <mutex>
#include <stdexcept>

extern int rand();
void FVeryBad() noexcept(false) {
  int *x = new int(0);
  if (rand() < 10) {
    throw std::runtime_error("error"); // NON_COMPLIANT
    *x = 1;
  }
  delete x;
}
void test_catch() noexcept(false) {
  int *x = new int(0);
  try {
    if (rand() < 10) {
      throw std::runtime_error("error"); // COMPLIANT
    }
  } catch (...) {
    // swallow this exception
  }
  delete x;
}

void FBad() noexcept(false) {
  int *x = new int(0);
  if (rand() < 10) {
    throw std::runtime_error("error"); // NON_COMPLIANT
  } else if (rand() < 20) {
    throw std::runtime_error("error"); // NON_COMPLIANT
  }
  delete x;
}
void test_2alloc() noexcept(false) {
  int *x = new int(0);
  int *y = new int(0);
  if (rand() < 10) {
    delete x;
    throw std::runtime_error("error"); // NON_COMPLIANT
  } else if (rand() < 20) {
    delete y;
    throw std::runtime_error("error"); // NON_COMPLIANT
  }
  delete y;
  delete x;
}

void FGood() noexcept(false) {
  int *y = new int(0);
  if (rand() < 10) {
    delete y;
    throw std::runtime_error("error"); // COMPLIANT
  } else if (rand() < 30) {
    delete y;
    throw std::runtime_error("Invalid Argument 1"); // COMPLIANT
  }
  delete y;
}
void FBest() noexcept(false) {
  std::unique_ptr<int> z = std::make_unique<int>(0);
  if (rand() < 10) {
    throw std::runtime_error("error"); // COMPLIANT
  } else if (rand() < 20) {
    throw std::runtime_error("error"); // COMPLIANT
  } else if (rand() < 30) {
    throw std::runtime_error("error"); // COMPLIANT
  }
}
class CRaii {
public:
  CRaii(int *pointer) noexcept : x(pointer) {}
  ~CRaii() {
    delete x;
    x = nullptr;
  }

private:
  int *x;
};
void FBest2() noexcept(false) {
  CRaii a1(new int(10));
  if (rand() < 10) {
    throw std::runtime_error("error"); // COMPLIANT
  } else if (rand() < 20) {
    throw std::runtime_error("error"); // COMPLIANT
  }
}

void may_throw() noexcept(false) {
  if (rand() < 10) {
    throw std::runtime_error("error");
  }
}

void f_rethrow() {
  int *x = new int(0);
  try {
    may_throw();
  } catch (...) {
    throw; // NON_COMPLIANT
  }
  delete x;
}

void f_rethrow_ok() {
  int *x = new int(0);
  try {
    may_throw();
  } catch (...) {
    delete x;
    throw; // COMPLIANT
  }
  delete x;
}

class TestField {
  int *x;

public:
  TestField() {
    x = new int(0);
    throw std::runtime_error("error"); // NON_COMPLIANT
  }
};

class TestFieldInit {
  int *x;

public:
  TestFieldInit() : x(new int(0)) {
    throw std::runtime_error("error"); // NON_COMPLIANT
  }
};

// file open close
std::fstream fs;
void test_fstream() {
  fs.open("test");
  throw std::runtime_error("error"); // NON_COMPLIANT
  fs.close();
}
std::fstream fs_ok;
void test_fstream_ok() {
  fs_ok.open("test");
  fs_ok.close();
  throw std::runtime_error("error"); // COMPLIANT
}
void test_fstream2() {
  fs.open("test");
  fs_ok.close();
  throw std::runtime_error("error"); // NON_COMPLIANT
}

std::mutex mtx;
void test_mutex() {
  mtx.lock();
  throw std::runtime_error("error"); // NON_COMPLIANT
  mtx.unlock();
}
std::mutex mtx_ok;
void test_mutex_ok() {
  mtx_ok.lock();
  mtx_ok.unlock();
  throw std::runtime_error("error"); // COMPLIANT
}
void test_mutex2() {
  mtx.lock();
  mtx_ok.unlock();
  throw std::runtime_error("error"); // NON_COMPLIANT
}
