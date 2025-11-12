class NetworkConnectivityServiceState {
  const NetworkConnectivityServiceState({
    this.isConnected = false,
  });

  final bool isConnected;

  NetworkConnectivityServiceState copyWith({
    bool? isConnected,
  }) {
    return NetworkConnectivityServiceState(
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
