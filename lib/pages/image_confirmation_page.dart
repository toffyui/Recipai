import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'ingredient_list_page.dart';
import '../core/constants/colors.dart';
import '../widgets/loading_widget.dart';
import '../widgets/app_footer.dart';
import '../utils/image_picker_util.dart';

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
                        final res = await pickAndSaveImage(context);
                        if (res != null && appProvider.uploadedImage != null) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: false,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const LoadingWidget(
                        messages: [
                          "RecipAIが食材を分析中...",
                          "20秒ほどかかります...",
                          "あともう少し...",
                          "頑張ってます...",
                          "もうすぐです...",
                          "時間がかかってごめんなさい...",
                        ],
                      );
                    },
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
                child: const Text('食材を確認する'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
