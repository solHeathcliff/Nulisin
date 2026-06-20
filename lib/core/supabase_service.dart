import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// MODELS
// ============================================================

class ProfileModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? profession;
  final String? interests;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.profession,
    this.interests,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        fullName: json['full_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        profession: json['profession'] as String?,
        interests: json['interests'] as String?,
        bio: json['bio'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'profession': profession,
        'interests': interests,
        'bio': bio,
      };
}

class ArticleModel {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String? coverImageUrl;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  // Joined fields
  ProfileModel? author;
  List<CategoryModel> categories;
  int commentCount;

  ArticleModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.coverImageUrl,
    required this.isPublished,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.author,
    this.categories = const [],
    this.commentCount = 0,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    ProfileModel? author;
    if (json['profiles'] != null) {
      author = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    List<CategoryModel> cats = [];
    if (json['article_categories'] is List) {
      cats = (json['article_categories'] as List)
          .where((e) => e['categories'] != null)
          .map((e) => CategoryModel.fromJson(e['categories'] as Map<String, dynamic>))
          .toList();
    }

    return ArticleModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      isPublished: json['is_published'] as bool? ?? true,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      viewCount: (json['view_count'] as int?) ?? 0,
      author: author,
      categories: cats,
    );
  }

  String get readTimeEstimate {
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes mnt';
  }

  String get formattedDate {
    if (publishedAt == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${publishedAt!.day} ${months[publishedAt!.month - 1]} ${publishedAt!.year}';
  }

  String get categoryName => categories.isNotEmpty ? categories.first.name : 'Umum';
}

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        coverImageUrl: json['cover_image_url'] as String?,
      );
}

class CommentModel {
  final String id;
  final String articleId;
  final String userId;
  final String content;
  final DateTime createdAt;
  ProfileModel? author;

