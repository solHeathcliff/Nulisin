import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'core/theme.dart';
import 'core/router.dart';
import 'core/article_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ArticleRepository.instance.init();
=======
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase — ganti dengan URL & Key dari project Supabase Anda
  await Supabase.initialize(
    url: SupabaseService.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: SupabaseService.supabaseAnonKey,
  );

>>>>>>> Back-End
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const NulisinApp());
}

class NulisinApp extends StatelessWidget {
  const NulisinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nulisin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
<<<<<<< HEAD
    );
  }
}
=======
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
      ],
    );
  }
}

>>>>>>> Back-End
