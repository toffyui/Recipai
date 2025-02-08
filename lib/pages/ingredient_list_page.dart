import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/ingredient_data.dart';
import '../providers/app_provider.dart';
import 'recipe_page.dart';
import '../widgets/loading_widget.dart';
import '../widgets/app_footer.dart';
import '../core/constants/colors.dart';

class IngredientListPage extends StatefulWidget {
  const IngredientListPage({Key? key}) : super(key: key);

  @override
  State<IngredientListPage> createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  final TextEditingController _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _showMoodDialog(AppProvider provider) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "今日の気分は？",
              style: TextStyle(fontSize: 20),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text("あっさり"),
                onTap: () => Navigator.pop(context, "light"),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text("がっつり"),
                onTap: () => Navigator.pop(context, "hearty"),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text("おまかせ"),
                onTap: () => Navigator.pop(context, "chef's choice"),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const LoadingWidget(
            messages: [
              "RecipAIが最高のレシピを考えています...",
              "20秒ほどかかります...",
              "もうお腹が空いていますか？",
              "頑張ってレシピを考えています...",
              "もうすぐです..."
            ],
          );
        },
      );
      try {
        await provider.generateRecipe(selected);
      } catch (e) {
        // TODO エラーハンドリング
      } finally {
        Navigator.of(context).pop(); 
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecipePage()),
      );
    }
  }

  /// 部分一致で食材画像を取得する
  String getIngredientImage(String name) {
    final List<MapEntry<String, String>> matchedEntries = ingredientImages.entries
        .where((entry) => name.contains(entry.key))
        .toList();

    if (matchedEntries.isEmpty) {
      return fallbackIngredientImage;
    }
    matchedEntries.sort((a, b) => b.key.length.compareTo(a.key.length));
    return matchedEntries.first.value;
  }

  /// 編集用ポップアップ
  Future<void> _showEditDialog(AppProvider provider, int index) async {
    final currentName = provider.ingredientNames[index];
    final TextEditingController controller =
        TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "食材の編集・削除",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "食材名を入力",
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.removeIngredient(index);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("削除"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        provider.ingredientNames[index] = controller.text.trim();
                        provider.notifyListeners();
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("保存"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 食材追加用ポップアップ
  Future<void> _showAddDialog(AppProvider provider) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "食材の追加",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: TextField(
            controller: _addController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "食材名を入力"),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.addIngredient(_addController.text.trim());
                      _addController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text("食材を追加"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("冷蔵庫の中身一覧"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: provider.ingredientNames.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final name = provider.ingredientNames[index];
                  final imageUrl = getIngredientImage(name);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        _showEditDialog(provider, index);
                      },
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                                  child: Image.asset(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  height: 32,
                                  child: Center(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.edit,
                                  size: 24,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () {
                            _showMoodDialog(provider);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "レシピを作成する",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 0,
                  color: Colors.transparent,
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      _showAddDialog(provider);
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 2),
    );
  }
}
