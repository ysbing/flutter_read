import 'package:flutter/material.dart';
import 'package:flutter_read/flutter_read.dart';
import 'package:flutter_read_example/setting.dart';

class BookMenu extends StatefulWidget {
  final ReadController bookController;

  const BookMenu({super.key, required this.bookController});

  @override
  State<StatefulWidget> createState() => _BookMenuState();
}

class _BookMenuState extends State<BookMenu> {
  bool _showDirectoryFlag = false;
  bool _showSettingFlag = false;
  bool _wrapDirectoryHeight = true;
  bool _wrapSettingHeight = true;
  final int _animDuration = 250;

  void _showDirectory() {
    setState(() {
      _showDirectoryFlag = true;
      _wrapDirectoryHeight = false;
    });
  }

  void _closeDirectory() {
    setState(() {
      _showDirectoryFlag = false;
    });
  }

  void _showSetting() {
    setState(() {
      _showSettingFlag = true;
      _wrapSettingHeight = false;
    });
  }

  void _closeSetting() {
    setState(() {
      _showSettingFlag = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool wrap = _wrapDirectoryHeight;
    return SizedBox(
      width: double.infinity,
      height: wrap ? null : double.infinity,
      child: Stack(
        fit: wrap ? StackFit.loose : StackFit.expand,
        children: [
          if (!wrap)
            GestureDetector(
              onTap: () {
                if (_showDirectoryFlag) {
                  _closeDirectory();
                }
                if (_showSettingFlag) {
                  _closeSetting();
                }
              },
              child: AnimatedOpacity(
                opacity: _showDirectoryFlag ? 1 : 0,
                duration: Duration(milliseconds: _animDuration),
                onEnd: () {
                  if (!_showDirectoryFlag) {
                    setState(() {
                      _wrapDirectoryHeight = true;
                    });
                  }
                  if (!_showSettingFlag) {
                    setState(() {
                      _wrapSettingHeight = true;
                    });
                  }
                },
                child: const ColoredBox(
                  color: Color(0x80000000),
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  AnimatedSlide(
                    offset: _wrapDirectoryHeight || !_showDirectoryFlag
                        ? const Offset(0, 1)
                        : Offset.zero,
                    duration: Duration(milliseconds: _animDuration),
                    child: SizedBox(
                      height: !_wrapDirectoryHeight ? 360 : 0,
                      child: _buildDirectory(),
                    ),
                  ),
                  AnimatedSlide(
                    offset: _wrapSettingHeight || !_showSettingFlag
                        ? const Offset(0, 1)
                        : Offset.zero,
                    duration: Duration(milliseconds: _animDuration),
                    child: SizedBox(
                      height: !_wrapSettingHeight ? 250 : 0,
                      child: BookSetting(
                        bookController: widget.bookController,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 1,
                color: Colors.amberAccent,
              ),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _item("Contents", "", () {
                      if (_showSettingFlag) {
                        _closeSetting();
                      }
                      if (_showDirectoryFlag) {
                        _closeDirectory();
                      } else {
                        _showDirectory();
                      }
                    }),
                    Container(
                      width: 1,
                      color: Colors.amberAccent,
                    ),
                    _item("Settings", "", () {
                      if (_showDirectoryFlag) {
                        _closeDirectory();
                      }
                      if (_showSettingFlag) {
                        _closeSetting();
                      } else {
                        _showSetting();
                      }
                    }),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(String text, String icon, GestureTapCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.yellow,
          alignment: Alignment.center,
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildDirectory() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      //padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              widget.bookController.currentBookSource?.getTitle() ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            height: 1,
            color: Colors.amberAccent,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.bookController.getChapterNum(),
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                BookSource? source =
                    widget.bookController.getSourceFromIndex(index);
                return ListTile(
                  title: Text(source?.getTitle() ?? ""),
                  onTap: () {
                    _closeDirectory();
                    Future.delayed(Duration(milliseconds: _animDuration), () {
                      Navigator.pop(context);
                      widget.bookController.startReadChapter(
                          source!, ChapterData(chapterIndex: index));
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
