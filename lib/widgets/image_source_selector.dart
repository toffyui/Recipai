import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> showImageSourceSelector(BuildContext context) async {
  return showDialog<XFile?>(
    context: context,
    builder: (context) => const _ImageSourceSelectorDialog(),
  );
}

class _ImageSourceSelectorDialog extends StatefulWidget {
  const _ImageSourceSelectorDialog({Key? key}) : super(key: key);

  @override
  State<_ImageSourceSelectorDialog> createState() =>
      _ImageSourceSelectorDialogState();
}

class _ImageSourceSelectorDialogState extends State<_ImageSourceSelectorDialog> {
  bool _isProcessing = false;
  final ImagePicker picker = ImagePicker();

  Future<void> _handlePick(ImageSource source) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    final XFile? image = await picker.pickImage(source: source);
    Navigator.pop(context, image);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("冷蔵庫の写真を撮ろう"),
      content: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("ライブラリから選ぶ"),
                onTap: () => _handlePick(ImageSource.gallery),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("写真を撮る"),
                onTap: () => _handlePick(ImageSource.camera),
              ),
            ],
          ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
