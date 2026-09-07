import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

// Shared shell for the courier-dispatch confirmation dialogs: title + close
// icon, a body widget, an orange warning strip, and a Cancel/Confirm row
// that pops the dialog with false/true respectively.
class _ConfirmationDialogShell extends StatelessWidget {
  final String title;
  final Widget body;
  final String warningText;
  final String cancelLabel;
  final String confirmLabel;
  const _ConfirmationDialogShell({
    required this.title,
    required this.body,
    required this.warningText,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: titilliumBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Icon(Icons.close, size: 20, color: Theme.of(context).hintColor),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              body,
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                ),
                child: Text(
                  warningText,
                  style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.orange.shade900),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Text(
                          cancelLabel,
                          style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Text(
                          confirmLabel,
                          style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SendToCourierConfirmationDialog extends StatelessWidget {
  final String providerLabel;
  const SendToCourierConfirmationDialog({super.key, required this.providerLabel});

  @override
  Widget build(BuildContext context) {
    return _ConfirmationDialogShell(
      title: getTranslated('send_this_order_to_the_delivery_partner', context) ?? 'Send this order to the delivery partner?',
      body: RichText(
        text: TextSpan(
          style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.4),
          children: [
            TextSpan(text: '${getTranslated('the_order_information_will_be_sent_to', context) ?? 'The order information will be sent to'} '),
            TextSpan(text: providerLabel, style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
            TextSpan(text: '. ${getTranslated('verify_delivery_information_before_you_continue', context) ?? 'Please verify the delivery address, recipient information, contact details, and delivery information before you continue.'}'),
          ],
        ),
      ),
      warningText: getTranslated('incorrect_information_may_cause_delivery_issues', context) ?? 'Incorrect information may cause delivery issues. Correct anything that is wrong before confirming.',
      cancelLabel: getTranslated('review_again', context) ?? 'Review Again',
      confirmLabel: getTranslated('confirm_and_send', context) ?? 'Confirm and Send',
    );
  }
}

// Shown before POST /courier/revise — no carrier is ever contacted by a
// revise, so the copy warns that the platform's record and the carrier's
// may now disagree, rather than warning about a duplicate booking.
class ReviseDeliveryConfirmationDialog extends StatelessWidget {
  const ReviseDeliveryConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return _ConfirmationDialogShell(
      title: getTranslated('update_delivery_information_question', context) ?? 'Update Delivery Information?',
      body: Text(
        getTranslated('revise_delivery_information_body', context) ??
            'This order is already assigned to a delivery partner. Changing this information may create a mismatch with what was already submitted to them.',
        style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.4),
      ),
      warningText: getTranslated('revise_delivery_information_warning', context) ??
          'You may need to update this with the delivery partner manually, or contact them if the shipment has already been processed.',
      cancelLabel: getTranslated('cancel', context) ?? 'Cancel',
      confirmLabel: getTranslated('yes_update', context) ?? 'Yes, Update',
    );
  }
}

// Shown before navigating to the booking form for a different partner. The
// old partner is never contacted server-side on a switch, so this is the
// only control over the duplicate-booking risk — reproduces the web panels'
// wording.
class SwitchDeliveryPartnerConfirmationDialog extends StatelessWidget {
  final String currentProviderLabel;
  final String newProviderLabel;
  const SwitchDeliveryPartnerConfirmationDialog({super.key, required this.currentProviderLabel, required this.newProviderLabel});

  @override
  Widget build(BuildContext context) {
    return _ConfirmationDialogShell(
      title: getTranslated('switch_delivery_partner_question', context) ?? 'Switch Delivery Partner?',
      body: RichText(
        text: TextSpan(
          style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.4),
          children: [
            TextSpan(text: '${getTranslated('this_order_is_already_assigned_to', context) ?? 'This order is already assigned to'} '),
            TextSpan(text: currentProviderLabel, style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
            TextSpan(text: '. ${getTranslated('switching_to', context) ?? 'Switching to'} '),
            TextSpan(text: newProviderLabel, style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
            TextSpan(text: ' ${getTranslated('switch_delivery_partner_conflict_warning', context) ?? 'may cause a conflict. Both delivery partners may try to process or collect the same order.'}'),
          ],
        ),
      ),
      warningText: getTranslated('previous_delivery_partner_not_cancelled_automatically', context) ??
          'The previous delivery partner is not cancelled automatically. Cancel the shipment with them directly to avoid a duplicate pickup.',
      cancelLabel: getTranslated('cancel', context) ?? 'Cancel',
      confirmLabel: getTranslated('yes_switch_partner', context) ?? 'Yes Switch Partner',
    );
  }
}
