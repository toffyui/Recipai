import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'image_confirmation_page.dart';
import '../core/constants/colors.dart';

class TopPage extends StatelessWidget {
  const TopPage({Key? key}) : super(key: key);
    
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            //   Image.asset(
            //     "assets/recipai.gif",
            //     fit: BoxFit.contain,
            //     ),
              Text(
                "RecipAI",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 36,
                    color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(
                "assets/top_image.png",
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              Text(
                "冷蔵庫をパシャッ\n今日のレシピはAIにお任せ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await appProvider.pickImage();
                  if (appProvider.uploadedImage != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ImageConfirmationPage(),
                      ),
                    );
                  }
                },
                child: const Text("冷蔵庫の写真を撮る"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
