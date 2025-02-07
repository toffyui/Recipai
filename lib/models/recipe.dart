class Recipe {
  final String title;
  final String text;
  final String imageBase64;

  Recipe({
    required this.title,
    required this.text,
    required this.imageBase64,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'text': text,
    'imageBase64': imageBase64,
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    title: json['title'],
    text: json['text'],
    imageBase64: json['imageBase64'],
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.title == title; // タイトルをユニークキーとする
  }

  @override
  int get hashCode => title.hashCode;
}
