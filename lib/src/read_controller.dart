import 'dart:async';

import 'package:flutter/material.dart';

import 'read_controller_impl.dart';
import 'read_data.dart';

abstract class ReadController {
  const ReadController();

  factory ReadController.create({
    bool enableVerticalDrag = false,
    Widget? loadingWidget,
    Widget? summaryWidget,
    ReadStyle? readStyle,
    EdgeCallback? onEdgeCallback,
  }) {
    return ReadControllerImpl(
      enableVerticalDrag: enableVerticalDrag,
      loadingWidget: loadingWidget,
      summaryWidget: summaryWidget,
      readStyle: readStyle,
      onEdgeCallback_: onEdgeCallback,
    );
  }

  // 阅读整本小说
  Future<int> startReadBook(BookSource source, {ChapterData? chapter});

  // 阅读章节
  Future<int> startReadChapter(BookSource source, ChapterData chapter);

  // 预加载章节
  Future<void> addChapter(BookSource source, int chapterIndex);

  // 阅读进度回调
  Stream<BookProgress> get onPageIndexChanged;

  // 当前进度
  BookProgress get currentProgress;

  // 小说样式
  ReadStyle get readStyle;

  // 设置小说样式
  set readStyle(ReadStyle style);

  // 滑动到边缘回调
  set onEdgeCallback(EdgeCallback? callback);

  // 小说页面数据加载时回调，用于插入广告，章评页等
  set onBookDataListCallback(ReadDataListCallback callback);

  // 上一页
  void previousPage();

  // 下一页
  void nextPage();

  // 设置简介页
  void setSummaryWidget(Widget widget);

  // 通过章节下标获取小说源
  BookSource? getSourceFromIndex(int chapterIndex);

  // 通过章节下标获取句子列表
  List<BookSentence>? getSentenceFromIndex(int chapterIndex);
}

typedef EdgeCallback = Function(bool isLeft);
typedef IndexCallback = void Function(int index);
typedef ReadDataListCallback = void Function(
    int chapterIndex, String title, List<PaintData> bookDataList);
typedef ReadItemBuilder = Widget Function(
    BuildContext context, String title, int pageIndex, int pageTotal);

class ReadStyle {
  final TextStyle textStyle;
  final TextStyle titleTextStyle;
  final Color bgColor;
  final double sentenceSpacing;
  final double lineSpacing;
  final double wordSpacing;
  final EdgeInsets padding;

  ReadStyle(
      {required this.textStyle,
        required this.titleTextStyle,
        required this.bgColor,
        required this.sentenceSpacing,
        required this.lineSpacing,
        required this.wordSpacing,
        this.padding = EdgeInsets.zero});
}
