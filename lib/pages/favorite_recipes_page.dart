import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/app_provider.dart';
import 'recipe_page.dart';
import '../widgets/app_footer.dart';

class FavoriteRecipesPage extends StatelessWidget {
  const FavoriteRecipesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final List<Recipe> favorites = provider.favoriteRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("お気に入りレシピ"),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text("お気に入りのレシピはありません"))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: favorites.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final recipe = favorites[index];

                  return InkWell(
                    onTap: () {
                      provider.recipeTitle = recipe.title;
                      provider.recipeText = recipe.text;
                      provider.recipeImageBase64 = recipe.imageBase64;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecipePage(),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: recipe.imageBase64.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(recipe.imageBase64),
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey,
                                      width: double.infinity,
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              recipe.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }
}
