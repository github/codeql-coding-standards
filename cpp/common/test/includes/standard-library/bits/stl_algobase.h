namespace std {
template <class ForwardIt, class UnaryPredicate>
ForwardIt remove_if(ForwardIt first, ForwardIt last, UnaryPredicate p) {
  return last;
}

template <class T> const T &max(const T &a, const T &b);

template <typename _RandomAccessIterator, typename _Compare>
inline void sort(_RandomAccessIterator __first, _RandomAccessIterator __last,
                 _Compare __comp) {}

template <typename _RandomAccessIterator>
inline void sort(_RandomAccessIterator __first, _RandomAccessIterator __last) {}

template <typename _RandomAccessIterator, typename _Compare>
inline void stable_sort(_RandomAccessIterator __first,
                        _RandomAccessIterator __last, _Compare __comp) {}

template <typename _RandomAccessIterator>
inline void stable_sort(_RandomAccessIterator __first,
                        _RandomAccessIterator __last) {}

template <typename _RandomAccessIterator, typename _Compare>
inline void partial_sort(_RandomAccessIterator __first,
                         _RandomAccessIterator __middle,
                         _RandomAccessIterator __last, _Compare __comp) {}

template <typename _RandomAccessIterator>
inline void partial_sort(_RandomAccessIterator __first,
                         _RandomAccessIterator __middle,
                         _RandomAccessIterator __last) {}
} // namespace std