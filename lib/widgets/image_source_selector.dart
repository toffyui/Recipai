import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> showImageSourceSelector(BuildContext context) async {
  return showDialog<XFile?>(
    context: context,
    builder: (context) => const _ImageSourceSelectorDialog(),
  );
}

class _ImageSourceSelectorDialog extends StatelessWidget {
  const _ImageSourceSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    return AlertDialog(
      title: const Text("冷蔵庫の写真を撮ろう"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("ライブラリから選ぶ"),
            onTap: () async {
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, image);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("写真を撮る"),
            onTap: () async {
              final XFile? image = await picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, image);
            },
          ),
        ],
      ),
    );
  }
}
