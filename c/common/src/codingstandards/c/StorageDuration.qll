import cpp

class DeclarationWithStorageDuration extends Declaration { }

newtype TStorageDuration =
  StorageDurationStatic() or
  StorageDurationAutomatic() or
  StorageDurationThread() or
  StorageDurationAllocated()

class StorageDuration extends TStorageDuration {
  predicate isStatic() { this = StorageDurationStatic() }

  predicate isAutomatic() { this = StorageDurationAutomatic() }

  predicate isThread() { this = StorageDurationThread() }

  predicate isAllocated() { this = StorageDurationAllocated() }

  string toString() { result = getStorageTypeName() + " storage duration" }

  string getStorageTypeName() {
    isStatic() and result = "static"
    or
    isAutomatic() and result = "automatic"
    or
    isThread() and result = "thread"
    or
    isAllocated() and result = "allocated"
  }
}
