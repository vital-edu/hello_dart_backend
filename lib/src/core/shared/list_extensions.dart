extension ListUtils<T> on List<T> {
  T? safe(int index) {
    return (0 <= index && index < length) ? this[index] : null;
  }
}
