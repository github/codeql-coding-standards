#define atomic_compare_exchange_weak(a, b, c) 0
#define atomic_compare_exchange_weak_explicit(a, b, c, d, e) 0
#define atomic_load(a) 0
#define atomic_load_explicit(a, b)
#define atomic_store(a, b) 0
#define atomic_store_explicit(a, b, c) 0
#define ATOMIC_VAR_INIT(value) (value)
#define atomic_is_lock_free(obj) __c11_atomic_is_lock_free(sizeof(*(obj)))
typedef _Atomic(int) atomic_int;