import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_read/flutter_read.dart';

import 'data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ReadController bookController = ReadController.create(
    loadingWidget: const Center(
      child: CircularProgressIndicator(),
    ),
  );

  @override
  void initState() {
    start();
    super.initState();
  }

  Future<void> start() async {
    DateTime now = DateTime.now();
    BookSource source = StringSource(bookData, "《斗罗大陆》", isSplit: true);
    int state = await bookController.startReadBook(source);
    Duration duration = DateTime.now().difference(now);
    debugPrint("wwww,加载小说耗时,$duration,$state");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFE2E8DC),
        body: SafeArea(
          child: ReadView(
            readController: bookController,
          ),
        ),
      ),
    );
  }
}
