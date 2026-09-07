import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_details_model.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/controllers/third_party_deliveryman_controller.dart';
import 'package:sixvalley_vendor_app/features/third_party_deliveryman/domain/models/courier_tracking_event_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ThirdPartyDeliveryInfoWidget extends StatelessWidget {
  final Order? orderModel;
  final CourierShipmentModel? courierShipment;
  const ThirdPartyDeliveryInfoWidget({super.key, this.orderModel, this.courierShipment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: ThemeShadow.getShadow(context)

      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getTranslated('third_party_delivery_partner', context) ?? '',
          style: robotoMedium.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
          fontSize: Dimensions.fontSizeLarge,)),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        courierShipment != null ? CourierShipmentCard(shipment: courierShipment!) : _FallbackInfo(orderModel: orderModel),

      ]),
    );
  }
}

class _FallbackInfo extends StatelessWidget {
  final Order? orderModel;
  const _FallbackInfo({this.orderModel});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(
          children: [
            Text('${getTranslated('third_party_delivery_service', context)!} : ',
              style: titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!,
              fontSize: Dimensions.fontSizeDefault)
            ),

            Expanded(
              child: Text(orderModel?.thirdPartyServiceName ?? '',
                style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7,),
                overflow: TextOverflow.ellipsis,
                fontSize: Dimensions.fontSizeDefault),
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

        Row(
          children: [
            Text('${getTranslated('third_party_delivery_tracking_id', context)!} : ',
              style: titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!,
              fontSize: Dimensions.fontSizeDefault)
            ),

            Expanded(
              child: Text(orderModel?.thirdPartyTrackingId ?? '',
                style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                overflow: TextOverflow.ellipsis,
                fontSize: Dimensions.fontSizeDefault),
                maxLines: 2,
              ),
            ),
          ],
        ),

      ],))
    ],
    );
  }
}

class CourierShipmentCard extends StatefulWidget {
  final CourierShipmentModel shipment;
  final bool showTrackingHistoryButton;
  const CourierShipmentCard({super.key, required this.shipment, this.showTrackingHistoryButton = true});

  @override
  State<CourierShipmentCard> createState() => CourierShipmentCardState();
}

class CourierShipmentCardState extends State<CourierShipmentCard> {
  bool _showHistory = false;
  bool _hasLoaded = false;
  List<CourierTrackingEventModel> _events = [];

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
    } else {
      throw 'Could not launch $trackingUrl';
    }
  }

  void _scrollIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ScrollableState? scrollable = Scrollable.maybeOf(context);
      if (scrollable == null) return;
      scrollable.position.animateTo(
        scrollable.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _toggleHistory() async {
    if (_showHistory) {
      setState(() => _showHistory = false);
      return;
    }

    setState(() => _showHistory = true);
    _scrollIntoView();

    final String? consignmentId = widget.shipment.consignmentId;
    if (consignmentId == null || consignmentId.isEmpty) return;

    final result = await Provider.of<ThirdPartyDeliverymanController>(context, listen: false)
        .getTrackingHistory(context, consignmentId);

    if (!mounted) return;
    setState(() {
      _hasLoaded = true;
      _events = result.events;
    });
    _scrollIntoView();
  }

  @override
  Widget build(BuildContext context) {
    final CourierShipmentModel shipment = widget.shipment;
    final Color toneColor = _toneColor(context, shipment.statusTone);
    final bool canTrack = widget.showTrackingHistoryButton
        && (shipment.consignmentId ?? '').isNotEmpty && shipment.canTrack != false;
    final bool isLoadingHistory = context.watch<ThirdPartyDeliverymanController>().isLoadingTrackingHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  valueWidget: Text(shipment.deliveryFee!.toStringAsFixed(2), style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),

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
            ],
          ),
        ),



        if (canTrack) ...[
        const SizedBox(height: Dimensions.paddingSizeDefault),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _toggleHistory,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSize),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
            ),
            icon: Icon(Icons.history, size: 18, color: Theme.of(context).primaryColor),
            label: Text(getTranslated(_showHistory ? 'hide_tracking_history' : 'view_tracking_history', context) ?? '',
                style: titilliumBold.copyWith(color: Theme.of(context).primaryColor)),
          ),
        ),
        ],

        if (canTrack && _showHistory) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: isLoadingHistory
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                    child: Center(child: CircularProgressIndicator()))
                : (_hasLoaded && _events.isEmpty)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Text(getTranslated('no_tracking_history_found', context) ?? '',
                            style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)))
                    : Column(
                        children: List.generate(_events.length, (index) {
                          final CourierTrackingEventModel event = _events[index];
                          return _TrackingEventRow(
                            event: event,
                            color: _toneColor(context, event.tone),
                            isLast: index == _events.length - 1,
                          );
                        }),
                      ),
          ),
        ],
      ],
    );
  }
}

class _TrackingEventRow extends StatelessWidget {
  final CourierTrackingEventModel event;
  final Color color;
  final bool isLast;
  const _TrackingEventRow({required this.event, required this.color, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.label ?? event.status ?? '',
                    style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                if ((event.time ?? '').isNotEmpty || (event.description ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      <String>[
                        if ((event.time ?? '').isNotEmpty) event.time!,
                        if ((event.description ?? '').isNotEmpty) event.description!,
                      ].join(' · '),
                      style: titilliumRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 0, top: Dimensions.paddingSizeSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color)),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          valueWidget,
        ],
      ),
    );
  }
}
