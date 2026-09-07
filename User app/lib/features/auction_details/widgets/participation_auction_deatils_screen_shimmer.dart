import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ParticipationAuctionDetailsScreenShimmer extends StatelessWidget {
  const ParticipationAuctionDetailsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context).darkTheme;
    final Color shimmerColor = isDark
        ? Theme.of(context).primaryColor.withValues(alpha: .05)
        : Theme.of(context).cardColor;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Colors.grey[300]!,
      enabled: true,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ShimmerBox(
                          shimmerColor: shimmerColor,
                          height: 14,
                          width: 160,
                          radius: 4),
                      _ShimmerBox(
                          shimmerColor: shimmerColor,
                          height: 24,
                          width: 80,
                          radius: Dimensions.radiusSmall),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: _ShimmerBox(
                    shimmerColor: shimmerColor,
                    height: 300,
                    width: double.infinity,
                    radius: Dimensions.radiusLarge,
                  ),
                ),


                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius:
                      BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) => Padding(
                        padding: EdgeInsets.only(right: i != 4 ? Dimensions.paddingSizeSmall : 0),
                        child: _ShimmerBox(
                          shimmerColor:
                          shimmerColor.withValues(alpha: .6),
                          height: 40,
                          width: 40,
                          radius: Dimensions.radiusDefault,
                        ),
                      )),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  color: shimmerColor,
                  child: IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _ShimmerBox(
                                      shimmerColor: shimmerColor.withValues(alpha: .7), height: 12, width: 90, radius: 4),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .7), height: 12, width: 12, radius: 6),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .7), height: 12, width: 50, radius: 4),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Row(
                                children: [
                                  _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .7), height: 14, width: 14, radius: 7),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .7), height: 12, width: 28, radius: 4),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),

                                  _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .7), height: 14, width: 14, radius: 7),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .7), height: 12, width: 28, radius: 4),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: shimmerColor.withValues(alpha: .6),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .5), height: 12, width: 80, radius: 4),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .5), height: 12, width: 12, radius: 6),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              _ShimmerBox(shimmerColor: shimmerColor.withValues(alpha: .5), height: 22, width: 80, radius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(shimmerColor: shimmerColor, height: 20, width: 220, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      ...List.generate(3, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: double.infinity, radius: 4),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeDefault),

                            Flexible(
                              flex: 3,
                              child: _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: double.infinity, radius: 4)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(shimmerColor: shimmerColor, height: 16, width: 70, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 16, width: 200, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      ...List.generate(4, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                        child: _ShimmerBox(shimmerColor: shimmerColor, height: 11, width: i == 3 ? 160 : double.infinity, radius: 4))),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 120, width: double.infinity, radius: Dimensions.radiusDefault),
                    ],
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final Color shimmerColor;
  final double height;
  final double width;
  final double radius;

  const _ShimmerBox({
    required this.shimmerColor,
    required this.height,
    required this.width,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: shimmerColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}