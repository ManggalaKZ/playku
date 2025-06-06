import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playku/app/modules/home/controller/user_controller.dart';
import 'package:playku/core/core.dart';

const String _CLOUDINARY_CLOUD_NAME = 'dotz74j1p';
const String _CLOUDINARY_API_KEY = '983354314759691';
const String _CLOUDINARY_UPLOAD_PRESET = 'yogjjkoh';

class QImagePicker extends StatefulWidget {
  const QImagePicker({
    required this.label,
    required this.onChanged,
    super.key,
    this.value,
    this.validator,
    this.hint,
    this.helper,
    this.extensions = const ['jpg', 'png'],
    this.enabled = true,
  });
  final String label;
  final String? value;
  final String? hint;
  final String? helper;
  final String? Function(String?)? validator;
  final Function(String) onChanged;
  final List<String> extensions;
  final bool enabled;

  @override
  State<QImagePicker> createState() => _QImagePickerState();
}

class _QImagePickerState extends State<QImagePicker> {
  final UserController userController = Get.find<UserController>();

  String? imageUrl;
  bool loading = false;
  late TextEditingController controller;
  @override
  void initState() {
    imageUrl = widget.value;
    controller = TextEditingController(
      text: widget.value ?? '-',
    );
    super.initState();
  }

  Future<String?> getFileMultiplePlatform() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.extensions,
    );
    if (result == null) return null;
    return result.files.first.path;
  }

  Future<String?> getFileAndroidIosAndWeb() async {
    final granted = await requestImagePermissions();
    if (!granted) {
      Get.snackbar(
          "Permission Denied", "Izin dibutuhkan untuk mengakses galeri");
      return null;
    }

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    final filePath = image?.path;
    if (filePath == null) return null;
    return filePath;
  }

  Future<bool> requestImagePermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted ||
          await Permission.storage.isGranted) return true;

      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      } else {
        return false;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  Future<String> uploadToCloudinary(String filePath) async {
    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(
        filePath,
        filename: 'upload.jpg',
      ),
      'upload_preset': _CLOUDINARY_UPLOAD_PRESET,
      'api_key': _CLOUDINARY_API_KEY,
    });

    final res = await dio.Dio().post(
      'https://api.cloudinary.com/v1_1/$_CLOUDINARY_CLOUD_NAME/image/upload',
      data: formData,
    );

    final String url = res.data['secure_url'];
    return url;
  }

  Future<void> browseFile() async {
    if (loading) return;

    String? filePath;

    if (!kIsWeb && Platform.isWindows) {
      filePath = await getFileMultiplePlatform();
    } else {
      filePath = await getFileAndroidIosAndWeb();
    }
    if (filePath == null) return;

    loading = true;
    userController.isUploading.value = true;

    setState(() {});

    imageUrl = await uploadToCloudinary(filePath);

    loading = false;
    userController.isUploading.value = false;

    setState(() {});

    if (imageUrl != null) {
      widget.onChanged(imageUrl!);
      controller.text = imageUrl!;
    }
    setState(() {});
  }

  String? get currentValue {
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Container(
            height: 96,
            width: 96,
            margin: const EdgeInsets.only(
              top: 8,
            ),
            decoration: BoxDecoration(
              color: loading ? Colors.blueGrey[400] : Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              image:
                  (!loading && imageUrl != null && imageUrl!.startsWith('http'))
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: Visibility(
              visible: loading == true,
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      'Uploading...'.tr,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: FormField(
              initialValue: false,
              validator: (value) {
                return widget.validator!(imageUrl);
              },
              builder: (FormFieldState<bool> field) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: widget.label,
                          labelStyle: const TextStyle(
                            color: Colors.blueGrey,
                          ),
                          helperText: widget.helper,
                          hintText: widget.hint,
                          errorText: field.errorText,
                        ),
                        onChanged: (value) {
                          widget.onChanged(value);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    if (widget.enabled)
                      Container(
                        width: 50,
                        height: 46,
                        margin: const EdgeInsets.only(
                          right: 4,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: browseFile,
                          child: const Icon(
                            Icons.file_upload,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
