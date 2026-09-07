import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class UserCreatedAuctionListRepositoryInterface implements RepositoryInterface {
  Future<ApiResponseModel> getMyAuctionList({required int offset, required String auctionStatus, int limit = 10, bool includeCounts = false});
}