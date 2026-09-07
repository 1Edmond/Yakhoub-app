import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_details_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/third_party_delivery_info_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/controllers/third_party_deliveryman_controller.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/domain/models/courier_enabled_provider_model.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/screens/send_to_courier_screen.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/widgets/send_to_courier_confirmation_dialog.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class CourierProviderSelectionWidget extends StatefulWidget {
  final Order? orderModel;
  final CourierShipmentModel? courierShipment;
  const CourierProviderSelectionWidget({super.key, required this.orderModel, this.courierShipment});

  @override
  State<CourierProviderSelectionWidget> createState() => _CourierProviderSelectionWidgetState();
}

class _CourierProviderSelectionWidgetState extends State<CourierProviderSelectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Setup is reserved for the admin for this vendor — don't bother
      // calling /courier/providers, it would only ever answer empty.
      final bool deliveryPartnerSetupComplete =
          Provider.of<SplashController>(context, listen: false).configModel?.deliveryPartnerSetupStatus == true;
      if (!deliveryPartnerSetupComplete) return;

      final controller = Provider.of<ThirdPartyDeliverymanController>(context, listen: false);
      // Reset any selection left over from a previously opened order.
      controller.selectProvider(null);
      controller.getEnabledProviders(context);
    });
  }

  Future<void> _openSendToCourierScreen(
    CourierEnabledProviderModel provider, {
    Map<String, dynamic>? initialDispatchDetails,
    SendToCourierMode mode = SendToCourierMode.book,
  }) async {
    final order = widget.orderModel;
    final shipping = order?.shippingAddressData;
    final String customerName = '${order?.customer?.fName ?? ''} ${order?.customer?.lName ?? ''}'.trim();

    // Pathao books against the shipping address's own contact, which can
    // differ from the account holder's name/phone on the customer profile.
    final bool useShippingContact = provider.id == 'pathao';
    final String recipientName = useShippingContact && (shipping?.contactPersonName ?? '').isNotEmpty
        ? shipping!.contactPersonName!
        : customerName;
    final String recipientPhone = useShippingContact && (shipping?.phone ?? '').isNotEmpty
        ? shipping!.phone!
        : (order?.customer?.phone ?? '');

    final String? successMessage = await Navigator.of(context).push<String>(MaterialPageRoute(
      builder: (_) => SendToCourierScreen(
        orderId: order!.id!,
        provider: provider,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        recipientAddress: shipping?.address ?? '',
        codAmount: order.paymentStatus == 'paid' ? 0 : (order.orderAmount ?? 0),
        orderValue: order.orderAmount,
        latitude: shipping?.latitude,
        longitude: shipping?.longitude,
        initialDispatchDetails: initialDispatchDetails,
        mode: mode,
      ),
    ));

    if (successMessage != null && mounted) {
      showCustomSnackBarWidget(successMessage, context, sanckBarType: SnackBarType.success);
      await Provider.of<OrderDetailsController>(context, listen: false).getOrderDetails(order!.id.toString());
      if (mounted) Navigator.of(context).pop();
    }
  }

  // Reproduces the web panels' switch warning: the previous partner is
  // never contacted server-side, so this confirmation is the only control
  // over the duplicate-booking risk. Re-shown fresh on every tap of the
  // Switch Delivery Partner button, so cancelling never blocks a retry.
  Future<void> _confirmAndSwitch(CourierEnabledProviderModel targetProvider, CourierShipmentModel shipment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => SwitchDeliveryPartnerConfirmationDialog(
        currentProviderLabel: shipment.deliveryPartner ?? '',
        newProviderLabel: targetProvider.label ?? '',
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await _openSendToCourierScreen(targetProvider, mode: SendToCourierMode.switchPartner);
  }

  CourierEnabledProviderModel? _findProvider(List<CourierEnabledProviderModel> providers, String? id) {
    if (id == null) return null;
    for (final provider in providers) {
      if (provider.id == id) return provider;
    }
    return null;
  }

  Widget _providerRadioTile(ThirdPartyDeliverymanController controller, CourierEnabledProviderModel provider, {required TextStyle labelStyle}) {
    final bool isSelected = controller.selectedProviderId == provider.id;
    return InkWell(
      onTap: () => controller.selectProvider(provider.id),
      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: .35),
            width: isSelected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(provider.label ?? '', style: labelStyle),
            Radio<String>(
              value: provider.id ?? '',
              groupValue: controller.selectedProviderId,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) => controller.selectProvider(value),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThirdPartyDeliverymanController>(
      builder: (context, controller, _) {
        if (controller.isLoadingProviders) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            child: Center(child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        final CourierShipmentModel? shipment = widget.courierShipment;

        // Already dispatched to a courier — show its status + management actions
        // instead of the plain "pick a provider" list below.
        if (shipment != null) {
          final CourierEnabledProviderModel? assignedProvider = _findProvider(controller.enabledProviders, shipment.provider);
          final bool canManage = shipment.canManage != false;
          final List<CourierEnabledProviderModel> otherProviders =
              controller.enabledProviders.where((provider) => provider.id != shipment.provider).toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getTranslated('third_party_delivery_partner', context) ?? '', style: robotoBold.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                CourierShipmentCard(shipment: shipment, showTrackingHistoryButton: false),

                if (canManage && assignedProvider != null) ...[
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openSendToCourierScreen(
                        assignedProvider,
                        initialDispatchDetails: shipment.dispatchDetails,
                        mode: SendToCourierMode.revise,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSize),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                      ),
                      icon: Icon(Icons.edit_outlined, size: 18, color: Theme.of(context).primaryColor),
                      label: Text(getTranslated('update_delivery_information', context) ?? '',
                          style: titilliumBold.copyWith(color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ],

                if (canManage && otherProviders.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text(getTranslated('switch_delivery_partner', context) ?? '', style: robotoBold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  for (int i = 0; i < otherProviders.length; i++) ...[
                    if (i != 0) const SizedBox(height: Dimensions.paddingSizeSmall),
                    Builder(builder: (context) => _providerRadioTile(
                      controller,
                      otherProviders[i],
                      labelStyle: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                    )),
                  ],

                  if (controller.selectedProviderId != null) ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    CustomButtonWidget(
                      btnTxt: getTranslated('switch_delivery_partner', context),
                      onTap: () => _confirmAndSwitch(
                        otherProviders.firstWhere((provider) => provider.id == controller.selectedProviderId),
                        shipment,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        }

        // No shipment assigned yet — assigning a brand-new third-party
        // delivery partner is gated behind delivery_partner_setup_status.
        // Managing an already-assigned shipment (above) is unaffected.
        final bool deliveryPartnerSetupComplete =
            Provider.of<SplashController>(context, listen: false).configModel?.deliveryPartnerSetupStatus == true;

        if (!deliveryPartnerSetupComplete) {
          return const SizedBox();
        }

        if (controller.enabledProviders.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
            child: Row(
              children: [
                CustomAssetImageWidget(Images.infoIcon, height: 15, width: 15),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(getTranslated('delivery_providers_are_not_configured', context) ?? '',
                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                )
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getTranslated('select_delivery_partner', context) ?? '', style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              for (int i = 0; i < controller.enabledProviders.length; i++) ...[
                if (i != 0) const SizedBox(height: Dimensions.paddingSizeSmall),
                Builder(builder: (context) => _providerRadioTile(
                  controller,
                  controller.enabledProviders[i],
                  labelStyle: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                )),
              ],

              if (controller.selectedProviderId != null) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                CustomButtonWidget(
                  btnTxt: getTranslated('send_to_courier', context),
                  onTap: () => _openSendToCourierScreen(
                    controller.enabledProviders.firstWhere((provider) => provider.id == controller.selectedProviderId),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
