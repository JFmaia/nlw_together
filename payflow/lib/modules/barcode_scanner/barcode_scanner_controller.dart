import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payflow/modules/barcode_scanner/barcode_scanner_status_page.dart';

class BarcodeScannerController {
  final statusNotifier =
      ValueNotifier<BarcodeScannerStatus>(BarcodeScannerStatus());

  BarcodeScannerStatus get status => statusNotifier.value;

  set status(BarcodeScannerStatus status) => statusNotifier.value = status;

  var barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  InputImage? imagePicker;

  CameraController? cameraController;

  // Verificando se há cameras, se houver será direcionada a primeira camera de traz, pois pode haver mais de uma.
  void getAvalibleCamera() async {
    try {
      final response = await availableCameras();
      final camera = response.firstWhere(
        (element) => element.lensDirection == CameraLensDirection.back,
      );
      cameraController = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
      );
      await cameraController!.initialize();
      scanWithCamera();
      listenCamera();
    } catch (e) {
      status = BarcodeScannerStatus.error(e.toString());
    }
  }

  //Depois da imagem se lida pelo GOOGLEMLKIT, a imagem parar aqui para ser lida e mandada pra tela de cadastro de boleto.
  Future<void> scannerBarCode(InputImage inputImage) async {
    try {
      final barcodes = await barcodeScanner.processImage(inputImage);

      var barcode;
      for (Barcode item in barcodes) {
        barcode = item.value.displayValue;
      }

      if (barcode != null && status.barcode.isEmpty) {
        status = BarcodeScannerStatus.barcode(barcode);
        cameraController!.dispose();
        await barcodeScanner.close();
      }

      return;
    } catch (e) {
      print("ERRO DA LEITURA $e");
    }
  }

  //Pegando imagem da galeria pra ler o codigo de barra se houver.
  void scanWithImagePicker() async {
    final response = await ImagePicker().getImage(source: ImageSource.gallery);
    final inputImage = InputImage.fromFilePath(response!.path);
    scannerBarCode(inputImage);
  }

  //Aqui estar sendo a funcionalidade da camera onde vai ser chamado a leitura.
  void scanWithCamera() {
    status = BarcodeScannerStatus.available();
    Future.delayed(Duration(seconds: 20)).then(
      (value) {
        if (status.hasBarcode == false)
          status = BarcodeScannerStatus.error("Timeout de leitura de boleto");
      },
    );
  }

  //Realizando leitura do codigo de barra.
  void listenCamera() {
    if (cameraController!.value.isStreamingImages == false)
      cameraController!.startImageStream(
        (cameraImage) async {
          if (status.stopScanner == false) {
            try {
              //linhas de codigo retiradas do proprio exemplo do package google_ml_kit.
              final WriteBuffer allBytes = WriteBuffer();
              for (Plane plane in cameraImage.planes) {
                allBytes.putUint8List(plane.bytes);
              }
              final bytes = allBytes.done().buffer.asUint8List();

              final Size imageSize = Size(
                  cameraImage.width.toDouble(), cameraImage.height.toDouble());

              final InputImageRotation imageRotation =
                  InputImageRotation.Rotation_0deg;

              final InputImageFormat inputImageFormat =
                  InputImageFormatMethods.fromRawValue(
                          cameraImage.format.raw) ??
                      InputImageFormat.NV21;

              final planeData = cameraImage.planes.map(
                (Plane plane) {
                  return InputImagePlaneMetadata(
                    bytesPerRow: plane.bytesPerRow,
                    height: plane.height,
                    width: plane.width,
                  );
                },
              ).toList();

              final inputImageData = InputImageData(
                size: imageSize,
                imageRotation: imageRotation,
                inputImageFormat: inputImageFormat,
                planeData: planeData,
              );

              final inputImage = InputImage.fromBytes(
                  bytes: bytes, inputImageData: inputImageData);
              //linhas adicionadas.
              scannerBarCode(inputImage);
            } catch (e) {
              print(e);
            }
          }
        },
      );
  }

  void dispose() {
    statusNotifier.dispose();
    barcodeScanner.close();
    if (status.showCamera) {
      cameraController!.dispose();
    }
  }
}
