import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_footer.dart';

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
                Center(
                  child: Text(
                    provider.recipeTitle!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (provider.recipeImageBase64 != null &&
                  provider.recipeImageBase64!.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      base64Decode(provider.recipeImageBase64!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (provider.recipeText != null &&
                  provider.recipeText!.isNotEmpty) 
                ...provider.recipeText!.split('\n').map((line) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      line,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList()
              else
                const SizedBox(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.toggleFavoriteCurrentRecipe();
        },
        backgroundColor: provider.isCurrentRecipeFavorite() ? Colors.red : Colors.grey,
        child: Icon(
          provider.isCurrentRecipeFavorite() ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
