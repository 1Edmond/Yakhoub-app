import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class CourierProviderCardShimmerWidget extends StatelessWidget {
  const CourierProviderCardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
      ),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
        highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 140, decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  )),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Container(height: 18, width: 90, decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  )),
                ],
              ),
            ),

            Container(height: 24, width: 44, decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Container(height: 34, width: 34, decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            )),
          ],
        ),
      ),
    );
  }
}
