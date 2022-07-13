#include <memory>
#include <stdexcept>

class Member {};

class ClassA {
private:
  Member *member;
  ClassA() noexcept(false) { // NON_COMPLIANT - can exit with exception, without
                             // freeing member
    try {
      member = new Member();
      throw std::exception();
    } catch (std::exception &e) {
      throw;
    }
  }
};

class ClassB {
private:
  Member *member;
  ClassB() noexcept(false) { // COMPLIANT - memory is freed
    try {
      member = new Member();
      throw std::exception();
    } catch (std::exception &e) {
      delete member;
      throw;
    }
  }
};

Member *CreateMember() { return new Member(); }

void DeleteMember(Member *member) { delete member; }

class ClassC {
private:
  Member *member;
  ClassC() noexcept(false) { // NON_COMPLIANT - can exit with exception, without
                             // freeing member
    try {
      member = CreateMember();
      throw std::exception();
    } catch (std::exception &e) {
      throw;
    }
  }
};

class ClassD {
private:
  Member *member;
  ClassD() noexcept(false) { // NON_COMPLIANT - can exit with exception, without
                             // freeing member
    try {
      member = CreateMember();
      throw std::exception();
    } catch (std::exception &e) {
      DeleteMember(member);
      throw;
    }
  }
};

class ClassE {
private:
  int *m_1;
  int *m_2;
  int *m_3;
  int *m_4;
  int *m_5;

  ClassE() { // NON_COMPLIANT - can exit with exception, without
             // freeing member
    m_1 = new int(0);
    m_2 = new int(0);
    try {
      m_3 = new int(0);
      m_4 = new int(0);
    } catch (std::bad_alloc &e) {
      delete m_2;
      delete m_3;
      throw;
    }
    m_5 = new int(0);
  }
};