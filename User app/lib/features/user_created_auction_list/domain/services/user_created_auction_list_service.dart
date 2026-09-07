import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/repository/user_created_auction_list_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/services/user_created_auction_list_service_interface.dart';

class UserCreatedAuctionListService implements UserCreatedAuctionListServiceInterface {
  final UserCreatedAuctionListRepositoryInterface userCreatedAuctionListRepositoryInterface;
  UserCreatedAuctionListService({required this.userCreatedAuctionListRepositoryInterface});

  @override
  Future getMyAuctionList({
    required int offset,
    required String auctionStatus,
    int limit = 10,
    bool includeCounts = false,
  }) async {
    return await userCreatedAuctionListRepositoryInterface.getMyAuctionList(offset: offset, auctionStatus: auctionStatus, limit: limit, includeCounts: includeCounts);
  }
}