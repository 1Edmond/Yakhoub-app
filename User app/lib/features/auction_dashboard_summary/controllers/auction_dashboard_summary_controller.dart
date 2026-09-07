import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/models/auction_dashboard_summary_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/services/auction_dashboard_summary_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class AuctionDashboardSummaryController extends ChangeNotifier {
  final AuctionDashboardSummaryServiceInterface serviceInterface;
  AuctionDashboardSummaryController({required this.serviceInterface});

  AuctionDashboardSummaryModel? _summaryModel;
  AuctionDashboardSummaryModel? get summaryModel => _summaryModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getAuctionDashboardSummary(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final ApiResponseModel response = await serviceInterface.getAuctionDashboardSummary();

    if (response.response != null && response.response!.statusCode == 200) {
      _summaryModel = AuctionDashboardSummaryModel.fromJson(response.response!.data);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    notifyListeners();
  }
}
