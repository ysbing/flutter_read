import 'package:flutter/material.dart';
import 'package:flutter_read/flutter_read.dart';

class BookSetting extends StatefulWidget {
  final ReadController bookController;

  const BookSetting({super.key, required this.bookController});

  @override
  State<StatefulWidget> createState() => _BookSettingState();
}

class _BookSettingState extends State<BookSetting> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _fontSize(),
          const SizedBox(
            height: 20,
          ),
          _lineSpacing(),
          const SizedBox(
            height: 20,
          ),
          _wordSpacing(),
          const SizedBox(
            height: 20,
          ),
          _fontColor(),
          const SizedBox(
            height: 20,
          ),
          _fontFamily(),
        ],
      ),
    );
  }

  Widget _fontSize() {
    return Row(
      children: [
        const Text(
          "Font Size",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle =
                widget.bookController.readStyle.copyWith(
              textStyle: widget.bookController.readStyle.textStyle.copyWith(
                  fontSize:
                      widget.bookController.readStyle.textStyle.fontSize! - 1),
              titleTextStyle: widget.bookController.readStyle.titleTextStyle
                  .copyWith(
                      fontSize:
                          (widget.bookController.readStyle.textStyle.fontSize! -
                                  1) *
                              1.3),
            );
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              "A-",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        Container(
          width: 60,
          alignment: Alignment.center,
          child: Text(
            "${widget.bookController.readStyle.textStyle.fontSize}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle =
                widget.bookController.readStyle.copyWith(
              textStyle: widget.bookController.readStyle.textStyle.copyWith(
                  fontSize:
                      widget.bookController.readStyle.textStyle.fontSize! + 1),
              titleTextStyle: widget.bookController.readStyle.titleTextStyle
                  .copyWith(
                      fontSize:
                          (widget.bookController.readStyle.textStyle.fontSize! +
                                  1) *
                              1.3),
            );
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              "A+",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _lineSpacing() {
    return Row(
      children: [
        const Text(
          "Line Spacing",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle = widget.bookController.readStyle
                .copyWith(
                    lineSpacing:
                        widget.bookController.readStyle.lineSpacing - 1);
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              "≡-",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        Container(
          width: 60,
          alignment: Alignment.center,
          child: Text(
            "${widget.bookController.readStyle.lineSpacing}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle = widget.bookController.readStyle
                .copyWith(
                    lineSpacing:
                        widget.bookController.readStyle.lineSpacing + 1);
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              "≡+",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _wordSpacing() {
    return Row(
      children: [
        const Text(
          "Word Spacing",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle = widget.bookController.readStyle
                .copyWith(
                    wordSpacing:
                        widget.bookController.readStyle.wordSpacing - 1);
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              "W-",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        Container(
          width: 60,
          alignment: Alignment.center,
          child: Text(
            "${widget.bookController.readStyle.wordSpacing}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle = widget.bookController.readStyle
                .copyWith(
                    wordSpacing:
                        widget.bookController.readStyle.wordSpacing + 1);
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text(
              "W+",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fontColor() {
    return Row(
      children: [
        const Text(
          "background",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle =
                widget.bookController.readStyle.copyWith(
              textStyle: widget.bookController.readStyle.textStyle
                  .copyWith(color: const Color(0xFF212832)),
              titleTextStyle: widget.bookController.readStyle.titleTextStyle
                  .copyWith(color: const Color(0xFF212832)),
              bgColor: const Color(0xFFF5F5DC),
            );
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFF5F5DC),
                borderRadius: BorderRadius.circular(20),
                border: widget.bookController.readStyle.bgColor ==
                        const Color(0xFFF5F5DC)
                    ? Border.all(color: Colors.blue)
                    : null),
            alignment: Alignment.center,
            child: const Text(
              "T",
              style: TextStyle(
                color: Color(0xFF212832),
                fontSize: 16,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle =
                widget.bookController.readStyle.copyWith(
              textStyle: widget.bookController.readStyle.textStyle
                  .copyWith(color: const Color(0xFF333333)),
              titleTextStyle: widget.bookController.readStyle.titleTextStyle
                  .copyWith(color: const Color(0xFF333333)),
              bgColor: const Color(0xFFC7EDCC),
            );
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFC7EDCC),
                borderRadius: BorderRadius.circular(20),
                border: widget.bookController.readStyle.bgColor ==
                        const Color(0xFFC7EDCC)
                    ? Border.all(color: Colors.blue)
                    : null),
            alignment: Alignment.center,
            child: const Text(
              "T",
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle =
                widget.bookController.readStyle.copyWith(
              textStyle: widget.bookController.readStyle.textStyle
                  .copyWith(color: const Color(0xFFCCCCCC)),
              titleTextStyle: widget.bookController.readStyle.titleTextStyle
                  .copyWith(color: const Color(0xFFCCCCCC)),
              bgColor: const Color(0xFF1E1E1E),
            );
            setState(() {});
          },
          child: Container(
            width: 40,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: widget.bookController.readStyle.bgColor ==
                        const Color(0xFF1E1E1E)
                    ? Border.all(color: Colors.blue)
                    : null),
            alignment: Alignment.center,
            child: const Text(
              "T",
              style: TextStyle(
                color: Color(0xFFCCCCCC),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fontFamily() {
    return Row(
      children: [
        const Text(
          "Font",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle =
                widget.bookController.readStyle.copyWith(
              textStyle: widget.bookController.readStyle.textStyle
                  .copyWith(fontFamily: ''),
              titleTextStyle: widget.bookController.readStyle.titleTextStyle
                  .copyWith(fontFamily: ''),
            );
            setState(() {});
          },
          child: Container(
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                border: widget.bookController.readStyle.textStyle.fontFamily
                            ?.isEmpty ??
                        true
                    ? Border.all(color: Colors.blue)
                    : null),
            alignment: Alignment.center,
            child: const Text(
              "System Font",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            widget.bookController.readStyle =
                widget.bookController.readStyle.copyWith(
              textStyle: widget.bookController.readStyle.textStyle
                  .copyWith(fontFamily: "楷体"),
              titleTextStyle: widget.bookController.readStyle.titleTextStyle
                  .copyWith(fontFamily: "楷体"),
            );
            setState(() {});
          },
          child: Container(
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                border:
                    widget.bookController.readStyle.textStyle.fontFamily == "楷体"
                        ? Border.all(color: Colors.blue)
                        : null),
            alignment: Alignment.center,
            child: const Text(
              "楷体",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "楷体",
              ),
            ),
          ),
        ),
      ],
    );
  }
}
