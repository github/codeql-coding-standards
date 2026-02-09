import cpp

class C11MutexType extends TypedefType {
  C11MutexType() { this.hasName("mtx_t") }
}

class C11ThreadType extends TypedefType {
  C11ThreadType() { this.hasName("thrd_t") }
}

class C11ConditionType extends TypedefType {
  C11ConditionType() { this.hasName("cnd_t") }
}

class C11ThreadStorageType extends TypedefType {
  C11ThreadStorageType() { this.hasName("tss_t") }
}

class C11ThreadingObjectType extends TypedefType {
  C11ThreadingObjectType() {
    this instanceof C11MutexType
    or
    this instanceof C11ThreadType
    or
    this instanceof C11ConditionType
    or
    this instanceof C11ThreadStorageType
  }
}
