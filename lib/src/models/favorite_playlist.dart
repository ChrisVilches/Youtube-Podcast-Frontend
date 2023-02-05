class FavoritePlaylist {
  FavoritePlaylist(this.title, this.author, this.id, this.isChannel);

  FavoritePlaylist.fromJson(final Map<String, dynamic> json)
      : id = json['id'] as String,
        author = json['author'] as String,
        isChannel = json['isChannel'] as bool,
        title = json['title'] as String;

  final String title;
  final String author;
  final String id;
  final bool isChannel;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'author': author,
        'isChannel': isChannel
      };
}
