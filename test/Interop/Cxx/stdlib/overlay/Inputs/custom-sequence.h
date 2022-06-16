#ifndef TEST_INTEROP_CXX_STDLIB_INPUTS_CUSTOM_SEQUENCE_H
#define TEST_INTEROP_CXX_STDLIB_INPUTS_CUSTOM_SEQUENCE_H

#include <cstddef>
#include <iterator>

struct SimpleSequence {
  struct ConstIterator {
  private:
    int value;

  public:
    using iterator_category = std::input_iterator_tag;
    using value_type = int;
    using pointer = int *;
    using reference = int &;
    using difference_type = int;

    ConstIterator(int value) : value(value) {}
    ConstIterator(const ConstIterator &other) = default;

    const int &operator*() const { return value; }

    ConstIterator &operator++() {
      value++;
      return *this;
    }
    ConstIterator operator++(int) {
      auto tmp = ConstIterator(value);
      value++;
      return tmp;
    }

    friend bool operator==(const ConstIterator &a, const ConstIterator &b) {
      return a.value == b.value;
    }
    friend bool operator!=(const ConstIterator &a, const ConstIterator &b) {
      return a.value != b.value;
    }
  };

  ConstIterator begin() const { return ConstIterator(1); }
  ConstIterator end() const { return ConstIterator(5); }
};

struct SimpleArrayWrapper {
private:
  int a[5] = {10, 20, 30, 40, 50};

public:
  // Unfortunately `__attribute__((returns_nonnull))` is required, otherwise
  // the return type would be `UnsafePointer<Int32>!` instead of
  // `UnsafePointer<Int32>`, and `UnsafePointer<Int32>!` does not conform to
  // UnsafeCxxInputIterator.
  const int *begin() const __attribute__((returns_nonnull)) { return &a[0]; }
  const int *end() const __attribute__((returns_nonnull)) { return &a[5]; }
};

#endif // TEST_INTEROP_CXX_STDLIB_INPUTS_CUSTOM_SEQUENCE_H