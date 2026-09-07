import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/controller/auction_transaction_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AuctionTransactionFilterBottomSheetWidget extends StatefulWidget {
  final int? searchAuctionId;
  const AuctionTransactionFilterBottomSheetWidget({super.key, this.searchAuctionId});

  @override
  State<AuctionTransactionFilterBottomSheetWidget> createState() => _AuctionTransactionFilterBottomSheetWidgetState();
}

class _AuctionTransactionFilterBottomSheetWidgetState extends State<AuctionTransactionFilterBottomSheetWidget> {
  static const List<String> _filterTypeList = ['all', 'credit', 'debit'];
  static const List<String> _durationTypeList = ['all', 'month', 'year', 'custom'];

  @override
  void initState() {
    super.initState();
    Provider.of<AuctionTransactionController>(context, listen: false).initFilterData();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Consumer<AuctionTransactionController>(builder: (context, controller, _) {
      return Container(
        constraints: BoxConstraints(maxHeight: size.height * 0.75),
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.paddingSizeTwelve),
            topRight: Radius.circular(Dimensions.paddingSizeTwelve),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: .05),
              blurRadius: 17.89,
              offset: const Offset(0, 4.77),
            ),
          ],
        ),
        child: Column(children: [
          const _FilterTitleWidget(),
          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),

          Expanded(child: SingleChildScrollView(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                child: Text(
                  getTranslated('transaction_type', context)!,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: SizedBox(
                  height: 60,
                  width: size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterTypeList.length,
                    itemBuilder: (context, index) {
                      final isSelected = _filterTypeList[index] == (controller.selectedFilterBy ?? 'all');
                      return InkWell(
                        onTap: () => controller.setSelectedFilterBy(type: _filterTypeList[index]),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 50),
                            decoration: BoxDecoration(
                              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor),
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                            ),
                            child: Center(child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Text(
                                getTranslated(_filterTypeList[index], context)!,
                                style: textRegular.copyWith(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor),
                              ),
                            )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),
              Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),

              // Duration
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                child: Text(
                  getTranslated('duration_type', context)!,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(width: .7, color: Theme.of(context).hintColor.withValues(alpha: .3)),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedDurationType,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    items: _durationTypeList.map((String value) {
                      final label = value == 'all' ? 'all'
                          : value == 'month' ? 'this_month'
                          : value == 'year' ? 'this_year'
                          : 'custom';
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(getTranslated(label, context)!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) controller.setSelectedDurationType(value);
                    },
                  ),
                ),
              ),

              // Date Range (visible only when custom is selected)
              if (controller.selectedDurationType == 'custom') ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                  child: Text(
                    getTranslated('date_range', context)!,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(children: [
                    Expanded(child: _DatePickerField(
                      label: getTranslated('start_date', context)!,
                      date: controller.startDate,
                      lastDate: controller.endDate,
                      onPicked: (date) => controller.setSelectedDate(startDate: date, endDate: controller.endDate),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: _DatePickerField(
                      label: getTranslated('end_date', context)!,
                      date: controller.endDate,
                      firstDate: controller.startDate,
                      onPicked: (date) => controller.setSelectedDate(startDate: controller.startDate, endDate: date),
                    )),
                  ]),
                ),
              ],

              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          ))),

          // Bottom buttons
          SafeArea(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(
                color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                spreadRadius: 0.5,
                blurRadius: 0.3,
              )],
            ),
            height: 80,
            child: Row(children: [
              Expanded(child: CustomButton(
                buttonText: '${getTranslated('clear_filter', context)}',
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .125),
                buttonHeight: 55,
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                onTap: () {
                  Navigator.pop(context);
                  if (controller.activeFilterCount > 0) {
                    controller.getAuctionTransactionList(
                      context,
                      isRefresh: true,
                      searchAuctionId: widget.searchAuctionId,
                      filterBy: 'all',
                      filterDurationType: 'all',
                      applyFilter: true,
                    );
                  }
                },
              )),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(child: CustomButton(
                buttonText: '${getTranslated('filter', context)}',
                backgroundColor: _canFilter(controller) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                buttonHeight: 55,
                onTap: _canFilter(controller) ? () {
                  controller.getAuctionTransactionList(
                    context,
                    isRefresh: true,
                    searchAuctionId: widget.searchAuctionId,
                    filterBy: controller.selectedFilterBy,
                    filterDurationType: controller.selectedDurationType,
                    startDate: controller.startDate,
                    endDate: controller.endDate,
                    applyFilter: true,
                  );
                  Navigator.pop(context);
                } : null,
              )),
            ]),
          )),
        ]),
      );
    });
  }

  bool _canFilter(AuctionTransactionController controller) {
    return true;
  }
}


class _FilterTitleWidget extends StatelessWidget {
  const _FilterTitleWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Stack(children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              getTranslated('filter_data', context)!,
              style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          Positioned(
            right: 0,
            top: Dimensions.paddingSizeTwelve,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).hintColor.withValues(alpha: .25),
                ),
                child: const Center(child: CustomAssetImageWidget(Images.crossIcon, height: 15)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}


class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?> onPicked;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPicked,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: firstDate ?? DateTime(2000),
            lastDate: lastDate ?? DateTime(2100),
          );
          if (picked != null) onPicked(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(width: .7, color: Theme.of(context).hintColor.withValues(alpha: .3)),
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          ),
          child: Row(children: [
            Expanded(child: Text(
              date != null ? DateFormat('dd MMM yyyy').format(date!) : 'dd-mm-yyyy',
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: date != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
              ),
            )),
            Icon(Icons.calendar_today_outlined, size: 16, color: Theme.of(context).hintColor),
          ]),
        ),
      ),
    ]);
  }
}
