void take_val(int) {}
void take_ref(int &) {}
void take_rref(int &&) {}
template <typename T> void take_uni(T &&) {}

int get_val();
int &get_ref();
int &&get_rref();

template <typename T> T &&move(T &t) { return static_cast<T &&>(t); }
template <typename T> T &&move(T &&t) { return static_cast<T &&>(t); }

int main() {
  get_val();
  get_ref();
  get_rref();

  int val = 42;
  take_val(val);
  take_ref(val);
  take_rref(move(val));
  take_uni(val);
  take_uni(move(val));

  take_val(get_val());
  take_rref(get_val());
  take_rref(move(get_val()));
  take_uni(get_val());
  take_uni(move(get_val()));

  int &ref = val;
  take_val(ref);
  take_ref(ref);
  take_rref(move(ref));
  take_uni(ref);
  take_uni(move(ref));

  take_val(get_ref());
  take_ref(get_ref());
  take_rref(move(get_ref()));
  take_uni(get_ref());
  take_uni(move(get_ref()));

  int &&rref = move(val);
  take_val(rref);
  take_ref(rref);
  take_rref(move(rref));
  take_uni(rref);
  take_uni(move(rref));

  take_val(get_rref());
  take_rref(get_rref());
  take_rref(move(get_rref()));
  take_uni(get_rref());
  take_uni(move(get_rref()));

  return 0;
}