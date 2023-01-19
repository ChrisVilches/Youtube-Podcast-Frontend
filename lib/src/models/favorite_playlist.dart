class FavoritePlaylist {
  FavoritePlaylist(this.title, this.author, this.id);

  FavoritePlaylist.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        author = json['author'] as String,
        title = json['title'] as String;

  String title;
  String author;
  final String id;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'title': title, 'author': author};
}
