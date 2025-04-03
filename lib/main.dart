import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Doğru import// intl paketini içeri aktarıyoruz
import 'package:windyforecast/ui/home_page.dart';

void main() {
  // Uygulama başlatılmadan önce Türkçe formatlamayı başlatıyoruz
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('tr_TR', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
