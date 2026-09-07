import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/domain/models/order_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:url_launcher/url_launcher.dart';

class ThirdPartyDeliveryInfoWidget extends StatelessWidget {
  final Orders? orderModel;
  final CourierShipmentModel? courierShipment;
  const ThirdPartyDeliveryInfoWidget({super.key, this.orderModel, this.courierShipment});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(color: Theme.of(context).highlightColor),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${getTranslated('shipping_info', context)}', style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: Dimensions.marginSizeExtraSmall),

        courierShipment != null ? _CourierShipmentCard(shipment: courierShipment!) : _FallbackInfo(orderModel: orderModel),
      ]),
    );
  }
}

class _FallbackInfo extends StatelessWidget {
  final Orders? orderModel;
  const _FallbackInfo({this.orderModel});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${getTranslated('delivery_service_name', context)} : ',
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),

        Text((orderModel?.deliveryServiceName != null && orderModel!.deliveryServiceName!.isNotEmpty) ?
        orderModel!.deliveryServiceName! : '',
          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ]),
      const SizedBox(height: Dimensions.marginSizeExtraSmall),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${getTranslated('tracking_id', context)} : ',
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),

        Text(orderModel?.thirdPartyDeliveryTrackingId != null ?
        orderModel!.thirdPartyDeliveryTrackingId! : '',
          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ]),
    ]);
  }
}

class _CourierShipmentCard extends StatelessWidget {
  final CourierShipmentModel shipment;
  const _CourierShipmentCard({required this.shipment});

  Color _toneColor(BuildContext context, String? tone) {
    switch (tone) {
      case 'success': return Theme.of(context).colorScheme.onTertiaryContainer;
      case 'danger': return Theme.of(context).colorScheme.error;
      case 'warning': return Colors.orange;
      case 'info': return Theme.of(context).primaryColor;
      default: return Theme.of(context).hintColor;
    }
  }

  Future<void> _openTrackingUrl(String trackingUrl) async {
    final Uri url = Uri.parse(trackingUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color toneColor = _toneColor(context, shipment.statusTone);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if ((shipment.deliveryPartner ?? '').isNotEmpty)
        _InfoRow(label: getTranslated('delivery_partner', context) ?? '',
          valueWidget: Text(shipment.deliveryPartner!, style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),

      if ((shipment.trackingNumber ?? '').isNotEmpty)
        _InfoRow(label: getTranslated('tracking_number', context) ?? '',
          valueWidget: Text(shipment.trackingNumber!, style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),

      if ((shipment.shipmentStatus ?? '').isNotEmpty)
        _InfoRow(label: getTranslated('shipment_status', context) ?? '',
          valueWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
            decoration: BoxDecoration(
              color: toneColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Text(getTranslated(shipment.shipmentStatus, context) ?? shipment.shipmentStatus!,
              style: titilliumBold.copyWith(color: toneColor, fontSize: Dimensions.fontSizeSmall)),
          )),

      if (shipment.deliveryFee != null)
        _InfoRow(label: getTranslated('delivery_fee', context) ?? '',
          valueWidget: Text(PriceConverter.convertPrice(context, shipment.deliveryFee),
            style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),

      if ((shipment.dispatchedAt ?? '').isNotEmpty)
        _InfoRow(label: getTranslated('dispatched_on', context) ?? '',
          valueWidget: Text(shipment.dispatchedAt!, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
          isLast: (shipment.trackingUrl ?? '').isEmpty),

      if ((shipment.trackingUrl ?? '').isNotEmpty)
        _InfoRow(label: getTranslated('live_tracking', context) ?? '',
          valueWidget: InkWell(
            onTap: () => _openTrackingUrl(shipment.trackingUrl!),
            child: Text(getTranslated('open_link', context) ?? '', style: titilliumBold.copyWith(color: Theme.of(context).primaryColor)),
          ),
          isLast: true),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final bool isLast;
  const _InfoRow({required this.label, required this.valueWidget, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Dimensions.marginSizeExtraSmall, top: Dimensions.marginSizeExtraSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          valueWidget,
        ],
      ),
    );
  }
}
