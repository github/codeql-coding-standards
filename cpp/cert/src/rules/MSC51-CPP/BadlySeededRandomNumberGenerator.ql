/**
 * @id cpp/cert/badly-seeded-random-number-generator
 * @name MSC51-CPP: Ensure your random number generator is properly seeded
 * @description Poorly seeded random number generators can lead to predicatable sequences of random
 *              numbers being generated.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc51-cpp
 *       security
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.standardlibrary.Random
import semmle.code.cpp.dataflow.TaintTracking

from RandomNumberEngineCreation createRandomNumberEngine, string seedSource
where
  not isExcluded(createRandomNumberEngine.getExclusionElement(),
    InitializationPackage::badlySeededRandomNumberGeneratorQuery()) and
  (
    // Default initialized
    createRandomNumberEngine.getNumberOfArguments() = 0 and
    seedSource = "default-initialized"
    or
    // Explicitly initialized, but to a constant
    seedSource =
      "is initialized to the constant value " +
        createRandomNumberEngine.getSeedArgument().getValue()
    or
    // Initialized from a poor source of randomness
    exists(Call c |
      c.getTarget().hasGlobalOrStdName("time") and
      TaintTracking::localExprTaint(c, createRandomNumberEngine.getSeedArgument()) and
      seedSource = "initialized from std::time"
    )
  )
select createRandomNumberEngine,
  "Random number generator " +
    createRandomNumberEngine.getCreatedRandomNumberEngine().getSimpleName() + " is " + seedSource +
    " and is therefore not properly seeded."
