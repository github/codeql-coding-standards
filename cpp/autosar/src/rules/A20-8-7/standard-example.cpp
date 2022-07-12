// $Id: A20-8-7.cpp 308795 2018-02-23 09:27:03Z michal.szczepankiewicz $
#include <memory>
template <template <typename> class T, typename U> 
struct Base
{
  T<U> sp;
};

template <typename T>
using Shared = Base<std::shared_ptr, T>;

template <typename T>
using Weak = Base<std::weak_ptr, T>;

struct SBarSFoo;
struct SFooSBar : public Shared<SBarSFoo> {};
struct SBarSFoo : public Shared<SFooSBar> {};

struct A : public Shared<A> {};

struct WBarSFoo;
struct SFooWBar : public Shared<WBarSFoo> {};
struct WBarSFoo : public Weak<SFooWBar> {};

int main()
{
  std::shared_ptr<SFooSBar> f = std::make_shared<SFooSBar>(); 
  std::shared_ptr<SBarSFoo> b = std::make_shared<SBarSFoo>(); 
  f->sp = b;
  b->sp = f;
  //non-compliant, both f and b have ref_count() == 2
  //destructors of f and b reduce ref_count() to 1,
  //destructors of underlying objects are never called,
  //so destructors of shared_ptrs sp are not called
  //and memory is leaked

  std::shared_ptr<A> a = std::make_shared<A>();
  a->sp = a;
  //non-compliant, object ’a’ destructor does not call
  //underlying memory destructor

  std::shared_ptr<SFooWBar> f2 = std::make_shared<SFooWBar>(); 
  std::shared_ptr<WBarSFoo> b2 = std::make_shared<WBarSFoo>(); 
  f2->sp = b2;
  b2->sp = f2;
  //compliant, b2->sp holds weak_ptr to f2, so f2 destructor 
  //is able to properly destroy underlying object

  return 0;
}
