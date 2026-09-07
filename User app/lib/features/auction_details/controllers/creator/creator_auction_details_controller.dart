import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/enum/creator/auction_delivery_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_bid_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/creator/creator_auction_details_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class CreatorAuctionDetailsController extends ChangeNotifier {
  final CreatorAuctionDetailsServiceInterface serviceInterface;

  CreatorAuctionDetailsController({required this.serviceInterface});

  CreatorAuctionProduct? _auctionProduct;
  CreatorAuctionProduct? get auctionProduct => _auctionProduct;

  // Resolved integer auction-product id from the detail response, used for
  // secondary calls (bid list etc.) whose endpoints still take an int id.
  int? _auctionProductId;
  int? get auctionProductId => _auctionProductId;

  DeliveredPayout? _deliveredPayout;

  AuctionWithdrawModel? _auctionWithdraw;
  AuctionWithdrawModel? get auctionWithdraw => _auctionWithdraw;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuctionBidListModel? _bidListModel;
  AuctionBidListModel? get bidListModel => _bidListModel;

  static const int _bidLimit = 10;

  List<AuctionBidItem> _allBids = [];
  List<AuctionBidItem> get allBids => _allBids;

  int _bidOffset = 1;
  int get bidOffset => _bidOffset;

  int? _bidTotalSize;
  int? get bidTotalSize => _bidTotalSize;

  bool _isBidPaginating = false;
  bool get isBidPaginating => _isBidPaginating;

  bool _isCollapsed = true;
  bool get isCollapsed => _isCollapsed;

  bool _isBidListLoading = false;
  bool get isBidListLoading => _isBidListLoading;

  bool _isTrackingUrlSaving = false;
  bool get isTrackingUrlSaving => _isTrackingUrlSaving;

  AuctionDeliveryStatus? _currentDeliveryStatus;
  AuctionDeliveryStatus? get currentDeliveryStatus => _currentDeliveryStatus;

  bool _isDeliveryStatusUpdating = false;
  bool get isDeliveryStatusUpdating => _isDeliveryStatusUpdating;

  double? get commissionAmountToPayToAdmin => _deliveredPayout?.breakdown?.commissionAmount;

  double? get withdrawableAmount => _deliveredPayout?.breakdown?.vendorReceivable;

  bool get isCashOnDeliveryCommission => _deliveredPayout?.claimPaymentMethod == 'cash_on_delivery';

  bool get isAdminCommissionPaid =>
      (_auctionProduct?.isAdminCommissionPaid ?? false) || (_auctionProduct?.hasPendingOfflineCommissionPayment ?? false);

  AuctionTransaction? get codCommissionTransaction {
    final list = _auctionProduct?.transactions;
    if (list == null) return null;
    try {
      return list.firstWhere((t) => t.type == 'commission_payment');
    } catch (_) {
      return null;
    }
  }

  Future<void> getAuctionDetails(BuildContext context, String slug) async {
    _isLoading = true;
    _auctionProduct = null;
    _deliveredPayout = null;
    _auctionWithdraw = null;
    notifyListeners();

    final ApiResponseModel response = await serviceInterface.getAuctionDetails(slug);

    if (response.response != null && response.response!.statusCode == 200) {
      final model = CreatorAuctionDetailsModel.fromJson(response.response!.data);
      _auctionProduct = model.product;
      _auctionProductId = model.product?.id;
      _deliveredPayout = model.deliveredPayout;
      _auctionWithdraw = model.auctionWithdraw;
      if (_auctionProductId != null) {
        await getAuctionBidList(productId: _auctionProductId!);
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getAuctionBidList({
    required int productId,
  }) async {
    _isBidListLoading = true;
    _allBids = [];
    _bidOffset = 1;
    _bidTotalSize = null;
    _isCollapsed = true;
    notifyListeners();

    try {
      final response = await serviceInterface.getAuctionBidList(auctionProductId: productId, offset: 1, limit: _bidLimit);
      if (response?.response?.statusCode == 200) {
        final data = response?.response?.data;
        if (data != null) {
          final model = AuctionBidListModel.fromJson(data);
          _bidTotalSize = model.totalSize;
          _allBids = model.bids ?? [];
          _bidListModel = model;
        }
      }
    } catch (_) {}

    _isBidListLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreBids({required int productId}) async {
    if (_isBidPaginating || !hasMoreBids) return;

    _isBidPaginating = true;
    notifyListeners();

    final nextOffset = _bidOffset + 1;

    try {
      final response = await serviceInterface.getAuctionBidList(auctionProductId: productId, offset: nextOffset, limit: _bidLimit);
      if (response?.response?.statusCode == 200) {
        final data = response?.response?.data;
        if (data != null) {
          final model = AuctionBidListModel.fromJson(data);
          _bidTotalSize = model.totalSize;
          _allBids.addAll(model.bids ?? []);
          _bidOffset = nextOffset;
          _isCollapsed = false;
        }
      }
    } catch (_) {}

    _isBidPaginating = false;
    notifyListeners();
  }

  bool get hasMoreBids {
    if (_bidTotalSize == null) return false;
    return _allBids.length < _bidTotalSize!;
  }

  void collapseBids() {
    if (_allBids.length > _bidLimit) {
      _allBids = _allBids.sublist(0, _bidLimit);
      _bidOffset = 1;
      _isCollapsed = true;
      notifyListeners();
    }
  }

  Future<bool> uploadTrackingUrl(int auctionProductId, String trackingUrl) async {
    _isTrackingUrlSaving = true;
    notifyListeners();

    try {
      ApiResponseModel apiResponse = await serviceInterface.uploadTrackingUrl(auctionProductId, trackingUrl);

      _isTrackingUrlSaving = false;
      notifyListeners();

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        return true;
      } else {
        ApiChecker.checkApi(apiResponse);
        return false;
      }
    } catch (e) {
      _isTrackingUrlSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDeliveryStatus(int auctionProductId, AuctionDeliveryStatus status) async {
    _isDeliveryStatusUpdating = true;
    notifyListeners();

    try {
      final ApiResponseModel apiResponse = await serviceInterface.updateDeliveryStatus(auctionProductId, status);

      _isDeliveryStatusUpdating = false;

      if (apiResponse.response != null) {
        final statusCode = apiResponse.response!.statusCode;
        final data = apiResponse.response!.data;

        if (statusCode == 200) {
          _currentDeliveryStatus = AuctionDeliveryStatus.fromValue(data['delivery_status'] as String?);
          notifyListeners();
          return true;
        } else if (statusCode == 403) {
          // Winner has not completed the claim payment yet
          ApiChecker.checkApi(apiResponse);
        } else if (statusCode == 404) {
          // Auction not found or not owned by this customer
          ApiChecker.checkApi(apiResponse);
        } else if (statusCode == 422) {
          // Invalid value or disallowed state transition
          ApiChecker.checkApi(apiResponse);
        } else {
          ApiChecker.checkApi(apiResponse);
        }
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isDeliveryStatusUpdating = false;
      notifyListeners();
      return false;
    }
  }
}