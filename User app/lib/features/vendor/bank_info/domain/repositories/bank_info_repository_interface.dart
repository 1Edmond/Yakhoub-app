import 'package:http/http.dart' as http;
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/profile/domain/models/profile_body.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/features/profile/domain/models/profile_info.dart';
import 'package:flutter_sixvalley_ecommerce/features/vendor/interface/repository_interface.dart';

abstract class BankInfoRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> chartFilterData(String? type);
  Future<http.StreamedResponse> updateBank(ProfileInfoModel userInfoModel, ProfileBody seller, String token);
  String getBankToken();
  Future<ApiResponse> getOrderFilterData(String? type);
}
