class FavoritePlaylist {
  FavoritePlaylist(this.title, this.id);

  String title;
  final String id;

  String encode() {
    return '$id,$title';
  }

  static FavoritePlaylist fromEncoded(String s) {
    final List<String> parts = s.split(',');
    final String id = parts[0];
    final List<String> nameParts = parts.sublist(1);
    final String title = nameParts.join(',');
    return FavoritePlaylist(title, id);
  }
}
