import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/routes.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const DamstockApp());
}

class DamstockApp extends StatefulWidget {
  const DamstockApp({super.key});

  @override
  State<DamstockApp> createState() => _DamstockAppState();
}

class _DamstockAppState extends State<DamstockApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) => MaterialApp(
          title: 'DAMSTOCK HOMES',
          debugShowCheckedModeBanner: false,
          locale: _state.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.of(_state.isAr),
          initialRoute: Routes.splash,
          onGenerateRoute: AppRouter.generate,
        ),
      ),
    );
  }
}
