import 'dart:async';
import 'dart:ui';

import 'package:dance_meter2/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  Timer? timer;
  int seconds = 0;
  int minutes = 0;
  int? selectedMinute;
  int? selectedPrice;
  double totalPrice = 0.0;

  service.on('start').listen((event) {
    final Map<String, dynamic>? args = event;
    if (args != null) {
      selectedMinute = args['selectedMinute'];
      selectedPrice = args['selectedPrice'];
    }

    seconds = 0;
    minutes = 0;
    totalPrice = 0.0;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds++;
      if (seconds >= 60) {
        seconds = 0;
        minutes++;
        if (selectedMinute != null &&
            selectedPrice != null &&
            selectedMinute! > 0) {
          totalPrice += selectedPrice! / selectedMinute!;
        }
      }

      service.invoke(
        'update',
        {
          "minutes": minutes,
          "seconds": seconds,
          "totalPrice": totalPrice,
        },
      );
    });
  });

  service.on('stop').listen((event) {
    timer?.cancel();
    seconds = 0;
    minutes = 0;
    totalPrice = 0;
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}