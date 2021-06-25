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

  final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  // Verificando se há cameras, se houver será direcionada a primeira camera de traz, pois pode haver mais de uma.
  void getAvalibleCamera() async {
    try {
      final response = await availableCameras();
      final camera = response.firstWhere(
        (element) => element.lensDirection == CameraLensDirection.back,
      );
      final cameraController = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
      );
      await cameraController.initialize();
      status = BarcodeScannerStatus.available(cameraController);
      scanWithCamera();
    } catch (e) {
      status = BarcodeScannerStatus.error(e.toString());
    }
  }

  //Aqui estar sendo a funcionalidade da camera onde vai ser chamado a leitura.
  void scanWithCamera() {
    Future.delayed(Duration(seconds: 10)).then(
      (value) {
        if (status.cameraController != null) {
          if (status.cameraController!.value.isStreamingImages)
            status.cameraController!.stopImageStream();
        }
        status = BarcodeScannerStatus.error("Timeout de leitura de boleto");
      },
    );
    listenCamera();
  }

  //Pegando imagem da galeria pra ler o codigo de barra se houver.
  void scanWithImagePicker() async {
    await status.cameraController!.stopImageStream();
    final response = await ImagePicker().getImage(source: ImageSource.gallery);
    final inputImage = InputImage.fromFilePath(response!.path);
    scannerBarCode(inputImage);
  }

  //Realizando leitura do codigo de barra.
  void listenCamera() {
    if (status.cameraController !=
        null) if (status.cameraController!.value.isStreamingImages == false)
      status.cameraController!.startImageStream(
        (cameraImage) async {
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
                InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
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
            await Future.delayed(Duration(seconds: 3));
            await scannerBarCode(inputImage);
          } catch (e) {
            print(e);
          }
        },
      );
  }

  //Depois da imagem se lida pelo GOOGLEMLKIT, a imagem parar aqui para ser lida e mandada pra tela de cadastro de boleto.
  Future<void> scannerBarCode(InputImage inputImage) async {
    try {
      if (status.cameraController != null) {
        if (status.cameraController!.value.isStreamingImages)
          status.cameraController!.stopImageStream();
      }
      final barcodes = await barcodeScanner.processImage(inputImage);
      var barcode;
      for (Barcode item in barcodes) {
        barcode = item.value.displayValue;
      }

      if (barcode != null && status.barcode.isEmpty) {
        status = BarcodeScannerStatus.barcode(barcode);
        if (status.cameraController != null) status.cameraController!.dispose();
      } else {
        availableCameras();
      }
    } catch (e) {
      print("ERRO DA LEITURA $e");
    }
  }

  void dispose() {
    statusNotifier.dispose();
    barcodeScanner.close();
    if (status.showCamera) {
      status.cameraController!.dispose();
    }
  }
}
