/**
 * @id c/cert/thread-was-previously-joined-or-detached
 * @name CON39-C: Do not join or detach a thread that was previously joined or detached
 * @description Joining or detaching a previously joined or detached thread can lead to undefined
 *              program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con39-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert



/**
 * Strategy for this one is to ensure that there are not two sinks to thrd_join
   or thrd_detach for a given 


   Truth table:

   Error if:

   thread calls detach, parent calls join
   thread calls 

   Make sure there aren't multiple calls to join? Very had to do in practice. 

   You should call join OR detach, but not both. 
 */

from
where
  not isExcluded(x, Concurrency5Package::threadWasPreviouslyJoinedOrDetachedQuery()) and
select
