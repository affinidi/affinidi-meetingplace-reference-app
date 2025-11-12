/// Extension methods on [Iterable<String?>] for working with non-empty strings.
extension NonEmptyIterableStringsExtensions on Iterable<String?> {
  /// The non-empty elements of this iterable.
  ///
  /// The same elements as this iterable, except that `null`
  /// and empty values are omitted.
  Iterable<String> get nonEmpty => nonNulls.where((item) => item.isNotEmpty);
}
