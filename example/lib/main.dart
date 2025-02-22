import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_read/flutter_read.dart';

import 'menu.dart';

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
    enableVerticalDrag: true,
    enableTapPage: true,
  );
  PersistentBottomSheetController? _menuController;

  @override
  void initState() {
    start();
    super.initState();
  }

  Future<void> start() async {
    DateTime now = DateTime.now();
    BookSource source = ByteDataSource(
        await rootBundle.load("assets/books/Phineas Redux.txt"),
        "Phineas Redux",
        isSplit: true);
    int state = await bookController.startReadBook(source);
    Duration duration = DateTime.now().difference(now);
    debugPrint("wwww,loading time, $duration, $state");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFE2E8DC),
        body: SafeArea(
          child: Builder(builder: (context) {
            return ReadView(
              readController: bookController,
              onMenu: () {
                if (_menuController == null) {
                  _menuController = showBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    builder: (context) => BookMenu(
                      bookController: bookController,
                    ),
                  )..closed.then((value) {
                      _menuController = null;
                    });
                } else {
                  _menuController?.close();
                }
              },
              onScroll: () {
                _menuController?.close();
              },
            );
          }),
        ),
      ),
    );
  }
}
