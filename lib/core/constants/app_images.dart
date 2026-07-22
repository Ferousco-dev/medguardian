abstract final class AppImages {
  static const List<String> hospitals = <String>[
    'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
    'https://images.unsplash.com/photo-1586773860418-d37222d8fce3',
    'https://images.unsplash.com/photo-1538108149393-fbbd81895907',
    'https://images.unsplash.com/photo-1626315869436-d6781ba69d6e',
    'https://images.unsplash.com/photo-1517120026326-d87759a7b63b',
  ];

  static const List<String> providers = <String>[
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d',
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d',
    'https://images.unsplash.com/photo-1594824476967-48c8b964273f',
    'https://images.unsplash.com/photo-1582750433449-648ed127bb54',
  ];

  static String sized(String url, {int width = 800, int quality = 70}) {
    return '$url?auto=format&fit=crop&w=$width&q=$quality';
  }

  const AppImages._();
}
