#ifndef _GHLIBCPP_FUTURE
#define _GHLIBCPP_FUTURE

namespace std {

enum class launch {
    async,
    deferred
};

template<typename T>
class future {
public:
    future();
    future(const future&);
    future(future&&);
};

template<typename T>
class shared_future {
public:
    shared_future();
    shared_future(const shared_future&);
    shared_future(shared_future&&);
    shared_future(future<T>&&);
};

template<typename T>
class promise {
public:
    promise();
    promise(const promise&);
    promise(promise&&);
    future<T> get_future();
};

template<typename Signature>
class packaged_task;

template<typename R, typename... Args>
class packaged_task<R(Args...)> {
public:
    packaged_task();
    packaged_task(const packaged_task&);
    packaged_task(packaged_task&&);
    template<typename F> packaged_task(F&&);
};

template<typename F, typename... Args>
auto async(F&&, Args&&...) -> future<decltype(declval<F>()(declval<Args>()...))>;

template<typename F, typename... Args>
auto async(launch, F&&, Args&&...) -> future<decltype(declval<F>()(declval<Args>()...))>;

} // namespace std

#endif // _GHLIBCPP_FUTURE
