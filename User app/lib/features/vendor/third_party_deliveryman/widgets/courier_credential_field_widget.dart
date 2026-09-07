import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/common/basewidgets/textfeild/custom_pass_textfeild_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/models/courier_provider_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/widgets/courier_option_picker_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/styles.dart';

class CourierCredentialFieldWidget extends StatefulWidget {
  final CourierFieldModel field;
  final TextEditingController controller;
  const CourierCredentialFieldWidget({super.key, required this.field, required this.controller});

  @override
  State<CourierCredentialFieldWidget> createState() => _CourierCredentialFieldWidgetState();
}

class _CourierCredentialFieldWidgetState extends State<CourierCredentialFieldWidget> {
  Future<void> _pickOption() async {
    final String? selected = await showCourierOptionPickerBottomSheet(
      context,
      title: widget.field.label ?? '',
      options: widget.field.options ?? [],
      selectedId: widget.controller.text,
    );
    if (selected != null) {
      setState(() => widget.controller.text = selected);
    }
  }

  String _selectedOptionLabel() {
    final match = (widget.field.options ?? []).where((option) => option.id == widget.controller.text);
    return match.isNotEmpty ? (match.first.label ?? '') : '';
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final Color labelColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: field.label ?? '',
              style: titilliumRegular.copyWith(color: labelColor),
              children: [
                if (field.required == true) TextSpan(text: '  *', style: titilliumRegular.copyWith(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          if (field.type == 'password')
            CustomPasswordTextFieldWidget(controller: widget.controller, hintTxt: field.label, border: true)
          else if (field.type == 'select')
            InkWell(
              onTap: _pickOption,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .35)),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  color: Theme.of(context).highlightColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedOptionLabel().isNotEmpty ? _selectedOptionLabel() : (getTranslated('select', context) ?? 'Select'),
                        style: titilliumRegular.copyWith(
                          color: _selectedOptionLabel().isNotEmpty ? labelColor : Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Theme.of(context).hintColor),
                  ],
                ),
              ),
            )
          else
            CustomTextFieldWidget(controller: widget.controller, hintText: field.label, border: true),

          if ((field.help ?? '').isNotEmpty) Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
            child: Text(field.help!, style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            )),
          ),
        ],
      ),
    );
  }
}
