import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class AuctionDashboardSummaryRepositoryInterface implements RepositoryInterface {
  Future<ApiResponseModel> getAuctionDashboardSummary();
}
