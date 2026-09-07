import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/domain/models/order_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/extension_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class CourierShipmentInfoCard extends StatelessWidget {
  final CourierShipmentModel shipment;
  const CourierShipmentInfoCard({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    final bool hasInstruction = (shipment.instruction ?? '').isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ((shipment.deliveryPartner ?? '').isNotEmpty)
          _InfoItem(icon: Icons.local_shipping_outlined,
            label: getTranslated('delivery_service_name', context) ?? '', value: shipment.deliveryPartner!),

        if ((shipment.trackingNumber ?? '').isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _InfoItem(icon: Icons.share_location_outlined,
            label: getTranslated('tracking_id', context) ?? '', value: shipment.trackingNumber!),
        ],

        if ((shipment.shipmentStatus ?? '').isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _InfoItem(icon: Icons.local_shipping_outlined,
            label: getTranslated('shipment_status', context) ?? '',
            value: getTranslated(shipment.shipmentStatus, context) ?? shipment.shipmentStatus!.toTitleCase()),
        ],

        if (hasInstruction) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Divider(thickness: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(shipment.instruction!,
            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.titleMedium?.color)),
        ],
      ]),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.titleMedium?.color),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(value, style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }
}
