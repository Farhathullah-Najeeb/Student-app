import 'package:crud_app/features/home/presentation/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  await SystemChannels.textInput.invokeMethod('TextInput.hide');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.amber,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.amber,
              iconTheme: IconThemeData(color: Colors.white)),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.amber),
          cardTheme: const CardTheme(color: Colors.white),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white,
          ),
          
          datePickerTheme: const DatePickerThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          radioTheme: const RadioThemeData(
              fillColor: MaterialStatePropertyAll(Colors.amber),
              overlayColor: MaterialStatePropertyAll(Colors.amberAccent))),
      home: const HomeView(),
    );
  }
}
