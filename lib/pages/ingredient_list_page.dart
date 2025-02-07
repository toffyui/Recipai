import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/ingredient_data.dart';
import '../providers/app_provider.dart';
import 'recipe_page.dart';
import '../widgets/loading_widget.dart';
import '../widgets/app_footer.dart';

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
          title: const Text("今日の気分は？"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("あっさり"),
                onTap: () => Navigator.pop(context, "あっさり"),
              ),
              ListTile(
                title: const Text("がっつり"),
                onTap: () => Navigator.pop(context, "がっつり"),
              ),
              ListTile(
                title: const Text("おまかせ"),
                onTap: () => Navigator.pop(context, "おまかせ"),
              ),
            ],
          ),
        );
      },
    );
    
    if (selected != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LoadingWidget(message: "レシピを考案中..."),
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
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("食材リスト"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: provider.ingredientNames.length,
                itemBuilder: (context, index) {
                  final name = provider.ingredientNames[index];
                  final imageUrl = ingredientImages[name] ?? fallbackIngredientImage;
                  
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => provider.removeIngredient(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("食材を追加"),
                      content: TextField(
                        controller: _addController,
                        decoration: const InputDecoration(hintText: "食材名を入力"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("キャンセル"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            provider.addIngredient(_addController.text.trim());
                            _addController.clear();
                            Navigator.pop(context);
                          },
                          child: const Text("追加"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("食材を追加"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isLoading
            ? null
            : () {
                _showMoodDialog(provider);
              },
        label: const Text("レシピを作成する"),
        icon: const Icon(Icons.restaurant_menu),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 1),
    );
  }
}
