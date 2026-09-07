import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/controllers/third_party_deliveryman_controller.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/domain/models/courier_provider_model.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/widgets/courier_credential_field_widget.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/widgets/courier_option_picker_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CourierProviderConfigScreen extends StatefulWidget {
  final CourierProviderModel provider;
  const CourierProviderConfigScreen({super.key, required this.provider});

  @override
  State<CourierProviderConfigScreen> createState() => _CourierProviderConfigScreenState();
}

class _CourierProviderConfigScreenState extends State<CourierProviderConfigScreen> {
  late bool _isEnabled;
  late String _environment;
  late String _country;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final provider = widget.provider;
    _isEnabled = provider.isEnabled ?? false;
    _environment = provider.environment?.isNotEmpty == true
        ? provider.environment!
        : (provider.environments?.isNotEmpty == true ? provider.environments!.first : 'sandbox');
    _country = provider.country ?? '';
    if (_country.isEmpty && provider.countries?.length == 1) {
      _country = provider.countries!.first.id ?? '';
    }

    for (final field in provider.fields ?? <CourierFieldModel>[]) {
      _controllers[field.key!] = TextEditingController(text: provider.credentials?[field.key] ?? '');
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final options = (widget.provider.countries ?? []).map((country) =>
        CourierFieldOptionModel(id: country.id, label: country.label)).toList();

    final String? selected = await showCourierOptionPickerBottomSheet(
      context,
      title: getTranslated('country', context) ?? 'Country',
      options: options,
      selectedId: _country,
    );
    if (selected != null) setState(() => _country = selected);
  }

  String _countryLabel() {
    final match = (widget.provider.countries ?? []).where((country) => country.id == _country);
    return match.isNotEmpty ? (match.first.label ?? '') : '';
  }

  bool _validate() {
    for (final field in widget.provider.fields ?? <CourierFieldModel>[]) {
      if (field.required == true && (_controllers[field.key]?.text.trim().isEmpty ?? true)) {
        showCustomSnackBarWidget('${field.label} ${getTranslated('is_required', context) ?? 'is required'}', context);
        return false;
      }
    }
    if ((widget.provider.countries?.length ?? 0) > 1 && _country.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_select_country', context) ?? 'Please select a country', context);
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;

    final Map<String, dynamic> credentials = {
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };

    final controller = Provider.of<ThirdPartyDeliverymanController>(context, listen: false);
    final bool isSuccess = await controller.saveCourierConfig(context, {
      'provider': widget.provider.id,
      'is_enabled': _isEnabled,
      'environment': _environment,
      if (_country.isNotEmpty) 'country': _country,
      'credentials': credentials,
    });

    if (!mounted) return;
    if (isSuccess) {
      showCustomSnackBarWidget(getTranslated('delivery_partner_settings_updated_successfully', context), context, sanckBarType: SnackBarType.success);
      await controller.getCourierConfig(context);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return Scaffold(
      appBar: CustomAppBarWidget(title: provider.label),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(getTranslated('enable_this_delivery_partner', context) ?? '', style: titilliumBold.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
                FlutterSwitch(
                  value: _isEnabled,
                  activeColor: Theme.of(context).primaryColor,
                  width: 44, height: 24, toggleSize: 18, padding: 2,
                  onToggle: (value) => setState(() => _isEnabled = value),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            if ((provider.environments ?? []).length > 1) ...[
              Text(getTranslated('environment', context) ?? '', style: titilliumRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(
                children: provider.environments!.map((env) => Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: ChoiceChip(
                    label: Text(getTranslated(env, context) ?? env),
                    selected: _environment == env,
                    onSelected: (_) => setState(() => _environment = env),
                  ),
                )).toList(),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            if ((provider.countries ?? []).length > 1) ...[
              Text(getTranslated('country', context) ?? '', style: titilliumRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              InkWell(
                onTap: _pickCountry,
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
                      Text(_countryLabel().isNotEmpty ? _countryLabel() : (getTranslated('select', context) ?? 'Select'),
                        style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      Icon(Icons.keyboard_arrow_down, color: Theme.of(context).hintColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            ...(provider.fields ?? []).map((field) => CourierCredentialFieldWidget(
              field: field,
              controller: _controllers[field.key]!,
            )),

            if ((provider.webhookUrl ?? '').isNotEmpty) ...[
              Text(getTranslated('webhook_url', context) ?? '', style: titilliumRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: provider.webhookUrl!));
                  showCustomSnackBarWidget(getTranslated('copied_to_clipboard', context), context, sanckBarType: SnackBarType.success);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .35)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(provider.webhookUrl!, style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ))),
                      Icon(Icons.copy, size: 16, color: Theme.of(context).hintColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(getTranslated('webhook_url_hint', context) ?? '', style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              )),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Consumer<ThirdPartyDeliverymanController>(
            builder: (context, controller, _) => CustomButtonWidget(
              btnTxt: getTranslated('save', context),
              isLoading: controller.isSaving,
              onTap: _save,
            ),
          ),
        ),
      ),
    );
  }
}
