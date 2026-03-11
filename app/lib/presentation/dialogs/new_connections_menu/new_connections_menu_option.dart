enum NewConnectionsMenuOption {
  shareQRCode(assetName: 'qrcode.png'),
  scanQRCode(assetName: 'scanqr.png'),
  claimAnOffer(assetName: 'receive.png'),
  publishAnOffer(assetName: 'publish.png');

  const NewConnectionsMenuOption({required this.assetName});

  final String assetName;
}
