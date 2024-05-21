import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 章节
class BookChapter {
  // 页列表
  List<BookPage> pages = List.empty(growable: true);
}

// 页
class BookPage {
  // 行列表
  List<BookLine> lines = List.empty(growable: true);

  // 行不够，往后补全
  bool isRepair = false;

  @override
  String toString() {
    return lines.toString();
  }
}

// 行
class BookLine {
  // 句子
  final BookSentence sentence;

  // 在句子中的开始位置
  final int startIndex;

  // 在句子中的结束位置
  int? endIndex;

  // 行不够，往后补全
  bool isRepair = false;

  // 是否是标题
  bool isTitle = false;

  BookLine(this.sentence, this.startIndex);

  @override
  String toString() {
    return sentence.words.sublist(startIndex, endIndex).toString();
  }
}

// 句
class BookSentence {
  // 字列表
  final List<BookWord> words;

  // 在章节中的位置
  final int index;

  // 在章节中的原始位置
  final int originalIndex;

  BookSentence(this.words, this.index, this.originalIndex);

  @override
  String toString() {
    return words.toString();
  }
}

// 字
class BookWord {
  // 字符
  final String char;

  // 在句子中的位置
  final int index;

  // 在屏幕的绝对坐标
  int x = 0;
  int y = 0;

  BookWord(this.char, this.index);

  @override
  String toString() {
    return char;
  }
}

class ChapterData {
  int chapterIndex;
  int sentenceIndex;
  int wordIndex;

  // 简介页
  bool summary;

  // 尾页，可用于章评，互动页
  bool colophon;

  ChapterData({
    this.chapterIndex = 0,
    this.sentenceIndex = 0,
    this.wordIndex = 0,
    this.summary = false,
    this.colophon = false,
  });
}

abstract class BookSource {
  // 书籍名或章节名
  String getTitle();

  Future<Map<String, List<BookSentence>>> getData();

  Future<Map<String, List<BookSentence>>> _read(
      Stream<List<int>> source, String title, bool isSplit) async {
    final Completer isFinish = Completer<void>();
    final Map<String, List<BookSentence>> result = {};
    List<BookSentence> sentences = List.empty(growable: true);
    result[title] = sentences;
    try {
      int position = 0;
      int originalPosition = 0;
      final RegExp chapterTitlePattern =
          RegExp(r'^\s*第\s*(?:[零一二两三四五六七八九十百千万]+|\d+)\s*章');
      source.transform(utf8.decoder).transform(const LineSplitter()).listen(
          (String line) {
        if (line.isNotEmpty) {
          if (isSplit && chapterTitlePattern.hasMatch(line)) {
            if (sentences.isNotEmpty) {
              sentences = List.empty(growable: true);
              position = 0;
              result[line.trim()] = sentences;
            }
          } else {
            List<BookWord> words = List.empty(growable: true);
            for (int i = 0; i < line.length; i++) {
              words.add(BookWord(line[i], i));
            }
            BookSentence sentence =
                BookSentence(words, position, originalPosition);
            sentences.add(sentence);
            position++;
          }
        }
        originalPosition++;
      }, onDone: () {
        debugPrint("wwww,read finish,${sentences.length}");
        if (!isFinish.isCompleted) {
          isFinish.complete();
        }
      }, onError: (e) {
        debugPrint("wwww,read error1:$e");
        if (!isFinish.isCompleted) {
          isFinish.complete();
        }
      });
      await isFinish.future;
    } catch (e) {
      debugPrint("wwww,read error2:$e");
    }
    return result;
  }
}

class FileSource extends BookSource {
  final String source;
  final String title;
  final bool isSplit;

  FileSource(this.source, this.title, {this.isSplit = false});

  @override
  Future<Map<String, List<BookSentence>>> getData() {
    File file = File(source);
    Stream<List<int>> stream;
    if (file.existsSync()) {
      stream = file.openRead();
    } else {
      stream = const Stream.empty();
    }
    return _read(stream, title, isSplit);
  }

  @override
  String getTitle() => title;
}

class ByteDataSource extends BookSource {
  final ByteData source;
  final String title;
  final bool isSplit;

  ByteDataSource(this.source, this.title, {this.isSplit = false});

  @override
  Future<Map<String, List<BookSentence>>> getData() {
    Uint8List bytes = source.buffer.asUint8List();
    StreamController<List<int>> controller = StreamController<List<int>>();
    controller.add(bytes);
    controller.close();
    Stream<List<int>> stream = controller.stream;
    return _read(stream, title, isSplit);
  }

  @override
  String getTitle() => title;
}

class StringSource extends BookSource {
  final String source;
  final String title;
  final bool isSplit;

  StringSource(this.source, this.title, {this.isSplit = false});

  @override
  Future<Map<String, List<BookSentence>>> getData() {
    StreamController<List<int>> controller = StreamController<List<int>>();
    List<int> bytes = utf8.encode(source);
    controller.add(bytes);
    controller.close();
    Stream<List<int>> stream = controller.stream;
    return _read(stream, title, isSplit);
  }

  @override
  String getTitle() => title;
}

class ChapterSource extends BookSource {
  final List<BookSentence> source;
  final String title;

  ChapterSource(this.source, this.title);

  @override
  Future<Map<String, List<BookSentence>>> getData() async {
    return {title: source};
  }

  @override
  String getTitle() => title;
}

// 页面绘制数据
class PaintData {
  final int chapterIndex;
  final String title;
  final BookPage? bookPage;
  final Widget? widget;
  final ValueNotifier<ui.Picture?> picture = ValueNotifier(null);

  PaintData(this.chapterIndex, this.title, {this.bookPage, this.widget});
}

class BookProgress {
  // 章节下标
  final String chapterTitle;

  // 章节下标
  final int chapterIndex;

  // 页下标
  final int pageIndex;

  // 总页数
  final int pageTotal;

  // 句在章节里的下标
  final int sentenceIndex;

  // 句在章节里的原始下标
  final int sentenceOriginalIndex;

  // 字在句里的下标
  final int wordIndex;

  // 是否是互动页
  final bool interaction;

  // 是否是简介页
  final bool snapshot;

  // 页面数据
  final BookPage? bookPage;

  BookProgress(
      this.chapterTitle,
      this.chapterIndex,
      this.pageIndex,
      this.pageTotal,
      this.sentenceIndex,
      this.sentenceOriginalIndex,
      this.wordIndex,
      this.bookPage,
      [this.interaction = false,
      this.snapshot = false]);

  static BookProgress zero = BookProgress("", 0, 0, 0, 0, 0, 0, null);

  @override
  String toString() {
    return "chapterTitle:$chapterTitle,chapterIndex:$chapterIndex,pageIndex:$pageIndex,pageTotal:$pageTotal,sentenceIndex:$sentenceIndex,sentenceOriginalIndex:$sentenceOriginalIndex,wordIndex:$wordIndex,interaction:$interaction,snapshot:$snapshot";
  }
}
