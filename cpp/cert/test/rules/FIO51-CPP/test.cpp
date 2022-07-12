#include <exception>
#include <fstream>

void test_terminate() {
  std::fstream file("file");
  std::terminate(); // NON_COMPLIANT
}

void test_closed() {
  std::fstream file("file");
  if (!file.is_open()) {
    return;
  }
  file.close();
  if (file.fail()) {
  }
  std::terminate(); // COMPLIANT
}

void test_fail() {
  {
    std::fstream file("file");
    if (!file.is_open()) {
      return;
    }
    file.close();
    if (file.fail()) {
    }
  }
  std::terminate(); // COMPLIANT
}

void test_scope() {
  std::fstream file;
  {
    file.open("file");
    if (!file.is_open()) {
      return;
    }
    file.close();
    if (file.fail()) {
    }
  }
  std::terminate(); // COMPLIANT
}

void test_sequence() {
  std::fstream file;
  {
    file.open("file");
    if (!file.is_open()) {
      return;
    }
    file.close();
    if (file.fail()) {
    }

    file.open("file");
    if (!file.is_open()) {
      return;
    }
  }
  std::terminate(); // NON_COMPLIANT
}

// file2 not closed
void test_2files() {
  std::fstream file1("file");
  std::fstream file2("file1");
  file2 << "some data";
  if (!file1.is_open()) {
    return;
  }
  file1.close();
  if (file2.fail()) {
  }
  std::terminate(); // NON_COMPLIANT
}

// test istream and ostream inherited functions
void test_stream_functions(int rand) {
  std::fstream file("file");
  int len = 10;
  char buff[len];
  file.close();
  file.is_open();
  if (rand)
    std::terminate(); // COMPLIANT
  file >> buff;
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.gcount();
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.get();
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.getline(buff, len);
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.ignore();
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.peek();
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.read(buff, len);
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.readsome(buff, len);
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.putback('a');
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.unget();
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.tellg();
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.seekg(0);
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.sync();
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file << "some data";
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.put('a');
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.write(buff, len);
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.tellp();
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.seekp(0);
  if (rand)
    std::terminate(); // NON_COMPLIANT
  file.flush();
  if (rand)
    std::terminate(); // NON_COMPLIANT
}
