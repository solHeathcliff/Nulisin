import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Article {
  final String image;
  final String category;
  final String title;
  final String author;
  final String badge;
  final String publishDate;
  final String readTime;
  bool isBookmarked;

  Article({
    required this.image,
    required this.category,
    required this.title,
    required this.author,
    required this.badge,
    required this.publishDate,
    required this.readTime,
    this.isBookmarked = false,
  });

  Map<String, dynamic> toJson() => {
        'image': image,
        'category': category,
        'title': title,
        'author': author,
        'badge': badge,
        'publishDate': publishDate,
        'readTime': readTime,
        'isBookmarked': isBookmarked,
      };

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        image: json['image'] as String,
        category: json['category'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        badge: json['badge'] as String,
        publishDate: json['publishDate'] as String,
        readTime: json['readTime'] as String,
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );
}

class ArticleRepository extends ChangeNotifier {
  static final ArticleRepository instance = ArticleRepository._internal();
  factory ArticleRepository() => instance;

  static const _storageKey = 'nulisin_articles';

  final List<Article> _articles = [];
  bool _isLoaded = false;

  ArticleRepository._internal();

  List<Article> get articles => List.unmodifiable(_articles);
  bool get isLoaded => _isLoaded;

  /// Call once at app startup (in main.dart) to load persisted data.
  Future<void> init() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      // Load persisted articles
      final List<dynamic> decoded = jsonDecode(raw);
      _articles.clear();
      _articles.addAll(decoded.map((e) => Article.fromJson(e as Map<String, dynamic>)));
    } else {
      // First run — seed with default articles
      _articles.addAll(_seedArticles());
      await _persist(prefs);
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addArticle(Article article) async {
    _articles.insert(0, article);
    notifyListeners();
    await _save();
  }

  Future<void> toggleBookmark(Article article) async {
    article.isBookmarked = !article.isBookmarked;
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  Future<void> _persist(SharedPreferences prefs) async {
    final encoded = jsonEncode(_articles.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Default seed data shown on first install.
  List<Article> _seedArticles() => [
        Article(
          image: 'https://picsum.photos/seed/essay1/800/450',
          category: 'Filsafat',
          title: 'Seni Berpikir Lambat di Abad yang Bergerak Cepat',
          author: 'Amara Prasetya',
          badge: 'Penulis Pilihan',
          publishDate: '12 Okt 2023',
          readTime: '7 mnt',
          isBookmarked: false,
        ),
        Article(
          image: 'https://picsum.photos/seed/tech2/800/450',
          category: 'Teknologi',
          title: 'Ketika AI Mulai Memahami Konteks: Era Baru Kecerdasan Buatan',
          author: 'Reza Hadikusuma',
          badge: 'Kontributor',
          publishDate: '10 Okt 2023',
          readTime: '10 mnt',
          isBookmarked: true,
        ),
        Article(
          image: 'https://picsum.photos/seed/sastra1/800/450',
          category: 'Sastra',
          title: 'Pramoedya dan Keberanian Melampaui Batas',
          author: 'Dian Savitri',
          badge: 'Editor',
          publishDate: '08 Okt 2023',
          readTime: '12 mnt',
          isBookmarked: false,
        ),
        Article(
          image: 'https://picsum.photos/seed/essay4/800/450',
          category: 'Esai',
          title: 'Tentang Kesendirian dan Mengapa Kita Membutuhkannya',
          author: 'Nadia Lestari',
          badge: 'Penulis Tamu',
          publishDate: '05 Okt 2023',
          readTime: '5 mnt',
          isBookmarked: false,
        ),
        Article(
          image: 'https://picsum.photos/seed/sci1/800/450',
          category: 'Sains',
          title: 'Mikrobioma Usus: Otak Kedua yang Kita Abaikan',
          author: 'Dr. Fajar Kusuma',
          badge: 'Ilmuwan',
          publishDate: '02 Okt 2023',
          readTime: '9 mnt',
          isBookmarked: true,
        ),
        Article(
          image: 'https://picsum.photos/seed/tr1/800/450',
          category: 'Teknologi',
          title: 'Batas Antara Manusia dan Mesin yang Semakin Kabur',
          author: 'Dr. Riza',
          badge: 'Kontributor',
          publishDate: '11 Okt 2023',
          readTime: '8 mnt',
        ),
        Article(
          image: 'https://picsum.photos/seed/tr2/800/450',
          category: 'Sastra',
          title: 'Puisi Sebagai Perlawanan: Catatan dari Penyair Jalanan',
          author: 'Layla Hassan',
          badge: 'Kontributor',
          publishDate: '09 Okt 2023',
          readTime: '6 mnt',
        ),
        Article(
          image: 'https://picsum.photos/seed/tr3/800/450',
          category: 'Filsafat',
          title: 'Eksistensialisme dan Krisis Identitas Digital',
          author: 'Marcus Tan',
          badge: 'Kontributor',
          publishDate: '01 Okt 2023',
          readTime: '11 mnt',
        ),
      ];
}
