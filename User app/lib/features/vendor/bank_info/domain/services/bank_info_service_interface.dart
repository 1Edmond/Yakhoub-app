import 'package:flutter_sixvalley_ecommerce/features/vendor/features/profile/domain/models/profile_body.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/profile/domain/models/profile_info.dart';

abstract class BankInfoServiceInterface {
  Future<dynamic> getBankList();
  Future<dynamic> chartFilterData(String? type);
  Future<dynamic> updateBank(ProfileInfoModel userInfoModel, ProfileBody seller, String token);
  String getBankToken();
  Future<dynamic> getOrderFilterData(String? type);
}
