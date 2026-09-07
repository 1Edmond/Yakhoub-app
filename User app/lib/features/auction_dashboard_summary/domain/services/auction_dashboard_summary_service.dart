import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/repository/auction_dashboard_summary_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_dashboard_summary/domain/services/auction_dashboard_summary_service_interface.dart';

class AuctionDashboardSummaryService implements AuctionDashboardSummaryServiceInterface {
  final AuctionDashboardSummaryRepositoryInterface repositoryInterface;
  AuctionDashboardSummaryService({required this.repositoryInterface});

  @override
  Future<dynamic> getAuctionDashboardSummary() async {
    return await repositoryInterface.getAuctionDashboardSummary();
  }
}
