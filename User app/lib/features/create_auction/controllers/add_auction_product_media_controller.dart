import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/domain/models/media_file_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/image_size_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class AddAuctionProductMediaController extends ChangeNotifier {
  XFile? _thumbnailFile;
  XFile? get thumbnailFile => _thumbnailFile;
  String? _existingThumbnailUrl;
  String? get existingThumbnailUrl => _existingThumbnailUrl;
  XFile? _seoThumbnailFile;
  XFile? get seoThumbnailFile => _seoThumbnailFile;
  String? _existingSeoThumbnailUrl;
  String? get existingSeoThumbnailUrl => _existingSeoThumbnailUrl;
  bool _seoOverridden = false;
  bool get seoOverridden => _seoOverridden;
  bool _seoExplicitlyCleared = false;
  bool get seoExplicitlyCleared => _seoExplicitlyCleared;
  XFile? get effectiveThumbnail => _thumbnailFile;
  String? get effectiveThumbnailUrl => _existingThumbnailUrl;

  XFile? get effectiveSeoThumbnail {
    if (_seoExplicitlyCleared) return null;
    return _seoOverridden ? _seoThumbnailFile : _thumbnailFile;
  }

  String? get effectiveSeoThumbnailUrl {
    if (_seoExplicitlyCleared) return null;
    return _seoOverridden ? _existingSeoThumbnailUrl : _existingThumbnailUrl;
  }

  final List<XFile> _productImages = [];
  List<XFile> get productImages => List.unmodifiable(_productImages);

  List<String> _existingImageUrls = [];
  List<String> get existingImageUrls => List.unmodifiable(_existingImageUrls);

  MediaFileModel? _pickedMediaFile;
  MediaFileModel? get pickedMediaFile => _pickedMediaFile;

  String? _existingVideoUrl;
  String? get existingVideoUrl => _existingVideoUrl;

  bool _isPickingMedia = false;
  bool get isPickingMedia => _isPickingMedia;

  void setExistingThumbnail(String url) {
    _existingThumbnailUrl = url;
    notifyListeners();
  }

  void clearExistingThumbnail() {
    _existingThumbnailUrl = null;
    notifyListeners();
  }

  Future<void> pickThumbnail() async {
    final XFile? picked = await ImageValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
      context: Get.context!,
    );
    if (picked == null) return;

    _thumbnailFile = picked;
    _existingThumbnailUrl = null;

    if (!_seoOverridden && !_seoExplicitlyCleared) {
      _seoThumbnailFile = null;
      _existingSeoThumbnailUrl = null;
    }

    notifyListeners();
  }

  void removeThumbnail() {
    _thumbnailFile = null;
    _existingThumbnailUrl = null;
    if (!_seoOverridden && !_seoExplicitlyCleared) {
      _seoThumbnailFile = null;
      _existingSeoThumbnailUrl = null;
    }
    notifyListeners();
  }

  void setExistingSeoThumbnail(String url) {
    _existingSeoThumbnailUrl = url;
    _seoOverridden = true;
    _seoExplicitlyCleared = false;
    notifyListeners();
  }

  Future<void> pickSeoThumbnail() async {
    final XFile? picked = await ImageValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
      context: Get.context!,
    );
    if (picked == null) return;

    _seoThumbnailFile = picked;
    _existingSeoThumbnailUrl = null;
    _seoOverridden = true;
    _seoExplicitlyCleared = false;
    notifyListeners();
  }

  void removeSeoThumbnail() {
    _seoThumbnailFile = null;
    _existingSeoThumbnailUrl = null;
    _seoOverridden = false;
    _seoExplicitlyCleared = true;
    notifyListeners();
  }

  void setExistingImages(List<String> urls) {
    _existingImageUrls = List.of(urls);
    notifyListeners();
  }

  Future<void> pickProductImage() async {
    final XFile? picked = await ImageValidationHelper.validateAndPickImage(
      source: ImageSource.gallery,
      context: Get.context!,
    );
    if (picked == null) return;

    _productImages.add(picked);
    notifyListeners();
  }

  void removeProductImage(int index) {
    if (index < 0) return;

    final int existingCount = _existingImageUrls.length;

    if (index < existingCount) {
      _existingImageUrls.removeAt(index);
    } else {
      final int newIndex = index - existingCount;
      if (newIndex < _productImages.length) {
        _productImages.removeAt(newIndex);
      }
    }

    notifyListeners();
  }

  Future<void> pickSingleMedia() async {
    _isPickingMedia = true;
    notifyListeners();

    final configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: [...AppConstants.videoExtensions],
    );

    if (result == null || result.files.isEmpty) {
      _isPickingMedia = false;
      notifyListeners();
      return;
    }

    final PlatformFile file = result.files.first;
    final String extension = file.extension?.toLowerCase() ?? '';

    final bool isValidExtension = [
      ...AppConstants.videoExtensions,
    ].contains(extension);

    if (!isValidExtension) {
      showCustomSnackBarWidget(getTranslated('invalid_file_type', Get.context!), Get.context!, snackBarType: SnackBarType.error);
      _isPickingMedia = false;
      notifyListeners();
      return;
    }

    final bool isVideo = AppConstants.videoExtensions.contains(extension);

    if (isVideo) {
      final double fileSizeMB = await ImageValidationHelper.getImageSizeFromXFile(file.xFile);
      final double maxSizeMB = (configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.maxSizeOfASingleFile).toDouble();

      if (fileSizeMB > maxSizeMB) {
        showCustomSnackBarWidget('${getTranslated('maximum_file_size', Get.context!)} ${maxSizeMB}MB', Get.context!, snackBarType: SnackBarType.warning);
        _isPickingMedia = false;
        notifyListeners();
        return;
      }

      final String? thumbnailPath = await _generateVideoThumbnail(file.path ?? '');
      if (thumbnailPath != null) {
        _pickedMediaFile = MediaFileModel(
          file: file.xFile,
          thumbnailPath: thumbnailPath,
          isVideo: true,
        );
      }
    } else {
      final double fileSizeMB = await ImageValidationHelper.getImageSizeFromXFile(file.xFile);
      final double maxImageSizeMB = (configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit).toDouble();

      if (fileSizeMB > maxImageSizeMB) {
        showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${maxImageSizeMB}MB', Get.context!, snackBarType: SnackBarType.warning);
        _isPickingMedia = false;
        notifyListeners();
        return;
      }

      _pickedMediaFile = MediaFileModel(
        file: file.xFile,
        thumbnailPath: file.path,
        isVideo: false,
      );
    }

    _isPickingMedia = false;
    notifyListeners();
  }

  void setExistingVideoUrl(String url) {
    _existingVideoUrl = url;
    notifyListeners();
  }

  void removeExistingVideo() {
    _existingVideoUrl = null;
    notifyListeners();
  }

  void removeMediaFile() {
    _pickedMediaFile = null;
    _existingVideoUrl = null;
    notifyListeners();
  }

  Future<String?> _generateVideoThumbnail(String filePath) async {
    final directory = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: filePath,
      thumbnailPath: directory.path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 100,
      maxWidth: 200,
      quality: 1,
    );
    return thumbnailPath.path;
  }

  void reset() {
    _thumbnailFile = null;
    _existingThumbnailUrl = null;
    _seoThumbnailFile = null;
    _existingSeoThumbnailUrl = null;
    _seoOverridden = false;
    _seoExplicitlyCleared = false;
    _productImages.clear();
    _existingImageUrls.clear();
    _pickedMediaFile = null;
    _existingVideoUrl = null;
    _isPickingMedia = false;
    notifyListeners();
  }
}