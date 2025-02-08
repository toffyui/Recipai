import 'package:flutter/material.dart';
import '../pages/favorite_recipes_page.dart';
import '../pages/ingredient_list_page.dart';
import '../core/constants/colors.dart';
import '../utils/image_picker_util.dart';
import '../pages/image_confirmation_page.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key, this.currentIndex}) : super(key: key);
  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: AppColors.accent,
      currentIndex: currentIndex ?? 0,
      onTap: (int index) async {
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
            // 画像選択ページへ遷移
            final res = await pickAndSaveImage(context);
            if (res != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImageConfirmationPage()),
              );
            }
            break;
          case 2:
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
          icon: Icon(Icons.menu_book),
          label: "お気に入り一覧",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_camera),
          label: "冷蔵庫をパシャッ",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.kitchen),
          label: "冷蔵庫の中身",
        ),
      ],
    );
  }
}
