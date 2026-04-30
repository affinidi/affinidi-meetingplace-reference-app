/// Constants for ZKP and liveness credential operations
class ZkpConstants {
  /// Message format for liveness check requests
  static const livenessCheckRequestType = 'https://affinidi.com/liveness-check-request';
  
  /// Message format for liveness proof responses
  static const livenessProofType = 'https://affinidi.com/liveness-proof';
  
  /// Default expiry duration for liveness credentials
  static const vcExpiryDuration = Duration(days: 5);
  
  /// Issuer name for generated credentials
  static const vcIssuerName = 'Affinidi';
  
  /// Schema identifier for liveness credentials
  static const livenessSchemaVersion = 'liveness-v1';
}
