import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/ingredient_data.dart';

class AppProvider extends ChangeNotifier {
  XFile? uploadedImage;
  
  List<String> ingredientNames = [];
  String? recipeTitle;
  String? recipeText;
  String? recipeImageBase64;
  
  bool isLoading = false;
  String? errorMessage;
  
  final ImagePicker _picker = ImagePicker();
  
  Future<void> pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      uploadedImage = pickedImage;
      notifyListeners();
    }
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
      
      final url = Uri.parse(dotenv.env["DETECT_INGREDIENTS_URL"]!);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image}),
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
}
