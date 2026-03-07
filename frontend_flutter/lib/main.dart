import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 去掉右上角的 Debug 旗標
      title: 'TrackMe 風控系統',
      theme: ThemeData(
        // 強制使用 Google Fonts，質感瞬間提升
        textTheme: GoogleFonts.notoSansTcTextTheme(),
        brightness: Brightness.dark, // 因為圖片是深色的，我們用暗色模式
      ),
      home: const LoginView(),
    );
  }
}
