import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/transaction/controllers/transaction_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/transaction/widgets/transaction_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/utill/dimensions.dart';

class WalletTransactionListViewWidget extends StatelessWidget {
  final TransactionController? transactionProvider;
  final int? limit;
  const WalletTransactionListViewWidget({super.key, this.transactionProvider, this.limit});

  @override
  Widget build(BuildContext context) {
    final items = transactionProvider!.transactionList!;
    final count = limit != null ? items.length.clamp(0, limit!) : items.length;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => TransactionWidget(transactionModel: transactionProvider!.transactionList![index]),
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: Dimensions.paddingSizeExtraSmall),
    );
  }
}
