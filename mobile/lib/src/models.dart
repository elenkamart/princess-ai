enum BodyType {
  hourglass('hourglass','Песочные часы'), pear('pear','Груша'), apple('apple','Яблоко'),
  rectangle('rectangle','Прямоугольник'), invertedTriangle('inverted_triangle','Перевёрнутый треугольник');
  const BodyType(this.apiValue,this.title); final String apiValue; final String title;
}
class OutfitItem {
  OutfitItem({required this.name,required this.reason}); final String name; final String reason;
  factory OutfitItem.fromJson(Map<String,dynamic> j)=>OutfitItem(name:j['name'],reason:j['reason']);
}
class PrincessOutfit {
  PrincessOutfit({required this.title,required this.score,required this.items,required this.explanation});
  final String title; final int score; final List<OutfitItem> items; final List<String> explanation;
  factory PrincessOutfit.fromJson(Map<String,dynamic> j)=>PrincessOutfit(
    title:j['title'], score:j['score'],
    items:(j['items'] as List).map((e)=>OutfitItem.fromJson(e)).toList(),
    explanation:(j['explanation'] as List).cast<String>(),
  );
}
