class Photo {
  final int id;
  final String photographer;
  final int width;
  final int height;
  final String thumbUrl;
  final String largeUrl;
  final String pageUrl;

  Photo({
    required this.id,
    required this.photographer,
    required this.width,
    required this.height,
    required this.thumbUrl,
    required this.largeUrl,
    required this.pageUrl,
  });

  double get ratio => width / height;

  factory Photo.fromJson(Map<String, dynamic> j) => Photo(
        id: j['id'],
        photographer: j['user'],
        width: j['webformatWidth'],
        height: j['webformatHeight'],
        thumbUrl: j['webformatURL'],
        largeUrl: j['largeImageURL'],
        pageUrl: j['pageURL'],
      );

  // used to saves photos to local storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'user': photographer,
        'webformatWidth': width,
        'webformatHeight': height,
        'webformatURL': thumbUrl,
        'largeImageURL': largeUrl,
        'pageURL': pageUrl,
      };
}