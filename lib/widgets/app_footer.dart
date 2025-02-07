import 'package:flutter/material.dart';
import '../pages/favorite_recipes_page.dart';
import '../pages/ingredient_list_page.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key, this.currentIndex}) : super(key: key);
  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex ?? 0,
      onTap: (int index) {
        if (currentIndex != null && index == currentIndex) return;
        switch (index) {
          case 0:
            // お気に入りレシピ一覧ページへ遷移
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const FavoriteRecipesPage()),
            );
            break;
          case 1:
            // 食材一覧ページへ遷移
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const IngredientListPage()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: "レシピ一覧",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.food_bank),
          label: "食材一覧",
        ),
      ],
    );
  }
}
