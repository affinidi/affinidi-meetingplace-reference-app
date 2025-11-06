enum MaxLengthValidatorType {
  small(16),
  medium(32),
  large(64),
  xlarge(128),
  extraLong(1024);

  const MaxLengthValidatorType(this.value);

  final int value;
}
