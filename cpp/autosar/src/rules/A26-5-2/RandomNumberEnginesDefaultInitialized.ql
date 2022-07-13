/**
 * @id cpp/autosar/random-number-engines-default-initialized
 * @name A26-5-2: Random number engines shall not be default-initialized
 * @description Default initializing a random number generator can lead to producing the same random
 *              sequence on every program run, which may be unexpected for the developer.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a26-5-2
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.standardlibrary.Random

from RandomNumberEngineCreation createRandomNumberEngine
where
  not isExcluded(createRandomNumberEngine.getExclusionElement(),
    InitializationPackage::randomNumberEnginesDefaultInitializedQuery()) and
  // Default initialized
  createRandomNumberEngine.getNumberOfArguments() = 0
select createRandomNumberEngine,
  "Random number generator " +
    createRandomNumberEngine.getCreatedRandomNumberEngine().getSimpleName() +
    " is default-initialized."
