import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Nguồn ảnh trang. Trả về ảnh đã giải mã ([ui.Image]) với chiều rộng khoảng [targetWidth].
abstract class PageImageSource {
  /// [thumbnail] là `true` khi chỉ cần ảnh nhỏ để hiện tạm.
  Future<ui.Image> load(int index, {required int targetWidth, bool thumbnail = false});
}

/// Tải byte ảnh trang (JPEG/PNG/WebP) theo chiều rộng mong muốn, ví dụ gọi API backend.
typedef PageBytesLoader = Future<Uint8List> Function(int pageIndex, int widthPx);

/// Nguồn ảnh dùng [PageBytesLoader]. Giải mã **đúng kích thước đích** để không giữ
/// ảnh gốc lớn trong RAM.
class BytesPageImageSource implements PageImageSource {
  BytesPageImageSource(this.loadBytes);

  final PageBytesLoader loadBytes;

  @override
  Future<ui.Image> load(int index, {required int targetWidth, bool thumbnail = false}) async {
    final bytes = await loadBytes(index, targetWidth);
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: targetWidth);
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }
}

/// Giữ ảnh của một cửa sổ trang quanh trang hiện tại (mặc định: trước, hiện tại, sau).
///
///  - Ảnh ngoài cửa sổ được giải phóng ngay (`dispose`), nên RAM không tăng theo số trang.
///  - Chỉ tải và giải mã **một ảnh một lúc** để đỉnh RAM thấp.
///  - Thứ tự: ảnh nhỏ của các trang trong cửa sổ trước, rồi ảnh đầy đủ theo ưu tiên
///    trang hiện tại, trang sau, trang trước.
///  - Lỗi tải một trang không làm dừng việc tải các trang khác. Trang đó thử lại ở lần
///    [setCenter] kế tiếp.
class PageImageWindow extends ChangeNotifier {
  PageImageWindow({
    required this.source,
    required this.pageCount,
    required this.targetWidth,
    this.thumbWidth = 360,
    this.radius = 1,
    this.useThumbnails = true,
    this.onError,
  }) : assert(pageCount > 0), assert(radius >= 0);

  final PageImageSource source;
  final int pageCount;
  final int targetWidth;
  final int thumbWidth;
  final int radius;
  final bool useThumbnails;
  final void Function(int pageIndex, Object error)? onError;

  final Map<int, ui.Image> _images = <int, ui.Image>{};
  final Map<int, bool> _isFull = <int, bool>{};
  final Set<int> _failed = <int>{};
  List<int> _order = <int>[];
  int _center = 0;
  bool _running = false;
  bool _disposed = false;

  /// Ảnh tốt nhất đang có của trang (đầy đủ nếu đã tải, ngược lại ảnh nhỏ), hoặc `null`.
  ui.Image? imageOf(int index) => _images[index];

  bool hasFull(int index) => _isFull[index] == true;

  /// Số ảnh đang giữ trong RAM (để kiểm tra khi đo).
  int get heldCount => _images.length;

  /// Đặt trang trung tâm. Gọi mỗi khi người dùng sang trang xong.
  void setCenter(int index) {
    if (_disposed) return;
    _center = index.clamp(0, pageCount - 1).toInt();
    _failed.clear();

    final order = <int>[_center];
    for (var k = 1; k <= radius; k++) {
      if (_center + k < pageCount) order.add(_center + k);
      if (_center - k >= 0) order.add(_center - k);
    }
    _order = order;

    for (final i in _images.keys.where((i) => !_order.contains(i)).toList()) {
      _release(_images.remove(i)!);
      _isFull.remove(i);
    }
    _pump();
  }

  _Job? _nextJob() {
    if (useThumbnails) {
      for (final i in _order) {
        if (!_images.containsKey(i) && !_failed.contains(i)) return _Job(i, thumbnail: true);
      }
    }
    for (final i in _order) {
      if (!hasFull(i) && !_failed.contains(i)) return _Job(i, thumbnail: false);
    }
    return null;
  }

  Future<void> _pump() async {
    if (_running || _disposed) return;
    _running = true;
    try {
      while (!_disposed) {
        final job = _nextJob();
        if (job == null) break;
        try {
          final image = await source.load(
            job.index,
            targetWidth: job.thumbnail ? thumbWidth : targetWidth,
            thumbnail: job.thumbnail,
          );
          _accept(job, image);
        } catch (e) {
          _failed.add(job.index);
          onError?.call(job.index, e);
        }
      }
    } finally {
      _running = false;
    }
  }

  void _accept(_Job job, ui.Image image) {
    if (_disposed || !_order.contains(job.index)) {
      image.dispose();
      return;
    }
    // Không để ảnh nhỏ đến muộn đè lên ảnh đầy đủ.
    if (job.thumbnail && hasFull(job.index)) {
      image.dispose();
      return;
    }
    final old = _images[job.index];
    _images[job.index] = image;
    _isFull[job.index] = !job.thumbnail;
    if (old != null) _release(old);
    notifyListeners();
  }

  /// Giải phóng sau khung hình hiện tại, để khung đang vẽ không dùng ảnh đã hủy.
  void _release(ui.Image image) {
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) => image.dispose());
      SchedulerBinding.instance.ensureVisualUpdate();
    } catch (_) {
      image.dispose();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final image in _images.values) {
      _release(image);
    }
    _images.clear();
    _isFull.clear();
    super.dispose();
  }
}

class _Job {
  const _Job(this.index, {required this.thumbnail});
  final int index;
  final bool thumbnail;
}
