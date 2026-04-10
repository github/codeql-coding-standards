#ifndef _GHLIBCPP_QUEUE
#define _GHLIBCPP_QUEUE

namespace std {

template<typename T>
class queue {
public:
    queue();
    queue(const queue&);
    queue(queue&&);
};

template<typename T>
class priority_queue {
public:
    priority_queue();
    priority_queue(const priority_queue&);
    priority_queue(priority_queue&&);
};

} // namespace std

#endif // _GHLIBCPP_QUEUE
