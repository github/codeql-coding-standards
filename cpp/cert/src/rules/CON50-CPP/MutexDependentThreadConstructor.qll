import cpp
import codingstandards.cpp.Concurrency

/**
 * Models a call to a `std::thread` constructor that depends on a mutex.
 */
class MutexDependentThreadConstructor extends ThreadConstructorCall {
  Expr mutexExpr;

  MutexDependentThreadConstructor() {
    mutexExpr = getAnArgument() and
    mutexExpr.getUnderlyingType().stripType() instanceof MutexType
  }

  Expr dependentMutex() { result = mutexExpr }
}
