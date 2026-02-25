class HomeServiceItem {
  final String key;
  final String name;
  final String svg;

  const HomeServiceItem({
    required this.key,
    required this.name,
    required this.svg,
  });

  factory HomeServiceItem.fromJson(Map<String, dynamic> json) {
    return HomeServiceItem(
      key: (json['key'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      svg: (json['svg'] ?? '').toString(),
    );
  }
}
