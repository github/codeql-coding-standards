/**
 * @id c/cert/clean-up-thread-specific-storage
 * @name CON30-C: Clean up thread-specific storage
 * @description Failing to clean up thread-specific resources can lead to unpredictable program
 *              behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/con30-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

// there are two safe patterns. 
// 1) They call free(tss_get(key))
// 2) They call tss_create(key, destructor) -- we don't make an attempt to
//    understand what the function is. They must also call tss_delete(key)
// THAT MEANS there is dataflow from tss_create -> tss_delete 
// OR there is dataflow from tss_create -> tss_delete
// we just make sure in one arg version it's wrapped in a call to free. 
// That IS there is taint from tss_create -> free();

from Function f 
where
  not isExcluded(f, Concurrency4Package::cleanUpThreadSpecificStorageQuery())
  and nm
select mi.getExpr()