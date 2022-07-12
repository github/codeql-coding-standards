//** THIS FILE IS AUTOGENERATED, DO NOT MODIFY DIRECTLY.  */
import cpp
import RuleMetadata

newtype ConcurrencyQuery =
  TDoNotAllowAMutexToGoOutOfScopeWhileLockedQuery() or
  TDoNotDestroyAMutexWhileItIsLockedQuery() or
  TEnsureActivelyHeldLocksAreReleasedOnExceptionalConditionsQuery() or
  TPreventDataRacesWhenAccessingBitFieldsFromMultipleThreadsQuery() or
  TDeadlockByLockingInPredefinedOrderQuery() or
  TWrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery() or
  TPreserveThreadSafetyAndLivenessWhenUsingConditionVariablesQuery() or
  TDoNotSpeculativelyLockALockedNonRecursiveMutexQuery() or
  TLockedALockedNonRecursiveMutexAuditQuery()

predicate isConcurrencyQueryMetadata(Query query, string queryId, string ruleId) {
  query =
    // `Query` instance for the `doNotAllowAMutexToGoOutOfScopeWhileLocked` query
    ConcurrencyPackage::doNotAllowAMutexToGoOutOfScopeWhileLockedQuery() and
  queryId =
    // `@id` for the `doNotAllowAMutexToGoOutOfScopeWhileLocked` query
    "cpp/cert/do-not-allow-a-mutex-to-go-out-of-scope-while-locked" and
  ruleId = "CON50-CPP"
  or
  query =
    // `Query` instance for the `doNotDestroyAMutexWhileItIsLocked` query
    ConcurrencyPackage::doNotDestroyAMutexWhileItIsLockedQuery() and
  queryId =
    // `@id` for the `doNotDestroyAMutexWhileItIsLocked` query
    "cpp/cert/do-not-destroy-a-mutex-while-it-is-locked" and
  ruleId = "CON50-CPP"
  or
  query =
    // `Query` instance for the `ensureActivelyHeldLocksAreReleasedOnExceptionalConditions` query
    ConcurrencyPackage::ensureActivelyHeldLocksAreReleasedOnExceptionalConditionsQuery() and
  queryId =
    // `@id` for the `ensureActivelyHeldLocksAreReleasedOnExceptionalConditions` query
    "cpp/cert/ensure-actively-held-locks-are-released-on-exceptional-conditions" and
  ruleId = "CON51-CPP"
  or
  query =
    // `Query` instance for the `preventDataRacesWhenAccessingBitFieldsFromMultipleThreads` query
    ConcurrencyPackage::preventDataRacesWhenAccessingBitFieldsFromMultipleThreadsQuery() and
  queryId =
    // `@id` for the `preventDataRacesWhenAccessingBitFieldsFromMultipleThreads` query
    "cpp/cert/prevent-data-races-when-accessing-bit-fields-from-multiple-threads" and
  ruleId = "CON52-CPP"
  or
  query =
    // `Query` instance for the `deadlockByLockingInPredefinedOrder` query
    ConcurrencyPackage::deadlockByLockingInPredefinedOrderQuery() and
  queryId =
    // `@id` for the `deadlockByLockingInPredefinedOrder` query
    "cpp/cert/deadlock-by-locking-in-predefined-order" and
  ruleId = "CON53-CPP"
  or
  query =
    // `Query` instance for the `wrapFunctionsThatCanSpuriouslyWakeUpInLoop` query
    ConcurrencyPackage::wrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery() and
  queryId =
    // `@id` for the `wrapFunctionsThatCanSpuriouslyWakeUpInLoop` query
    "cpp/cert/wrap-functions-that-can-spuriously-wake-up-in-loop" and
  ruleId = "CON54-CPP"
  or
  query =
    // `Query` instance for the `preserveThreadSafetyAndLivenessWhenUsingConditionVariables` query
    ConcurrencyPackage::preserveThreadSafetyAndLivenessWhenUsingConditionVariablesQuery() and
  queryId =
    // `@id` for the `preserveThreadSafetyAndLivenessWhenUsingConditionVariables` query
    "cpp/cert/preserve-thread-safety-and-liveness-when-using-condition-variables" and
  ruleId = "CON55-CPP"
  or
  query =
    // `Query` instance for the `doNotSpeculativelyLockALockedNonRecursiveMutex` query
    ConcurrencyPackage::doNotSpeculativelyLockALockedNonRecursiveMutexQuery() and
  queryId =
    // `@id` for the `doNotSpeculativelyLockALockedNonRecursiveMutex` query
    "cpp/cert/do-not-speculatively-lock-a-locked-non-recursive-mutex" and
  ruleId = "CON56-CPP"
  or
  query =
    // `Query` instance for the `lockedALockedNonRecursiveMutexAudit` query
    ConcurrencyPackage::lockedALockedNonRecursiveMutexAuditQuery() and
  queryId =
    // `@id` for the `lockedALockedNonRecursiveMutexAudit` query
    "cpp/cert/locked-a-locked-non-recursive-mutex-audit" and
  ruleId = "CON56-CPP"
}

module ConcurrencyPackage {
  Query doNotAllowAMutexToGoOutOfScopeWhileLockedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `doNotAllowAMutexToGoOutOfScopeWhileLocked` query
      TConcurrencyPackageQuery(TDoNotAllowAMutexToGoOutOfScopeWhileLockedQuery())
  }

  Query doNotDestroyAMutexWhileItIsLockedQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `doNotDestroyAMutexWhileItIsLocked` query
      TConcurrencyPackageQuery(TDoNotDestroyAMutexWhileItIsLockedQuery())
  }

  Query ensureActivelyHeldLocksAreReleasedOnExceptionalConditionsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `ensureActivelyHeldLocksAreReleasedOnExceptionalConditions` query
      TConcurrencyPackageQuery(TEnsureActivelyHeldLocksAreReleasedOnExceptionalConditionsQuery())
  }

  Query preventDataRacesWhenAccessingBitFieldsFromMultipleThreadsQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `preventDataRacesWhenAccessingBitFieldsFromMultipleThreads` query
      TConcurrencyPackageQuery(TPreventDataRacesWhenAccessingBitFieldsFromMultipleThreadsQuery())
  }

  Query deadlockByLockingInPredefinedOrderQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `deadlockByLockingInPredefinedOrder` query
      TConcurrencyPackageQuery(TDeadlockByLockingInPredefinedOrderQuery())
  }

  Query wrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `wrapFunctionsThatCanSpuriouslyWakeUpInLoop` query
      TConcurrencyPackageQuery(TWrapFunctionsThatCanSpuriouslyWakeUpInLoopQuery())
  }

  Query preserveThreadSafetyAndLivenessWhenUsingConditionVariablesQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `preserveThreadSafetyAndLivenessWhenUsingConditionVariables` query
      TConcurrencyPackageQuery(TPreserveThreadSafetyAndLivenessWhenUsingConditionVariablesQuery())
  }

  Query doNotSpeculativelyLockALockedNonRecursiveMutexQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `doNotSpeculativelyLockALockedNonRecursiveMutex` query
      TConcurrencyPackageQuery(TDoNotSpeculativelyLockALockedNonRecursiveMutexQuery())
  }

  Query lockedALockedNonRecursiveMutexAuditQuery() {
    //autogenerate `Query` type
    result =
      // `Query` type for `lockedALockedNonRecursiveMutexAudit` query
      TConcurrencyPackageQuery(TLockedALockedNonRecursiveMutexAuditQuery())
  }
}
