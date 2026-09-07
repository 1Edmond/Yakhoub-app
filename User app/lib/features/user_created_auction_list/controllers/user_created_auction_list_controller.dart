import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/enum/user_created_auction_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/models/user_created_auction_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/services/user_created_auction_list_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class UserCreatedAuctionListController extends ChangeNotifier {
  final UserCreatedAuctionListServiceInterface userCreatedAuctionListServiceInterface;
  UserCreatedAuctionListController({required this.userCreatedAuctionListServiceInterface});

  final Map<UserCreatedAuctionStatusEnum, UserCreatedAuctionListModel?> _models = {};
  final Map<UserCreatedAuctionStatusEnum, bool> _loadingStates = {};

  AuctionCounts? _counts;
  AuctionCounts? get counts => _counts;

  UserCreatedAuctionListModel? getModel(UserCreatedAuctionStatusEnum status) => _models[status];

  bool isLoading(UserCreatedAuctionStatusEnum status) => _loadingStates[status] ?? false;

  Future<void> getMyAuctionList(UserCreatedAuctionStatusEnum status, int offset, {bool reload = false,}) async {
    if (reload || offset == 1) {
      _models[status] = null;
      _loadingStates[status] = true;
      notifyListeners();
    }

    final ApiResponseModel apiResponse =
    await userCreatedAuctionListServiceInterface.getMyAuctionList(offset: offset, auctionStatus: status.key, includeCounts: offset == 1);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      final newData = UserCreatedAuctionListModel.fromJson(apiResponse.response!.data);

      if (offset == 1) {
        _models[status] = newData;
        if (newData.counts != null) _counts = newData.counts;
      } else {
        final existing = _models[status];
        existing?.products?.addAll(newData.products ?? []);
        existing?.offset = newData.offset;
        existing?.totalSize = newData.totalSize;
      }

      _loadingStates[status] = false;
    } else {
      _loadingStates[status] = false;
      ApiChecker.checkApi(apiResponse);
    }

    notifyListeners();
  }


}