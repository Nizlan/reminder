import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:reminder/ui/events_screen.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String> _initTimeZone() async {
    return await FlutterNativeTimezone.getLocalTimezone();
  }

  @override
  void initState() {
    _initTimeZone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<String>(
        future: _initTimeZone(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return EventsScreen(timezone: snapshot.data!);
          } else {
            return const Scaffold();
          }
        },
      ),
    );
  }
}
