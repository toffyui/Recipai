import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/ingredient_data.dart';
import '../models/recipe.dart';
import '../widgets/image_source_selector.dart';

class AppProvider extends ChangeNotifier {
  XFile? uploadedImage;
  
  List<String> ingredientNames = [];
  String? recipeTitle;
  String? recipeText;
  String? recipeImageBase64;
  List<Recipe> favoriteRecipes = [];
  
  bool isLoading = false;
  String? errorMessage;
  
  AppProvider() {
    _loadFavoriteRecipes();
  }
  
  Future<void> analyzeImage() async {
    if (uploadedImage == null) return;
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      final file = File(uploadedImage!.path);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final mimeType = uploadedImage!.mimeType ?? 'image/jpeg';
      final url = Uri.parse(dotenv.env["DETECT_INGREDIENTS_URL"]!);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image, "mime_type": mimeType}),
      );
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded["ingredients"] is List) {
          ingredientNames = (decoded["ingredients"] as List)
              .map((e) => e.toString())
              .toList();
        } else {
          errorMessage = "予期しないAPIレスポンスです";
        }
      } else {
        errorMessage = "APIエラー: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "画像解析に失敗しました: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  void addIngredient(String name) {
    if (name.isNotEmpty) {
      ingredientNames.add(name);
      notifyListeners();
    }
  }
  
  void removeIngredient(int index) {
    if (index >= 0 && index < ingredientNames.length) {
      ingredientNames.removeAt(index);
      notifyListeners();
    }
  }
  
  Future<void> generateRecipe(String mood) async {
    if (ingredientNames.isEmpty) return;
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      final url = Uri.parse(dotenv.env["GENERATE_RECIPE_URL"]!);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ingredients": ingredientNames,
          "feeling": mood,
        }),
      );
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final title = decoded["title"] as String? ?? "";
        final steps = decoded["steps"] as List? ?? [];
        final imageBase64 = decoded["image_base64"] as String? ?? "";
        recipeTitle = title;
        recipeText = steps.join("\n");
        recipeImageBase64 = imageBase64;
      } else {
        errorMessage = "レシピ生成APIエラー: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "レシピ生成に失敗しました: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Recipe? get currentRecipe {
    if (recipeTitle != null &&
        recipeText != null &&
        recipeImageBase64 != null &&
        recipeTitle!.isNotEmpty &&
        recipeText!.isNotEmpty &&
        recipeImageBase64!.isNotEmpty) {
      return Recipe(
        title: recipeTitle!,
        text: recipeText!,
        imageBase64: recipeImageBase64!,
      );
    }
    return null;
  }
  bool isCurrentRecipeFavorite() {
    final current = currentRecipe;
    if (current == null) return false;
    return favoriteRecipes.contains(current);
  }
  void toggleFavoriteCurrentRecipe() {
    final current = currentRecipe;
    if (current == null) return;
    if (favoriteRecipes.contains(current)) {
      favoriteRecipes.remove(current);
    } else {
      favoriteRecipes.add(current);
    }
    notifyListeners();
    _saveFavoriteRecipes();
  }
  Future<void> _loadFavoriteRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteList = prefs.getStringList("favoriteRecipes");
    if (favoriteList != null) {
      favoriteRecipes = favoriteList.map((jsonString) {
        final Map<String, dynamic> data = jsonDecode(jsonString);
        return Recipe.fromJson(data);
      }).toList();
      notifyListeners();
    }
  }
  Future<void> _saveFavoriteRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        favoriteRecipes.map((recipe) => jsonEncode(recipe.toJson())).toList();
    await prefs.setStringList("favoriteRecipes", jsonList);
  }
}
