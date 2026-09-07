import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/participation_auction_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_bid_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_entry_fee_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_save_request_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/auction_social_share_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/services/participator/auction_participation_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/notification_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:provider/provider.dart';

class AuctionParticipationController extends ChangeNotifier {
  final AuctionParticipationServiceInterface auctionParticipationServiceInterface;

  AuctionParticipationController({required this.auctionParticipationServiceInterface});

  bool _isEntryFeeLoading = false;
  bool get isEntryFeeLoading => _isEntryFeeLoading;

  bool _isBidLoading = false;
  bool get isBidLoading => _isBidLoading;

  double? _minimumBidRequired;
  double? get minimumBidRequired => _minimumBidRequired;

  void clearMinimumBidRequired() {
    _minimumBidRequired = null;
  }

  bool _isEntryFeePaid = false;
  bool get isEntryFeePaid => _isEntryFeePaid;

  bool _isSaveLoading = false;
  bool get isSaveLoading => _isSaveLoading;

  bool? _isSaved;
  bool? get isSaved => _isSaved;

  bool _isSocialShareLoading = false;
  bool get isSocialShareLoading => _isSocialShareLoading;

  bool _isInvoiceLoading = false;
  bool get isInvoiceLoading => _isInvoiceLoading;

  AuctionSocialShareModel? _socialShareLink;
  AuctionSocialShareModel? get socialShareLink => _socialShareLink;

  AuctionEntryFeeResponseModel? _lastEntryFeeResponse;
  AuctionEntryFeeResponseModel? get lastEntryFeeResponse => _lastEntryFeeResponse;

  AuctionSaveResponseModel? _lastSaveResponse;
  AuctionSaveResponseModel? get lastSaveResponse => _lastSaveResponse;

  bool _isWalletApplied = false;
  bool get isWalletApplied => _isWalletApplied;

  bool _isWalletInsufficient = false;
  bool get isWalletInsufficient => _isWalletInsufficient;


  bool applyWallet({
    required double walletBalance,
    required double entryFee,
  }) {
    if (_isWalletApplied) {
      _isWalletApplied = false;
      _isWalletInsufficient = false;
      notifyListeners();
      return false;
    }
    if (walletBalance >= entryFee) {
      _isWalletApplied = true;
      _isWalletInsufficient = false;
      _selectedPaymentMethodIndex = -1;
      _selectedPaymentMethodName = '';
      _isOfflinePaymentSelected = false;
    } else {
      _isWalletApplied = false;
      _isWalletInsufficient = true;
    }
    notifyListeners();
    return _isWalletApplied;
  }

  void resetWalletApply() {
    _isWalletApplied = false;
    _isWalletInsufficient = false;
    notifyListeners();
  }

  int _selectedPaymentMethodIndex = -1;
  int get selectedPaymentMethodIndex => _selectedPaymentMethodIndex;

  String _selectedPaymentMethodName = '';
  String get selectedPaymentMethodName => _selectedPaymentMethodName;

  void setSelectedPaymentMethod(int index, String name) {
    _selectedPaymentMethodIndex = index;
    _selectedPaymentMethodName = name;
    _isWalletApplied = false;
    _isWalletInsufficient = false;
    _isOfflinePaymentSelected = false;
    notifyListeners();
  }

  void resetPaymentMethodSelection() {
    _selectedPaymentMethodIndex = -1;
    _selectedPaymentMethodName = '';
    notifyListeners();
  }

  bool _isOfflinePaymentSelected = false;
  bool get isOfflinePaymentSelected => _isOfflinePaymentSelected;

  void setOfflinePaymentSelected(bool value) {
    _isOfflinePaymentSelected = value;
    if (value) {
      _isWalletApplied = false;
      _isWalletInsufficient = false;
      _selectedPaymentMethodIndex = -1;
      _selectedPaymentMethodName = '';
    }
    notifyListeners();
  }

  void resetPaymentState() {
    resetWalletApply();
    resetPaymentMethodSelection();
    _isOfflinePaymentSelected = false;
    notifyListeners();
  }

