Language: [English](https://github.com/ysbing/flutter_read/blob/main/README.md) | [中文简体](https://github.com/ysbing/flutter_read/blob/main/README_zh.md)

# flutter_read

Flutter Novel Reader is a multi-platform reading app offering smooth scrolling, diverse text styles, and personalized settings. It supports chapter evaluation and interaction features, easy installation and usage, real-time reading progress monitoring, and is released under the LGPLv3 license.

![Demo](https://github.com/ysbing/flutter_read/raw/main/demo.webp)

## Features

- Supports reading local novels
- Implements smooth scrolling with coverage
- Provides diverse text style settings, including color, size, and font
- Allows free adjustment of line spacing and letter spacing for personalized reading experience
- Enables setting introduction pages and chapter end pages, including features like chapter ratings and interactive pages

## Platform Support

| Android | iOS | MacOS | Windows | Linux | Web |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |


## Installation

1. Add this package to your Flutter project's `pubspec.yaml` file according to the installation instructions
   ```yaml
   dependencies:
      flutter_read: ^1.0.6
   ```

2. Import the necessary libraries

   ```dart
   import 'package:flutter_read/flutter_read.dart';
   ```

## Usage

1. Declare a novel controller variable:
   ```dart
   final ReadController readController = ReadController.create();
   ```

2. Add the novel widget to the interface:
   ```dart
   @override            
   Widget build(BuildContext context) {
     return MaterialApp(
       home: ReadView(readController: readController),
     );
   }
   ```

3. Open the novel:
   ```dart
   final ByteData byteData = await rootBundle.load("assets/斗罗大陆.txt");
   BookSource source = ByteDataSource(byteData, "《斗罗大陆》", isSplit: true);
   int state = await readController.startReadBook(source);
   ```

4. Listen to the novel reading progress:
   ```dart
   StreamSubscription subscription =
   readController.onPageIndexChanged.listen((progress) {
     // Handle logic for page index changes
   });
   
   // Unsubscribe when the page exits
   @override
   void dispose() {
     subscription.cancel();
     super.dispose();
   }
   ```

## License

This project is released under the [LGPLv3](https://opensource.org/licenses/LGPL-3.0) license.