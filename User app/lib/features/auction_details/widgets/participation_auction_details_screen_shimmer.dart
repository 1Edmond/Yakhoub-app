import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/shimmers/auction_card_shimmer_widget.dart';
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
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Auction ID & status badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 120, radius: 4),
                      _ShimmerBox(shimmerColor: shimmerColor, height: 24, width: 70, radius: Dimensions.radiusSmall),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // AuctionCountdownTimerWidget
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(
                    children: [
                      // Flexible label ("Auction ends in" / "Auction starts in")
                      Flexible(
                        child: _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 90, radius: 4),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      ...List.generate(4, (i) => Padding(
                        padding: EdgeInsets.only(left: i > 0 ? Dimensions.paddingSizeSmall : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ShimmerBox(shimmerColor: shimmerColor, height: 40, width: 40, radius: Dimensions.radiusDefault),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            _ShimmerBox(shimmerColor: shimmerColor, height: 8, width: 28, radius: 4),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // ProductImageViewerWidget
                SizedBox(
                  height: 315,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Carousel main image
                      _ShimmerBox(
                        shimmerColor: shimmerColor,
                        height: 300,
                        width: double.infinity,
                        radius: Dimensions.radiusLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // AuctionStatInfoWidget
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  color: shimmerColor,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 80, radius: 4),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 10, radius: 2),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 50, radius: 4),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Row(
                                children: [
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 14, radius: 2),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 30, radius: 4),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 14, radius: 2),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 30, radius: 4),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 75, radius: 4),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 10, radius: 2),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              _ShimmerBox(shimmerColor: shimmerColor, height: 22, width: 90, radius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // AuctionProductInfoWidget
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(shimmerColor: shimmerColor, height: 20, width: 220, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _InfoRowShimmer(shimmerColor: shimmerColor),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 70, radius: 4),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 10, radius: 2),
                              ],
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Flexible(
                            flex: 3,
                            child: _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: double.infinity, radius: 4),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      _InfoRowShimmer(shimmerColor: shimmerColor),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // AuctionProductDetailsWidget
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 130, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 1, width: double.infinity, radius: 0),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(shimmerColor: shimmerColor, height: 16, width: 200, radius: 4),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      ...List.generate(4, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                        child: _ShimmerBox(
                          shimmerColor: shimmerColor,
                          height: 10,
                          width: i == 3 ? 180 : double.infinity,
                          radius: 4,
                        ),
                      )),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _ShimmerBox(
                        shimmerColor: shimmerColor,
                        height: 120,
                        width: double.infinity,
                        radius: Dimensions.radiusDefault,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // BiddingListWidget
                Container(
                  color: shimmerColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeTwelve,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 140, radius: 4),
                          Row(
                            children: [
                              _ShimmerBox(shimmerColor: shimmerColor, height: 20, width: 20, radius: 4),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 70, radius: 4),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeTwelve),

                      ...List.generate(3, (_) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeSmall,
                          horizontal: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: Dimensions.paddingSizeDefault + Dimensions.paddingSizeSmall,
                              child: _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 16, radius: 4),
                            ),

                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 11, width: 110, radius: 4),
                                  const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                                  _ShimmerBox(shimmerColor: shimmerColor, height: 8, width: 70, radius: 4),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    _ShimmerBox(shimmerColor: shimmerColor, height: 11, width: 60, radius: 4),
                                    const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                                    _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 12, radius: 2),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // AuctionInsightsWidget
                Container(
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: Row(
                          children: [
                            _ShimmerBox(shimmerColor: shimmerColor, height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, radius: 4),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 120, radius: 4),
                            const Spacer(),
                            _ShimmerBox(shimmerColor: shimmerColor, height: 20, width: 20, radius: 4),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault,
                          bottom: Dimensions.paddingSizeDefault,
                        ),
                        child: Wrap(
                          spacing: Dimensions.paddingSizeLarge,
                          runSpacing: Dimensions.paddingSizeDefault,
                          children: List.generate(4, (_) => Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ShimmerBox(shimmerColor: shimmerColor, height: 8, width: 70, radius: 4),
                                const SizedBox(height: 4),
                                _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 60, radius: 4),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // AuctionPersonWidget
                Container(
                  color: shimmerColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: Dimensions.iconSizeExtraLarge,
                        width: Dimensions.iconSizeExtraLarge,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 100, radius: 4),
                            const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                            _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: 70, radius: 4),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: _ShimmerBox(shimmerColor: shimmerColor, height: 20, width: 20, radius: 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            ),
          ),

          // AuctionFeatureTagsWidget
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(3, (i) => Padding(
                  padding: EdgeInsets.only(right: i < 2 ? Dimensions.paddingSizeSmall : 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.homePagePadding,
                    ),
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 80, radius: 4),
                      ],
                    ),
                  ),
                )),
              ),
            ),
          ),

          // Similar products header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ShimmerBox(shimmerColor: shimmerColor, height: 14, width: 120, radius: 4),
                  _ShimmerBox(shimmerColor: shimmerColor, height: 12, width: 50, radius: 4),
                ],
              ),
            ),
          ),

          // Similar products grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (_, __) => const AuctionCardShimmerWidget(),
                childCount: 4,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisSpacing: Dimensions.paddingSizeSmall,
                childAspectRatio: 0.60,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: Dimensions.paddingSizeLarge),
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

class _InfoRowShimmer extends StatelessWidget {
  final Color shimmerColor;

  const _InfoRowShimmer({required this.shimmerColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          child: _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: double.infinity, radius: 4),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Flexible(
          flex: 3,
          child: _ShimmerBox(shimmerColor: shimmerColor, height: 10, width: double.infinity, radius: 4),
        ),
      ],
    );
  }
}