import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({Key? key}) : super(key: key);
    
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    if (provider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("今日のレシピ"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (provider.recipeTitle == null &&
        provider.recipeText == null &&
        provider.recipeImageBase64 == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("今日のレシピ"),
        ),
        body: const Center(child: Text("レシピが見つかりません")),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("今日のレシピ"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.recipeTitle != null &&
                  provider.recipeTitle!.isNotEmpty)
                Text(
                  provider.recipeTitle!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              if (provider.recipeImageBase64 != null &&
                  provider.recipeImageBase64!.isNotEmpty)
                Center(
                  child: Image.memory(
                    base64Decode(provider.recipeImageBase64!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              const SizedBox(height: 16),
              if (provider.recipeText != null &&
                  provider.recipeText!.isNotEmpty)
                Text(
                  provider.recipeText!,
                  style: const TextStyle(fontSize: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
