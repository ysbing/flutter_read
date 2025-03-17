# flutter_read

Flutter小说阅读器是一款支持多平台的阅读应用，提供流畅滑动、多样化文字样式、个性化设置，支持章节评价和互动功能，轻松安装使用，实时监测阅读进度，遵循LGPLv3许可证发布。

![演示](https://github.com/ysbing/flutter_read/raw/main/demo.webp)

## 功能特点

- 支持本地小说的阅读
- 实现了流畅的覆盖式滑动方式
- 提供多样化的文字样式设置，包括颜色、大小和字体
- 可自由调整行间距和字间距，个性化阅读体验
- 允许设置简介页和章尾页，包括设置章节评价和互动页等功能

## 平台支持

| Android | iOS | MacOS | Windows | Linux | Web |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |


## 安装

1. 按照安装说明在你的Flutter项目的`pubspec.yaml`文件中添加此包
   ```yaml
   dependencies:
      flutter_read: ^1.0.6
   ```

2. 导入所需的库

   ```dart
   import 'package:flutter_read/flutter_read.dart';
   ```

## 使用

1. 声明小说控制器变量：
   ```dart
   final ReadController readController = ReadController.create();
   ```

2. 将小说控件添加到界面上：
   ```dart
   @override            
   Widget build(BuildContext context) {
     return MaterialApp(
       home: ReadView(readController: readController),
     );
   }
   ```

3. 打开小说：
   ```dart
   final ByteData byteData = await rootBundle.load("assets/斗罗大陆.txt");
   BookSource source = ByteDataSource(byteData, "《斗罗大陆》", isSplit: true);
   int state = await readController.startReadBook(source);
   ```

4. 监听小说阅读进度
   ```dart
   StreamSubscription subscription =
   readController.onPageIndexChanged.listen((progress) {
     // 处理页面索引变化的逻辑
   });
   
   // 页面退出时取消订阅
   @override
   void dispose() {
     subscription.cancel();
     super.dispose();
   }
   ```

## 许可证

本项目采用 [LGPLv3](https://opensource.org/licenses/LGPL-3.0) 许可证发布。