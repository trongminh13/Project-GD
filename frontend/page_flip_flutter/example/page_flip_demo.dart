// Chạy thử không cần backend:
//   flutter run -t example/page_flip_demo.dart
//
// Đổi 'your_app' thành tên package trong pubspec.yaml của dự án.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:your_app/core/page_flip/page_flip_view.dart';
import 'package:your_app/core/page_flip/page_image_window.dart';

void main() => runApp(const _DemoApp());

/// Nguồn ảnh giả: vẽ trang mẫu bằng canvas, có độ trễ 150 ms để giống mạng.
class ProceduralPageSource implements PageImageSource {
  ProceduralPageSource({this.latency = const Duration(milliseconds: 150)});

  final Duration latency;

  static const List<List<String>> _pages = <List<String>>[
    <String>['TOÁN 3 · CHƯƠNG 1', 'Số tự nhiên đến 10 000', 'Trong chương này, em học đọc, viết, so sánh các số có bốn chữ số.'],
    <String>['CHƯƠNG 1', 'Bài 1. Đọc và viết số', '4 235 = 4 nghìn + 2 trăm + 3 chục + 5 đơn vị.'],
    <String>['CHƯƠNG 1', 'Bài 2. So sánh các số', '7 308 > 7 299 vì hàng trăm: 3 > 2.'],
    <String>['CHƯƠNG 1', 'Bài 3. Cộng trong phạm vi 10 000', '2 345 + 1 432 = 3 777.'],
    <String>['CHƯƠNG 1', 'Bài 4. Trừ trong phạm vi 10 000', '6 584 - 2 341 = 4 243.'],
    <String>['CHƯƠNG 1', 'Ôn tập chương 1', 'Hết chương 1. Em có thể làm bài tập cuối chương.'],
  ];

  @override
  Future<ui.Image> load(int index, {required int targetWidth, bool thumbnail = false}) async {
    await Future<void>.delayed(latency);
    final w = targetWidth.toDouble();
    final h = w * 1.4142;
    final u = w / 360;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = Colors.white);
    canvas.drawRect(
      Rect.fromLTWH(0.5, 0.5, w - 1, h - 1),
      Paint()
        ..color = const Color(0xFFDADCE0)
        ..style = PaintingStyle.stroke,
    );
    final page = _pages[index % _pages.length];
    var y = 32 * u;
    void text(String t, double size, FontWeight weight, Color color) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: TextStyle(fontSize: size * u, fontWeight: weight, color: color, height: 1.35)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w - 56 * u);
      tp.paint(canvas, Offset(28 * u, y));
      y += tp.height + 12 * u;
    }

    text(page[0], 11, FontWeight.w600, const Color(0xFF5F6368));
    text(page[1], 24, FontWeight.w600, const Color(0xFF202124));
    text(page[2], 15, FontWeight.w400, const Color(0xFF202124));
    text('${index + 1}', 13, FontWeight.w400, const Color(0xFF5F6368));
    return recorder.endRecording().toImage(targetWidth, h.round());
  }
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2457C5)),
      home: const _DemoPage(),
    );
  }
}

class _DemoPage extends StatefulWidget {
  const _DemoPage();

  @override
  State<_DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<_DemoPage> {
  final PageFlipController _controller = PageFlipController();
  final PageImageSource _source = ProceduralPageSource();
  int _page = 0;
  bool _shadow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang ${_page + 1}/6'),
        actions: <Widget>[
          Row(
            children: <Widget>[
              const Text('Bóng'),
              Switch(value: _shadow, onChanged: (v) => setState(() => _shadow = v)),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PageFlipView(
                pageCount: 6,
                source: _source,
                controller: _controller,
                shadow: _shadow,
                hintOnOpen: true,
                onPageChanged: (p) => setState(() => _page = p),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: <Widget>[
                Expanded(child: OutlinedButton(onPressed: _controller.previous, child: const Text('Trang trước'))),
                const SizedBox(width: 8),
                Expanded(child: FilledButton(onPressed: _controller.next, child: const Text('Trang sau'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
