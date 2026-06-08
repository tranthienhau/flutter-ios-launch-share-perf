import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'perf_provider.dart';

class PerfScreen extends ConsumerWidget {
  const PerfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sample = ref.watch(perfSampleProvider);
    final opts = ref.watch(perfOptionsProvider);
    final notifier = ref.read(perfOptionsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance HUD'),
        backgroundColor: BrandColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'FPS',
                  value: sample.fps.toStringAsFixed(0),
                  color: sample.fps >= 55 ? const Color(0xFF35C759) : const Color(0xFFFF9F0A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: 'Jank',
                  value: '${sample.jankPercent.toStringAsFixed(1)}%',
                  color: sample.jankPercent < 5 ? const Color(0xFF35C759) : const Color(0xFFFF3B30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Build ms',
                  value: sample.avgBuildMs.toStringAsFixed(2),
                  color: BrandColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: 'Raster ms',
                  value: sample.avgRasterMs.toStringAsFixed(2),
                  color: BrandColors.accentAlt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Sampled over ${sample.totalFrames} real frames • 16.67ms = 60fps budget',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 24),
          const Text('Optimization toggles',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _Toggle(
            label: 'RepaintBoundary on cells',
            subtitle: 'Isolate repaints so scrolling does not redraw the whole list.',
            value: opts.repaintBoundaries,
            onChanged: notifier.toggleRepaintBoundaries,
          ),
          _Toggle(
            label: 'Image cache enabled',
            subtitle: 'Decode-once and reuse to cut raster cost.',
            value: opts.cacheImages,
            onChanged: notifier.toggleCacheImages,
          ),
          _Toggle(
            label: 'Simulate heavy work',
            subtitle: 'Push expensive layout to watch FPS drop and jank rise.',
            value: opts.heavyWork,
            onChanged: notifier.toggleHeavyWork,
          ),
          const SizedBox(height: 16),
          _StressGrid(heavy: opts.heavyWork, repaintBoundaries: opts.repaintBoundaries),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      activeColor: BrandColors.accent,
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// A small animated grid used as a controllable rendering load so the HUD shows
/// the impact of the optimization toggles on real frame timings.
class _StressGrid extends StatefulWidget {
  const _StressGrid({required this.heavy, required this.repaintBoundaries});
  final bool heavy;
  final bool repaintBoundaries;

  @override
  State<_StressGrid> createState() => _StressGridState();
}

class _StressGridState extends State<_StressGrid> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.heavy ? 240 : 48;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(count, (i) {
            final t = (_c.value + i / count) % 1.0;
            final cell = Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Color.lerp(BrandColors.accent, BrandColors.accentAlt, t),
              ),
            );
            return widget.repaintBoundaries ? RepaintBoundary(child: cell) : cell;
          }),
        );
      },
    );
  }
}
