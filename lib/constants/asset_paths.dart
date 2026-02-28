class AssetPaths {
  static const String iconsPath = 'assets/icons';
  static const String imagesPath = 'assets/images';

  static String icon(String fileName) => '$iconsPath/$fileName';
  static String image(String fileName) => '$imagesPath/$fileName';
}
