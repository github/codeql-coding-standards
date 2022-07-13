/**
 * @id c/cert/properly-seed-pseudorandom-number-generators
 * @name MSC32-C: Properly seed pseudorandom number generators
 * @description Improperly seeded random number generators can lead to insecure code.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc32-c
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/** Defines a class that models function calls to srandom() */
class SRandomCall extends FunctionCall {
  SRandomCall(){
    getTarget().hasGlobalOrStdName("srandom")
  }

  /** Holds if the call is not obviously trivial. */
  predicate isTrivial(){
    getArgument(0) instanceof Literal
  }
}

from FunctionCall fc
where
  not isExcluded(fc, MiscPackage::properlySeedPseudorandomNumberGeneratorsQuery()) and
  
  // find all calls to random() 
  fc.getTarget().hasGlobalOrStdName("random") and 

  // where there isn't a call to srandom that comes before it that is
  // non-trivial
  not exists(SRandomCall sr |
    // normally we would want to do this in reverse --- but srandom() is 
    // not pure and the order does not matter. 
    sr.getASuccessor*() = fc and not sr.isTrivial()
  )


select fc, "Call to `random()` without a valid call to `srandom()`."
