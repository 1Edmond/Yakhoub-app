import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_bid_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/participation_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/participator/participation_auction_details_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';

class ParticipationAuctionDetailsController extends ChangeNotifier {
  final ParticipationAuctionDetailsServiceInterface participationAuctionDetailsServiceInterface;

  ParticipationAuctionDetailsController({required this.participationAuctionDetailsServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ParticipationAuctionDetailsModel? _auctionDetails;
  ParticipationAuctionDetailsModel? get auctionDetails => _auctionDetails;

  // Resolved integer auction-product id from the detail response, used for
  // secondary calls (bid list etc.) whose endpoints still take an int id.
  int? _auctionProductId;
  int? get auctionProductId => _auctionProductId;

  // Slug of the currently loaded auction, used to refresh the overview after
  // actions (entry fee, bid, save) that only know the integer product id.
  String? _slug;

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

  Future<void> getAuctionProductOverview(BuildContext context, {required String slug, String? auctionStatus, bool silent = false}) async {

    _slug = slug;
    final int productStatus = (auctionStatus == 'live' || auctionStatus == 'upcoming') ? 1 : 0;

    if (!silent) {
      _isLoading = true;
      _auctionDetails = null;
      notifyListeners();
    }

    ApiResponseModel? response;

    try {
      response = await participationAuctionDetailsServiceInterface.getAuctionProductOverview(
          slug: slug, auctionStatus: auctionStatus, productStatus: productStatus);


      if (response?.response?.statusCode == 200) {
        final data = response?.response?.data;
        if (data != null) {
          _auctionDetails = ParticipationAuctionDetailsModel.fromJson(data);
          _auctionProductId = _auctionDetails?.product?.id;
        }
        _isLoading = false;
        notifyListeners();
        if (_auctionProductId != null) {
          getAuctionBidList(productId: _auctionProductId!, silent: silent);
        }
      } else if (response?.response?.statusCode == 404) {
        _isLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('auction_product_not_found', Get.context!), Get.context!, snackBarType: SnackBarType.error);
      } else {
        _isLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('failed_to_load_auction_details', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }


  }

  /// Refreshes the currently loaded auction overview using the stored slug.
  /// Used by actions (entry fee, bid, save) that only hold the integer id.
  Future<void> refreshOverview(BuildContext context, {String? auctionStatus, bool silent = false}) async {
    if (_slug == null) return;
    await getAuctionProductOverview(context, slug: _slug!, auctionStatus: auctionStatus, silent: silent);
  }

  Future<void> getAuctionBidList({
    required int productId,
    bool isMyBid = false,
    bool silent = false,
  }) async {
    if (!silent) {
      _isBidListLoading = true;
      _allBids = [];
      _bidOffset = 1;
      _bidTotalSize = null;
      _isCollapsed = true;
      notifyListeners();
    }

    try {
      final response = await participationAuctionDetailsServiceInterface
          .getAuctionBidList(auctionProductId: productId, isMyBid: isMyBid, offset: 1, limit: _bidLimit);
      if (response?.response?.statusCode == 200) {
        final data = response?.response?.data;
        print("--->> bid list response: $data");
        if (data != null) {
          print("--->> bid list response 1: $data");
          final model = AuctionBidListModel.fromJson(data);
          print("--->> bid list response 2: $data");
          _bidTotalSize = model.totalSize;
          _allBids = model.bids ?? [];
          _bidListModel = model;
        }
      }
    } catch (_) {}

    if (!silent) _isBidListLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreBids({required int productId, bool isMyBid = false}) async {
    if (_isBidPaginating || !hasMoreBids) return;

    _isBidPaginating = true;
    notifyListeners();

    final nextOffset = _bidOffset + 1;

    try {
      final response = await participationAuctionDetailsServiceInterface
          .getAuctionBidList(auctionProductId: productId, isMyBid: isMyBid, offset: nextOffset, limit: _bidLimit);
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

  void clearAuctionDetails() {
    _auctionDetails = null;
    _bidListModel = null;
    notifyListeners();
  }
}