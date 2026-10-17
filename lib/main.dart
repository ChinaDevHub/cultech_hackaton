import 'package:cultech_hackaton/app.dart';
import 'package:cultech_hackaton/core/di/injection_container.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reflect in-app navigation in the browser URL bar (push/go both update it).
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await configureDependencies();
  runApp(const App());
}
