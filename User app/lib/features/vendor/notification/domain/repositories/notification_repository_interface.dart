

import 'package:flutter_sixvalley_ecommerce/features/vendor/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/interface/repository_interface.dart';

abstract class NotificationRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> seenNotification(int id);
  Future<ApiResponse> getAuctionNotificationList({int limit = 10, int offset = 1});
  Future<ApiResponse> markAuctionNotificationSeen({int? id});
}
