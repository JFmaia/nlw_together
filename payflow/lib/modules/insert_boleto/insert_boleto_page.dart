import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:payflow/modules/insert_boleto/insert_boleto_controller.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/themes/app_text_styles.dart';
import 'package:payflow/shared/widgets/input_text/input_text_widget.dart';
import 'package:payflow/shared/widgets/set_label_buttons/set_label_buttons.dart';

class InsertBoleto extends StatefulWidget {
  final String? barcode;
  const InsertBoleto({
    Key? key,
    this.barcode,
  }) : super(key: key);

  @override
  _InsertBoletoState createState() => _InsertBoletoState();
}

class _InsertBoletoState extends State<InsertBoleto> {
  final controller = InsertBoletoController();
  final moneyInputTextCotroller = MoneyMaskedTextController(
    leftSymbol: "R\$",
    decimalSeparator: ",",
  );

  final dueDateInputTextController = MaskedTextController(mask: "00/00/0000");
  final barcodeInputTextController = TextEditingController();

  @override
  void initState() {
    if (widget.barcode != null) {
      barcodeInputTextController.text = widget.barcode!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(
          color: AppColors.input,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 93,
                vertical: 24,
              ),
              child: Text(
                "Preencha os dados do boleto",
                style: AppTextStyles.titleBoldHeading,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    InputTextWidget(
                      validator: controller.validateName,
                      label: "Nome do boleto",
                      icon: Icons.description_outlined,
                      onChanged: (value) {
                        controller.onChanged(name: value);
                      },
                    ),
                    InputTextWidget(
                      validator: controller.validateVencimento,
                      label: "Vencimento",
                      controller: dueDateInputTextController,
                      icon: FontAwesomeIcons.timesCircle,
                      onChanged: (value) {
                        controller.onChanged(dueDate: value);
                      },
                    ),
                    InputTextWidget(
                      validator: (_) => controller
                          .validateValor(moneyInputTextCotroller.numberValue),
                      controller: moneyInputTextCotroller,
                      label: "Valor",
                      icon: FontAwesomeIcons.wallet,
                      onChanged: (value) {
                        controller.onChanged(
                          valeu: moneyInputTextCotroller.numberValue,
                        );
                      },
                    ),
                    InputTextWidget(
                      validator: controller.validateCodigo,
                      controller: barcodeInputTextController,
                      label: "C??digo",
                      icon: FontAwesomeIcons.barcode,
                      onChanged: (value) {
                        controller.onChanged(barcode: value);
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: SetLabelButtons(
        enableSecondaryColor: true,
        primaryLabel: "Cancelar",
        primaryOnPressed: () {
          Navigator.pop(context);
        },
        secondaryLabel: "Cadastrar",
        secondaryOnPressed: () async {
          await controller.cadastrarBoleto();
          Navigator.pop(context);
        },
      ),
    );
  }
}
