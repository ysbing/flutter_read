import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_read/src/read_scroll_controller.dart';

import '../flutter_read.dart';

class ReadListView extends StatelessWidget {
  final ReadListController? pageController;
  final NullableIndexedWidgetBuilder itemBuilder;
  final VoidCallback? onScrollCallback;
  final IndexCallback? onPageIndexChanged;

  const ReadListView({
    super.key,
    this.pageController,
    required this.itemBuilder,
    this.onScrollCallback,
    this.onPageIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        int currentIndex =
            pageController!.page?.round() ?? pageController!.initialPage;
        onPageIndexChanged?.call(currentIndex, pre: true);
        if (notification is ScrollEndNotification) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (!((pageController?.position.isScrollingNotifier.value) ??
                true)) {
              onPageIndexChanged?.call(currentIndex);
            }
          });
        } else if (notification is ScrollStartNotification) {
          if (notification.dragDetails != null) {
            onScrollCallback?.call();
          }
        }
        return false;
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemExtent: MediaQuery.of(context).size.height,
          controller: pageController,
          itemBuilder: (BuildContext context, int index) {
            return itemBuilder(context, index);
          },
        ),
      ),
    );
  }
}
