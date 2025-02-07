import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'ingredient_list_page.dart';
import '../core/constants/colors.dart';
import '../widgets/loading_widget.dart';
import '../widgets/app_footer.dart';

class ImageConfirmationPage extends StatelessWidget {
  const ImageConfirmationPage({Key? key}) : super(key: key);
    
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('冷蔵庫の中身を確認する'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    File(appProvider.uploadedImage!.path),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () async {
                        await appProvider.pickImage();
                        if (appProvider.uploadedImage != null) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const LoadingWidget(message: "食材を解析中..."),
                );
                try {
                  await appProvider.analyzeImage();
                } catch (e) {
                  // TODO エラーハンドリング
                } finally {
                  Navigator.of(context).pop();
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IngredientListPage()),
                );
              },
              child: const Text(
                '食材を確認する',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
