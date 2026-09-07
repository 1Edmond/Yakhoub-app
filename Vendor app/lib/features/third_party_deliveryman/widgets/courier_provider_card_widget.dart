import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/domain/models/courier_provider_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CourierProviderCardWidget extends StatefulWidget {
  final CourierProviderModel provider;
  final Function(bool isEnabled) onToggle;
  final VoidCallback onConfigureTap;
  const CourierProviderCardWidget({super.key, required this.provider, required this.onToggle, required this.onConfigureTap});

  @override
  State<CourierProviderCardWidget> createState() => _CourierProviderCardWidgetState();
}

class _CourierProviderCardWidgetState extends State<CourierProviderCardWidget> {
  // Bumped whenever a toggle attempt is cancelled, to force FlutterSwitch to
  // re-sync its internal visual state back to `provider.isEnabled` (it tracks
  // its own optimistic state on tap regardless of what `onToggle` does).
  int _switchResetTick = 0;

  Future<void> _handleToggle(bool value) async {
    if (widget.provider.isConfigured != true) {
      widget.onConfigureTap();
      setState(() => _switchResetTick++);
      return;
    }

    bool confirmed = false;
    await showAnimatedDialogWidget(context, CustomConfirmationDialogWidget(
      iconWidget: _ToggleConfirmationIconWidget(isEnabling: value),
      title: getTranslated(value ? 'want_to_enable_delivery' : 'want_to_disable_delivery', context)
          ?.replaceAll('{partner}', widget.provider.label ?? '') ?? '',
      description: getTranslated(value ? 'enable_delivery_partner_hint' : 'disable_delivery_partner_hint', context) ?? '',
      yesButtonText: getTranslated('ok', context) ?? 'Ok',
      noButtonText: getTranslated('cancel', context) ?? 'Cancel',
      onYesPressed: () {
        confirmed = true;
        Navigator.of(context).pop();
      },
    ));

    if (confirmed) {
      widget.onToggle(value);
    } else {
      setState(() => _switchResetTick++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final bool isConfigured = provider.isConfigured == true;
    final bool isEnabled = provider.isEnabled == true;

    final String badgeKey = !isConfigured ? 'not_configured' : (isEnabled ? 'enabled' : 'disabled');
    final Color badgeColor = !isConfigured
        ? Theme.of(context).colorScheme.error
        : (isEnabled ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).hintColor);

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Dimensions.paddingSizeSmall,
              runSpacing: Dimensions.paddingSizeExtraSmall,
              children: [
                Text(provider.label ?? '', style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    getTranslated(badgeKey, context) ?? '',
                    style: titilliumBold.copyWith(color: badgeColor, fontSize: Dimensions.fontSizeExtraSmall),
                  ),
                ),
              ],
            ),
          ),

          FlutterSwitch(
            key: ValueKey('${provider.id}-$isEnabled-$_switchResetTick'),
            value: isEnabled,
            activeColor: Theme.of(context).primaryColor,
            width: 44, height: 24, toggleSize: 18, padding: 2,
            onToggle: _handleToggle,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          InkWell(
            onTap: widget.onConfigureTap,
            child: Container(
              height: 34, width: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Icon(Icons.settings_outlined, size: 18, color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleConfirmationIconWidget extends StatelessWidget {
  final bool isEnabling;
  const _ToggleConfirmationIconWidget({required this.isEnabling});

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = isEnabling ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error;

    return SizedBox(
      height: Dimensions.heightWidth50,
      width: Dimensions.heightWidth50 + 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(Images.creditCard, height: Dimensions.heightWidth50),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(isEnabling ? Icons.check : Icons.remove, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
