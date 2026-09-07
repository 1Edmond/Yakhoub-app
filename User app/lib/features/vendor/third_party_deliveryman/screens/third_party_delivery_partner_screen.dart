import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/common/basewidgets/custom_search_field_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/common/basewidgets/no_data_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/controllers/third_party_deliveryman_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/models/courier_provider_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/screens/courier_provider_config_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/widgets/courier_provider_card_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/widgets/courier_provider_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/styles.dart';

class ThirdPartyDeliveryPartnerScreen extends StatefulWidget {
  const ThirdPartyDeliveryPartnerScreen({super.key});

  @override
  State<ThirdPartyDeliveryPartnerScreen> createState() => _ThirdPartyDeliveryPartnerScreenState();
}

class _ThirdPartyDeliveryPartnerScreenState extends State<ThirdPartyDeliveryPartnerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThirdPartyDeliverymanController>(context, listen: false).getCourierConfig(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('delivery_partner_integration', context)),
      body: Consumer<ThirdPartyDeliverymanController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.providers.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemCount: 6,
              itemBuilder: (_, __) => const CourierProviderCardShimmerWidget(),
            );
          }

          final List<CourierProviderModel> filteredProviders = controller.providers.where((provider) =>
              (provider.label ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          return RefreshIndicator(
            onRefresh: () => controller.getCourierConfig(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoBannerWidget(
                    icon: Icons.info_outline,
                    color: Theme.of(context).colorScheme.tertiary,
                    text: getTranslated('delivery_partner_config_info', context) ?? '',
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  if (!controller.hasEnabledProvider) _InfoBannerWidget(
                    icon: Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                    text: getTranslated('no_delivery_partner_enabled_warning', context) ?? '',
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text(getTranslated('delivery_partner_list', context) ?? '', style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  CustomSearchFieldWidget(
                    controller: _searchController,
                    hint: getTranslated('search_by_delivery_partner_name', context),
                    prefix: '',
                    showCloseIcon: _searchQuery.isNotEmpty,
                    iconPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  if (filteredProviders.isEmpty)
                    const NoDataScreen(title: 'no_data_found', image: Images.noData)
                  else
                    ...filteredProviders.map((provider) => CourierProviderCardWidget(
                      provider: provider,
                      onToggle: (isEnabled) => controller.toggleProvider(context, provider, isEnabled),
                      onConfigureTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CourierProviderConfigScreen(provider: provider),
                      )),
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoBannerWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InfoBannerWidget({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: Text(text, style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ))),
        ],
      ),
    );
  }
}