  CommentModel({
    required this.id,
    required this.articleId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    ProfileModel? author;
    if (json['profiles'] != null) {
      author = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }
    return CommentModel(
      id: json['id'] as String,
      articleId: json['article_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: author,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} mnt lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    if (diff.inDays < 30) return '${diff.inDays} hari lalu';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }
}

// ============================================================
// SUPABASE SERVICE
// ============================================================

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  factory SupabaseService() => instance;
  SupabaseService._internal();

  // Credentials — ganti dengan credentials Supabase project Anda
  static const String supabaseUrl = 'https://azssocqcrxbhlieuftkk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF6c3NvY3FjcnhiaGxpZXVmdGtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExODM1MjksImV4cCI6MjA5Njc1OTUyOX0.cmmTS7xOd0I75EY4-DRIjFujKyQNdJE-lhnshCgiP0c';

  SupabaseClient get _client => Supabase.instance.client;

  final ValueNotifier<ProfileModel?> profileNotifier = ValueNotifier<ProfileModel?>(null);
  final ValueNotifier<int> articleRefreshTrigger = ValueNotifier<int>(0);
  final ValueNotifier<Set<String>> bookmarkedIdsNotifier = ValueNotifier<Set<String>>({});
  final ValueNotifier<List<ArticleModel>> bookmarkedArticlesNotifier = ValueNotifier<List<ArticleModel>>([]);

  // ─── AUTH ──────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    profileNotifier.value = null;
    bookmarkedIdsNotifier.value = {};
    bookmarkedArticlesNotifier.value = [];
  }

  Future<void> deleteCurrentUser() async {
    await _client.rpc('delete_user');
    await signOut();
  }

  // ─── PROFILES ─────────────────────────────────────────────

  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    final profile = ProfileModel.fromJson(data);
    profileNotifier.value = profile;
    fetchBookmarks();
    return profile;
  }

  Future<ProfileModel> upsertProfile({
    required String userId,
    required String fullName,
    String? profession,
    String? interests,
    String? bio,
    String? avatarUrl,
  }) async {
    final payload = {
      'id': userId,
      'full_name': fullName,
      if (profession != null) 'profession': profession,
      if (interests != null) 'interests': interests,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    final data = await _client
        .from('profiles')
        .upsert(payload)
        .select()
        .single();
    final profile = ProfileModel.fromJson(data);
    profileNotifier.value = profile;
    return profile;
  }

  Future<String?> uploadAvatar(String userId, dynamic file) async {
    final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      if (kIsWeb) {
        await _client.storage
            .from('avatars')
            .uploadBinary(path, file as Uint8List,
                fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'));
      } else {
        await _client.storage
            .from('avatars')
            .upload(path, file as File,
                fileOptions: const FileOptions(upsert: true));
      }
      return _client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      return null;
    }
  }

  // ─── BOOKMARKS ─────────────────────────────────────────────

  Future<void> fetchBookmarks() async {
    final userId = currentUser?.id;
    if (userId == null) {
      bookmarkedIdsNotifier.value = {};
      bookmarkedArticlesNotifier.value = [];
      return;
    }
    try {
      final data = await _client
          .from('bookmarks')
          .select('article_id')
          .eq('user_id', userId);
      final ids = (data as List).map((e) => e['article_id'] as String).toSet();
      bookmarkedIdsNotifier.value = ids;

      if (ids.isEmpty) {
        bookmarkedArticlesNotifier.value = [];
        return;
      }
      // Ambil data artikel untuk semua yang disimpan
      final idsList = ids.join(',');
      final articlesData = await _client
          .from('articles')
          .select('''
            *,
            profiles(*),
            article_categories(category_id, categories(*))
          ''')
          .eq('is_published', true)
          .or('id.in.($idsList)');
      bookmarkedArticlesNotifier.value =
          (articlesData as List).map((e) => ArticleModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('fetchBookmarks error: $e');
    }
  }

  Future<void> toggleBookmark(String articleId) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    final currentIds = Set<String>.from(bookmarkedIdsNotifier.value);
    final isSaved = currentIds.contains(articleId);

    try {
      if (isSaved) {
        // UNSAVE — hapus instan dari kedua notifier
        currentIds.remove(articleId);
        bookmarkedIdsNotifier.value = currentIds;
        bookmarkedArticlesNotifier.value = bookmarkedArticlesNotifier.value
            .where((a) => a.id != articleId)
            .toList();
        await _client
            .from('bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq('article_id', articleId);
      } else {
        // SAVE — tambah ID instan, lalu fetch 1 artikel untuk data lengkap
        currentIds.add(articleId);
        bookmarkedIdsNotifier.value = currentIds;
        await _client.from('bookmarks').insert({
          'user_id': userId,
          'article_id': articleId,
        });
        // Fetch hanya artikel yang baru disimpan
        final articleData = await _client
            .from('articles')
            .select('''
              *,
              profiles(*),
              article_categories(category_id, categories(*))
            ''')
            .eq('id', articleId)
            .maybeSingle();
        if (articleData != null) {
          final article = ArticleModel.fromJson(articleData);
          bookmarkedArticlesNotifier.value = [
            article,
            ...bookmarkedArticlesNotifier.value,
          ];
        }
      }
    } catch (e) {
      debugPrint('toggleBookmark error: $e');
      fetchBookmarks(); // Rollback on error
    }
  }

  Future<List<ArticleModel>> getBookmarkedArticles() async {
    // Return from notifier if already loaded, else fetch
    if (bookmarkedArticlesNotifier.value.isNotEmpty ||
        bookmarkedIdsNotifier.value.isEmpty) {
      return bookmarkedArticlesNotifier.value;
    }
    await fetchBookmarks();
    return bookmarkedArticlesNotifier.value;
  }

  // ─── ARTICLES ─────────────────────────────────────────────

  Future<List<ArticleModel>> getHomeFeed({
    String? categoryId,
    int limit = 20,
    int offset = 0,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    try {
      // 1. Get article IDs and read_at timestamps that the user has read
      final historyData = await _client
          .from('reading_history')
          .select('article_id, read_at')
          .eq('user_id', userId);
      
      final readHistoryMap = <String, DateTime>{};
      for (final row in historyData as List) {
        final articleId = row['article_id'] as String;
        final readAtStr = row['read_at'] as String?;
        if (readAtStr != null) {
          readHistoryMap[articleId] = DateTime.parse(readAtStr);
        }
      }

      final readArticleIds = readHistoryMap.keys.toList();

      var query = _client.from('articles').select('''
        *,
        profiles(*),
        article_categories(category_id, categories(*))
      ''').eq('is_published', true);

      if (readArticleIds.isEmpty) {
        query = query.eq('author_id', userId);
      } else {
        final idsList = readArticleIds.join(',');
        query = query.or('author_id.eq.$userId,id.in.($idsList)');
      }

      if (categoryId != null) {
        // Filter through article_categories
        final articleIds = await _client
            .from('article_categories')
            .select('article_id')
            .eq('category_id', categoryId);
        final ids = (articleIds as List).map((e) => e['article_id'] as String).toList();
        if (ids.isEmpty) return [];
        query = query.inFilter('id', ids);
      }

      final data = await query
          .order('published_at', ascending: false)
          .range(offset, offset + limit - 1);

      final articlesList = (data as List).map((e) => ArticleModel.fromJson(e)).toList();

      // Sort by read_at (descending), falling back to published_at or createdAt
      articlesList.sort((a, b) {
        final timeA = readHistoryMap[a.id] ?? a.publishedAt ?? a.createdAt;
        final timeB = readHistoryMap[b.id] ?? b.publishedAt ?? b.createdAt;
        return timeB.compareTo(timeA);
      });

      return articlesList;
    } catch (e) {
      debugPrint('getHomeFeed error: $e');
      // Fallback to only user's own articles on error
      var query = _client.from('articles').select('''
        *,
        profiles(*),
        article_categories(category_id, categories(*))
      ''').eq('author_id', userId).eq('is_published', true);

      final data = await query
          .order('published_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List).map((e) => ArticleModel.fromJson(e)).toList();
    }
  }

  Future<void> recordReadingHistory(String articleId) async {
    final userId = currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from('reading_history').upsert({
        'user_id': userId,
        'article_id': articleId,
        'read_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,article_id');
      articleRefreshTrigger.value++;
    } catch (e) {
      debugPrint('recordReadingHistory error: $e');
    }
  }


  Future<List<ArticleModel>> getDiscoverFeed({
    String? categoryId,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('articles')
        .select('''
          *,
          profiles(*),
          article_categories(category_id, categories(*))
        ''')
        .eq('is_published', true);

    if (categoryId != null) {
      // Filter through article_categories
      final articleIds = await _client
          .from('article_categories')
          .select('article_id')
          .eq('category_id', categoryId);
      final ids = (articleIds as List).map((e) => e['article_id'] as String).toList();
      if (ids.isEmpty) return [];
      query = _client
          .from('articles')
          .select('''
            *,
            profiles(*),
            article_categories(category_id, categories(*))
          ''')
          .eq('is_published', true)
          .inFilter('id', ids);
    }

    final data = await query
        .order('view_count', ascending: false)
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<void> incrementViewCount(String articleId) async {
    try {
      await _client.rpc('increment_view_count', params: {'article_id': articleId});
    } catch (e) {
      debugPrint('incrementViewCount error: $e');
    }
  }

  Future<ArticleModel?> getArticleById(String articleId) async {
    final data = await _client
        .from('articles')
        .select('''
          *,
          profiles(*),
          article_categories(category_id, categories(*))
        ''')
        .eq('id', articleId)
        .maybeSingle();
    if (data == null) return null;
    return ArticleModel.fromJson(data);
  }

  Future<List<ArticleModel>> getMyArticles({bool? isPublished}) async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    var query = _client
        .from('articles')
        .select('''
          *,
          profiles(*),
          article_categories(category_id, categories(*))
        ''')
        .eq('author_id', userId);

    if (isPublished != null) {
      query = query.eq('is_published', isPublished);
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<ArticleModel> createArticle({
    required String title,
    required String content,
    required bool isPublished,
    String? coverImageUrl,
    List<String> categoryIds = const [],
  }) async {
    final userId = currentUser!.id;

    final articleData = await _client.from('articles').insert({
      'author_id': userId,
      'title': title,
      'content': content,
      'is_published': isPublished,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
    }).select().single();

    final article = ArticleModel.fromJson(articleData);

    // Insert categories
    if (categoryIds.isNotEmpty) {
      final categoryRows = categoryIds
          .map((catId) => {
                'article_id': article.id,
                'category_id': catId,
              })
          .toList();
      await _client.from('article_categories').insert(categoryRows);
    }

    articleRefreshTrigger.value++;
    return article;
  }

  Future<ArticleModel> updateArticle({
    required String articleId,
    String? title,
    String? content,
    bool? isPublished,
    String? coverImageUrl,
    bool clearCoverImage = false,
    List<String>? categoryIds,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null) payload['title'] = title;
    if (content != null) payload['content'] = content;
    if (isPublished != null) payload['is_published'] = isPublished;
    if (clearCoverImage) {
      payload['cover_image_url'] = null;
    } else if (coverImageUrl != null) {
      payload['cover_image_url'] = coverImageUrl;
    }

    final data = await _client
        .from('articles')
        .update(payload)
        .eq('id', articleId)
        .select()
        .single();

    // Update categories if provided
    if (categoryIds != null) {
      await _client
          .from('article_categories')
          .delete()
          .eq('article_id', articleId);

      if (categoryIds.isNotEmpty) {
        final rows = categoryIds
            .map((catId) => {
                  'article_id': articleId,
                  'category_id': catId,
                })
            .toList();
        await _client.from('article_categories').insert(rows);
      }
    }

    articleRefreshTrigger.value++;
    return ArticleModel.fromJson(data);
  }

  Future<void> deleteArticle(String articleId) async {
    await _client.from('articles').delete().eq('id', articleId);
    articleRefreshTrigger.value++;
  }

  Future<String?> uploadCoverImage(String articleId, dynamic file) async {
    final userId = currentUser!.id;
    final path = '$userId/${articleId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      if (kIsWeb) {
        await _client.storage
            .from('article-covers')
            .uploadBinary(path, file as Uint8List,
                fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'));
      } else {
        await _client.storage
            .from('article-covers')
            .upload(path, file as File,
                fileOptions: const FileOptions(upsert: true));
      }
      return _client.storage.from('article-covers').getPublicUrl(path);
    } catch (e) {
      debugPrint('Cover upload error: $e');
      return null;
    }
  }

  // ─── CATEGORIES ───────────────────────────────────────────

  Future<List<CategoryModel>> getCategories({bool onlyPublished = false}) async {
    if (onlyPublished) {
      final data = await _client.from('categories').select('''
        id, name, description, cover_image_url,
        article_categories(
          articles(is_published)
        )
      ''').order('name');

      final defaultCategories = {
        'Filsafat', 'Teknologi', 'Sastra', 'Esai',
        'Sains', 'Budaya', 'Sejarah', 'Kesehatan'
      };

      final list = <CategoryModel>[];
      for (final row in data as List) {
        final name = row['name'] as String;
        if (defaultCategories.contains(name)) {
          list.add(CategoryModel.fromJson(row));
          continue;
        }

        bool hasPublishedArticle = false;
        final artCats = row['article_categories'] as List?;
        if (artCats != null) {
          for (final ac in artCats) {
            final article = ac['articles'] as Map<String, dynamic>?;
            if (article != null && article['is_published'] == true) {
              hasPublishedArticle = true;
              break;
            }
          }
        }

        if (hasPublishedArticle) {
          list.add(CategoryModel.fromJson(row));
        }
      }
      return list;
    } else {
      final data = await _client.from('categories').select().order('name');
      return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
    }
  }

  Future<CategoryModel> createCategory({required String name, String? description}) async {
    final trimmedName = name.trim();
    
    // Cari apakah kategori dengan nama yang sama sudah ada (case-insensitive)
    final existing = await _client
        .from('categories')
        .select()
        .ilike('name', trimmedName)
        .maybeSingle();

    if (existing != null) {
      return CategoryModel.fromJson(existing);
    }

    // Jika belum ada, buat baru
    final data = await _client.from('categories').insert({
      'name': trimmedName,
      if (description != null) 'description': description,
    }).select().single();
    return CategoryModel.fromJson(data);
  }

  // ─── COMMENTS ─────────────────────────────────────────────

  Future<List<CommentModel>> getComments(String articleId) async {
    final data = await _client
        .from('comments')
        .select('*, profiles(*)')
        .eq('article_id', articleId)
        .order('created_at', ascending: true);
    return (data as List).map((e) => CommentModel.fromJson(e)).toList();
  }

  Future<CommentModel> createComment({
    required String articleId,
    required String content,
  }) async {
    final userId = currentUser!.id;
    final data = await _client.from('comments').insert({
      'article_id': articleId,
      'user_id': userId,
      'content': content,
    }).select('*, profiles(*)').single();
    return CommentModel.fromJson(data);
  }

  Future<String?> uploadArticleImage(dynamic file) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final path = '$userId/inline_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      if (kIsWeb) {
        await _client.storage
            .from('article-covers')
            .uploadBinary(path, file as Uint8List,
                fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'));
      } else {
        await _client.storage
            .from('article-covers')
            .upload(path, file as File,
                fileOptions: const FileOptions(upsert: true));
      }
      return _client.storage.from('article-covers').getPublicUrl(path);
    } catch (e) {
      debugPrint('Inline image upload error: $e');
      return null;
    }
  }

  static String mapException(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Failed host lookup') ||
        msg.contains('ClientException') ||
        msg.contains('Network') ||
        msg.contains('connection')) {
      return 'Koneksi internet terputus. Silakan periksa jaringan Anda.';
    }
    if (e is AuthException) {
      final authMsg = e.message;
      if (authMsg.contains('Invalid login credentials')) return 'Email atau kata sandi salah.';
      if (authMsg.contains('Email not confirmed')) return 'Email belum dikonfirmasi. Cek inbox Anda.';
      if (authMsg.contains('Too many requests')) return 'Terlalu banyak percobaan. Tunggu sebentar.';
      if (authMsg.contains('User already registered')) return 'Email ini sudah terdaftar.';
      if (authMsg.contains('Password should be')) return 'Password minimal 6 karakter.';
      if (authMsg.contains('Unable to validate email')) return 'Format email tidak valid.';
      return authMsg;
    }
    return msg;
  }
}
