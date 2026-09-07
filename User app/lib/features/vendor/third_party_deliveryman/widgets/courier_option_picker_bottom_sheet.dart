import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/common/basewidgets/bottom_sheet_topbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/common/basewidgets/custom_search_field_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/third_party_deliveryman/domain/models/courier_provider_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/styles.dart';

Future<String?> showCourierOptionPickerBottomSheet(
  BuildContext context, {
  required String title,
  required List<CourierFieldOptionModel> options,
  String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CourierOptionPickerBottomSheet(title: title, options: options, selectedId: selectedId),
  );
}

class _CourierOptionPickerBottomSheet extends StatefulWidget {
  final String title;
  final List<CourierFieldOptionModel> options;
  final String? selectedId;
  const _CourierOptionPickerBottomSheet({required this.title, required this.options, this.selectedId});

  @override
  State<_CourierOptionPickerBottomSheet> createState() => _CourierOptionPickerBottomSheetState();
}

class _CourierOptionPickerBottomSheetState extends State<_CourierOptionPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<CourierFieldOptionModel> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
  }

  void _filter(String query) {
    setState(() {
      _filteredOptions = widget.options.where((option) =>
          (option.label ?? '').toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
      ),
      child: Column(
        children: [
          const BottomSheetTopBarWidget(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.title, style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: CustomSearchFieldWidget(
              controller: _searchController,
              hint: getTranslated('search', context),
              prefix: '',
              iconPressed: () {},
              onChanged: _filter,
            ),
          ),

          Expanded(
            child: _filteredOptions.isEmpty
                ? Center(child: Text(getTranslated('no_data_found', context) ?? '', style: titilliumRegular))
                : ListView.builder(
                    itemCount: _filteredOptions.length,
                    itemBuilder: (context, index) {
                      final option = _filteredOptions[index];
                      final bool isSelected = option.id == widget.selectedId;
                      return ListTile(
                        title: Text(option.label ?? '', style: titilliumRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )),
                        trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                        onTap: () => Navigator.pop(context, option.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
