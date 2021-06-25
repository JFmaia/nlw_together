class BarcodeScannerStatus {
  final bool isCameraAvalible;
  final String error;
  final String barcode;
  final bool stopScanner;

  BarcodeScannerStatus({
    this.stopScanner = false,
    this.isCameraAvalible = false,
    this.error = "",
    this.barcode = "",
  });

  factory BarcodeScannerStatus.available() => BarcodeScannerStatus(
        isCameraAvalible: true,
        stopScanner: false,
      );

  factory BarcodeScannerStatus.error(String message) => BarcodeScannerStatus(
        error: message,
        stopScanner: true,
      );

  factory BarcodeScannerStatus.barcode(String barcode) => BarcodeScannerStatus(
        barcode: barcode,
        stopScanner: true,
      );

  bool get showCamera => isCameraAvalible && error.isEmpty;

  bool get hasError => error.isNotEmpty;

  bool get hasBarcode => barcode.isNotEmpty;
}