  bool validateEntryFee(
      BuildContext context, {
        required int? auctionProductId,
        required double feeAmount,
        required String? selectedCurrency,
      }) {
    if (auctionProductId == null || auctionProductId <= 0) {
      showCustomSnackBarWidget(getTranslated('please_select_auction_product', context), context, snackBarType: SnackBarType.warning);
      return false;
    }

    if (feeAmount <= 0) {
      showCustomSnackBarWidget(getTranslated('please_enter_valid_fee_amount', context), context, snackBarType: SnackBarType.warning);
      return false;
    }

    if (selectedCurrency == null || selectedCurrency.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_select_currency', context), context, snackBarType: SnackBarType.warning);
      return false;
    }

    if (selectedCurrency.trim().length > 10) {
      showCustomSnackBarWidget(getTranslated('currency_code_too_long', context), context, snackBarType: SnackBarType.warning);
      return false;
    }

    return true;
  }

  bool validateBid(
      BuildContext context, {
        required int? auctionProductId,
        required TextEditingController bidAmountController,
      }) {
    if (auctionProductId == null || auctionProductId <= 0) {
      showCustomSnackBarWidget(getTranslated('please_select_auction_product', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    if (bidAmountController.text.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_enter_bid_amount', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    final double? bidAmount = double.tryParse(bidAmountController.text.trim());
    if (bidAmount == null || bidAmount < 0) {
      showCustomSnackBarWidget(getTranslated('please_enter_valid_bid_amount', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    return true;
  }

  Future<ApiResponseModel?> payAuctionEntryFee(BuildContext context, {required int auctionProductId, required double feeAmount, required String currency, String auctionStatus = '', String paymentMethod = '', int? methodId, String? methodName, Map<String, String>? methodInformations, String? paymentNote}) async {
    _isEntryFeeLoading = true;
    _isEntryFeePaid = false;
    notifyListeners();

    final entryFeeRequest = AuctionEntryFeeRequestModel(
      auctionProductId: auctionProductId,
      feeAmount: feeAmount,
      currency: currency.trim(),
      paymentMethod: paymentMethod,
      methodId: methodId,
      methodName: methodName,
      methodInformations: methodInformations,
      paymentNote: paymentNote,
    );

    ApiResponseModel? response;
    try {
      response = await auctionParticipationServiceInterface.payAuctionEntryFee(entryFeeRequest: entryFeeRequest);

      if (response?.response?.statusCode == 200) {

        final data = response?.response?.data;
        if (data != null) {
          _lastEntryFeeResponse = AuctionEntryFeeResponseModel.fromJson(data);
        }
        _isEntryFeeLoading = false;
        _isEntryFeePaid = true;

        notifyListeners();
        if(data['redirect_link'] == null && data['redirect_link'].toString().isEmpty) {
          showCustomSnackBarWidget(getTranslated('auction_entry_fee_paid_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
        }
        Provider.of<ParticipationAuctionDetailsController>(Get.context!, listen: false).refreshOverview(Get.context!, auctionStatus: auctionStatus);

        final bool hasRedirect = data['redirect_link'] != null && data['redirect_link'].toString().isNotEmpty;
        if (!hasRedirect) {
          unawaited(NotificationHelper.subscribeToAuctionTopics(auctionProductId));
        }

        if (hasRedirect) {
          final String redirectLink = data['redirect_link'];

          RouterHelper.getAuctionDigitalPaymentScreenRoute(
            url: redirectLink,
            action: RouteAction.push,
            onSuccess: () {
              unawaited(NotificationHelper.subscribeToAuctionTopics(auctionProductId));
              Provider.of<ParticipationAuctionDetailsController>(Get.context!, listen: false)
                  .refreshOverview(Get.context!, auctionStatus: auctionStatus);
            },
          );
        }

      } else {
        _isEntryFeeLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      _isEntryFeeLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('auction_entry_fee_payment_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    return response;
  }

  Future<ApiResponseModel?> placeAuctionBid(
      BuildContext context, {
        required int auctionProductId,
        required TextEditingController bidAmountController,
        bool isAutoBid = false,
      }) async {
    _isBidLoading = true;
    notifyListeners();

    final bidRequest = AuctionBidRequestModel(
      auctionProductId: auctionProductId,
      bidAmount: double.tryParse(bidAmountController.text.trim()) ?? 0.0,
      isAutoBid: isAutoBid,
      currencyCode: Provider.of<SplashController>(Get.context!, listen: false).myCurrency?.code,
    );

    ApiResponseModel? response;
    try {
      response = await auctionParticipationServiceInterface.placeAuctionBid(bidRequest: bidRequest);

      if (response?.response?.statusCode == 200) {
        _isBidLoading = false;
        notifyListeners();
        if (!context.mounted) return response;
        showCustomSnackBarWidget(getTranslated('auction_bid_placed_successfully', context), context, snackBarType: SnackBarType.success);
        Provider.of<ParticipationAuctionDetailsController>(context, listen: false).refreshOverview(context);
      } else if (response?.response?.statusCode == 403) {
        _isBidLoading = false;
        final data = response?.response?.data;
        final hasMinimumBidKey = data is Map && data.containsKey('minimum_bid_required');
        if (!hasMinimumBidKey) {
          notifyListeners();
          if (!context.mounted) return response;
          ApiChecker.checkApi(response!, useOverlay: true, overlayContext: context);
        } else {
          _minimumBidRequired = data['minimum_bid_required'] != null ? double.tryParse(data['minimum_bid_required'].toString()) : null;
          notifyListeners();

          if (!context.mounted) return response;
          final convertedAmount = PriceConverter.convertPrice(context, _minimumBidRequired);
          final msg = '${getTranslated('bid_amount_must_be_at_least', context)} $convertedAmount';
          showOverlaySnackBar(context, msg, snackBarType: SnackBarType.error);
        }
      } else {
        _isBidLoading = false;
        notifyListeners();
        if (!context.mounted) return response;
        ApiChecker.checkApi(response!, useOverlay: true, overlayContext: context);
      }
    } catch (e) {
      _isBidLoading = false;
      notifyListeners();
      if (!context.mounted) return response;
      showOverlaySnackBar(context, getTranslated('auction_bid_place_failed', context), snackBarType: SnackBarType.error);
    }
    return response;
  }

  bool _isWithdrawBidLoading = false;
  bool get isWithdrawBidLoading => _isWithdrawBidLoading;

  Future<ApiResponseModel?> withdrawAuctionBid(
    BuildContext context, {
    required int auctionProductId,
  }) async {
    _isWithdrawBidLoading = true;
    notifyListeners();

    ApiResponseModel? response;
    try {
      response = await auctionParticipationServiceInterface.withdrawAuctionBid(
        auctionProductId: auctionProductId,
      );

      if (response?.response?.statusCode == 200) {
        _isWithdrawBidLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('bid_withdrawn_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
        Provider.of<ParticipationAuctionDetailsController>(Get.context!, listen: false).refreshOverview(Get.context!);
      } else {
        _isWithdrawBidLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      _isWithdrawBidLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('bid_withdraw_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    return response;
  }

  bool _isRollbackBidLoading = false;
  bool get isRollbackBidLoading => _isRollbackBidLoading;

  Future<ApiResponseModel?> rollbackAuctionBid(
    BuildContext context, {
    required int auctionProductId,
    required double bidAmount,
  }) async {
    _isRollbackBidLoading = true;
    notifyListeners();

    ApiResponseModel? response;
    try {
      response = await auctionParticipationServiceInterface.rollbackAuctionBid(
        auctionProductId: auctionProductId,
        bidAmount: bidAmount,
        currencyCode: Provider.of<SplashController>(Get.context!, listen: false).myCurrency?.code ?? '',
      );

      if (response?.response?.statusCode == 200) {
        _isRollbackBidLoading = false;
        notifyListeners();
        if (!context.mounted) return response;
        showCustomSnackBarWidget(getTranslated('bid_rolled_back_successfully', context), context, snackBarType: SnackBarType.success);
        Provider.of<ParticipationAuctionDetailsController>(context, listen: false).refreshOverview(context);
        if (context.mounted) Navigator.pop(context);
      } else if (response?.response?.statusCode == 422) {
        _isRollbackBidLoading = false;
        notifyListeners();
        final data = response?.response?.data;
        final msg = (data is Map ? data['message']?.toString() : null) ?? '';
        if (msg.isNotEmpty && context.mounted) {
          showOverlaySnackBar(context, msg, snackBarType: SnackBarType.error);
        }
      } else if (response?.response?.statusCode == 403) {
        _isRollbackBidLoading = false;
        notifyListeners();
        final data = response?.response?.data;
        final msg = (data is Map ? data['message']?.toString() : null) ?? '';
        if (context.mounted) {
          showOverlaySnackBar(context, msg.isNotEmpty ? msg : getTranslated('rollback_bid_failed', context), snackBarType: SnackBarType.error);
        }
      } else {
        _isRollbackBidLoading = false;
        notifyListeners();
        if (!context.mounted) return response;
        ApiChecker.checkApi(response!, useOverlay: true, overlayContext: context);
      }
    } catch (e) {
      _isRollbackBidLoading = false;
      notifyListeners();
      if (!context.mounted) return response;
      showOverlaySnackBar(context, getTranslated('rollback_bid_failed', context), snackBarType: SnackBarType.error);
    }
    return response;
  }

  void resetEntryFeePaidStatus() {
    _isEntryFeePaid = false;
    notifyListeners();
  }

  bool validateToggleSave(BuildContext context, {required int? auctionProductId}) {
    if (auctionProductId == null || auctionProductId <= 0) {
      showCustomSnackBarWidget(getTranslated('please_select_auction_product', context), context, snackBarType: SnackBarType.warning);
      return false;
    }
    return true;
  }

  Future<ApiResponseModel?> toggleSaveAuctionProduct(
      BuildContext context, {
        required int auctionProductId,
      }) async {
    _isSaveLoading = true;
    notifyListeners();

    final saveProductRequest = AuctionSaveRequestModel(auctionProductId: auctionProductId);

    ApiResponseModel? response;
    try {
      response = await auctionParticipationServiceInterface.toggleSaveAuctionProduct(
        saveProductRequest: saveProductRequest,
      );

      if (response?.response?.statusCode == 200) {
        final data = response?.response?.data;
        if (data != null) {
          _lastSaveResponse = AuctionSaveResponseModel.fromJson(data);
          _isSaved = _lastSaveResponse!.isSaved;
        }

        Provider.of<ParticipationAuctionDetailsController>(Get.context!, listen: false)
            .refreshOverview(Get.context!);

        _isSaveLoading = false;
        notifyListeners();

        final String messageKey = (_isSaved ?? false) ? 'auction_product_saved_successfully' : 'auction_product_unsaved_successfully';
        showCustomSnackBarWidget(getTranslated(messageKey, Get.context!), Get.context!, snackBarType: SnackBarType.success);
      } else {
        _isSaveLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      _isSaveLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('auction_save_product_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    return response;
  }

  Future<ApiResponseModel?> getAuctionInvoice(int auctionId, BuildContext context) async {
    _isInvoiceLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await auctionParticipationServiceInterface.getAuctionInvoice(auctionId);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      await requestPermissions();
      final downloadsDirectory = Directory('/storage/emulated/0/Download');
      List<int> intList = List<int>.from(apiResponse.response!.data);
      String fileName = 'auction_$auctionId.pdf';
      var filePath = path.join(downloadsDirectory.path, fileName);
      int fileCounter = 1;
      while (await File(filePath).exists()) {
        fileName = 'auction_$auctionId($fileCounter).pdf';
        filePath = path.join(downloadsDirectory.path, fileName);
        fileCounter++;
      }
      final file = File(filePath);
      await file.writeAsBytes(intList);
      await OpenFile.open(filePath);
      showCustomSnackBarWidget(getTranslated('invoice_downloaded_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);
    } else {
      showCustomSnackBarWidget(getTranslated('invoice_download_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
    _isInvoiceLoading = false;
    notifyListeners();
    return apiResponse;
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> getAuctionSocialShareLink(
      BuildContext context, {
        required int productId,
      }) async {
    _isSocialShareLoading = true;
    notifyListeners();
    ApiResponseModel? response;
    try{
      response = await auctionParticipationServiceInterface.getAuctionSocialShareLink(productId: productId);
      if(response?.response?.statusCode == 200) {
        final data = response?.response?.data;
        if (data != null) {
          _socialShareLink = AuctionSocialShareModel.fromJson(data);
          _isSocialShareLoading = false;
          notifyListeners();
        }
      } else if (response?.response?.statusCode == 404) {
        _isSocialShareLoading = false;
        notifyListeners();
        showCustomSnackBarWidget(getTranslated('auction_product_not_found', Get.context!), Get.context!, snackBarType: SnackBarType.error);
      } else {
        _isSocialShareLoading = false;
        notifyListeners();
        ApiChecker.checkApi(response!);
      }
    } catch (e){
      _isSocialShareLoading = false;
      notifyListeners();
      showCustomSnackBarWidget(getTranslated('failed_generate_social_share_link', Get.context!), Get.context!, snackBarType: SnackBarType.error);
    }
  }
}