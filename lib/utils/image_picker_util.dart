import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';
import '../widgets/image_source_selector.dart';

Future<XFile?> pickAndSaveImage(BuildContext context) async {
  final XFile? image = await showImageSourceSelector(context);
  if (image != null) {
    Provider.of<AppProvider>(context, listen: false).uploadedImage = image;
    Provider.of<AppProvider>(context, listen: false).notifyListeners();
    return image;
  }
  return null;
}
