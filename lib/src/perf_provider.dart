import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live frame-timing sample derived from the engine's real timings callback.
class PerfSample {
  const PerfSample({
    required this.fps,
    required this.avgBuildMs,
    required this.avgRasterMs,
    required this.jankyFrames,
    required this.totalFrames,
  });

  final double fps;
  final double avgBuildMs;
  final double avgRasterMs;
  final int jankyFrames;
  final int totalFrames;

  const PerfSample.zero()
      : fps = 0,
        avgBuildMs = 0,
        avgRasterMs = 0,
        jankyFrames = 0,
        totalFrames = 0;

  double get jankPercent => totalFrames == 0 ? 0 : (jankyFrames / totalFrames) * 100;
}

/// Optimization toggles a developer would flip while profiling an iOS build.
class PerfOptions {
  const PerfOptions({
    this.repaintBoundaries = true,
    this.cacheImages = true,
    this.heavyWork = false,
  });

  final bool repaintBoundaries;
  final bool cacheImages;
  final bool heavyWork;

  PerfOptions copyWith({bool? repaintBoundaries, bool? cacheImages, bool? heavyWork}) {
    return PerfOptions(
      repaintBoundaries: repaintBoundaries ?? this.repaintBoundaries,
      cacheImages: cacheImages ?? this.cacheImages,
      heavyWork: heavyWork ?? this.heavyWork,
    );
  }
}

final perfOptionsProvider =
    NotifierProvider<PerfOptionsNotifier, PerfOptions>(PerfOptionsNotifier.new);

class PerfOptionsNotifier extends Notifier<PerfOptions> {
  @override
  PerfOptions build() => const PerfOptions();

  void toggleRepaintBoundaries(bool v) => state = state.copyWith(repaintBoundaries: v);
  void toggleCacheImages(bool v) => state = state.copyWith(cacheImages: v);
  void toggleHeavyWork(bool v) => state = state.copyWith(heavyWork: v);
}

/// Streams real frame timings from [SchedulerBinding] and reduces them into a
/// rolling [PerfSample]. This is the same data Flutter DevTools / Xcode would
/// surface, exposed live in-app so you can see the effect of each toggle.
final perfSampleProvider = NotifierProvider<PerfSampleNotifier, PerfSample>(
  PerfSampleNotifier.new,
);

class PerfSampleNotifier extends Notifier<PerfSample> {
  final List<FrameTiming> _window = <FrameTiming>[];
  int _janky = 0;
  int _total = 0;

  // 60fps target -> ~16.67ms budget per frame.
  static const double _budgetMs = 1000.0 / 60.0;

  @override
  PerfSample build() {
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    ref.onDispose(() {
      SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    });
    return const PerfSample.zero();
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _window.add(t);
      _total++;
      final totalMs =
          (t.buildDuration.inMicroseconds + t.rasterDuration.inMicroseconds) / 1000.0;
      if (totalMs > _budgetMs) _janky++;
    }
    while (_window.length > 60) {
      _window.removeAt(0);
    }
    if (_window.isEmpty) return;

    double build = 0;
    double raster = 0;
    for (final t in _window) {
      build += t.buildDuration.inMicroseconds / 1000.0;
      raster += t.rasterDuration.inMicroseconds / 1000.0;
    }
    final avgBuild = build / _window.length;
    final avgRaster = raster / _window.length;
    final frameMs = (avgBuild + avgRaster).clamp(0.001, 1000.0);
    final fps = (1000.0 / frameMs).clamp(0.0, 120.0);

    state = PerfSample(
      fps: fps,
      avgBuildMs: avgBuild,
      avgRasterMs: avgRaster,
      jankyFrames: _janky,
      totalFrames: _total,
    );
  }
}
