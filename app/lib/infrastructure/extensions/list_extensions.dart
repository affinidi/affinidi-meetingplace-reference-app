/// Extension methods on [List] for common immutable operations.
extension ListExtensions<T> on List<T> {
  /// Returns a new list with the replaced item
  List<T> replaceItemAtIndex(int index, T newValue) {
    final newList = [...this];
    newList[index] = newValue;
    return newList;
  }
}
