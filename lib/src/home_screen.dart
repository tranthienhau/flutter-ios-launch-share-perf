import 'package:flutter/material.dart';

import 'app.dart';
import 'perf_screen.dart';
import 'share_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [BrandColors.accent, BrandColors.accentAlt],
                    ),
                  ),
                  child: const Icon(Icons.flutter_dash, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('iOS Toolkit',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('Launch • Share • Performance',
                          style: TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _FeatureCard(
              icon: Icons.rocket_launch,
              title: 'Launch Screen',
              subtitle:
                  'Storyboard-matched first frame: no white flash, no layout jump on cold start.',
              color: BrandColors.accent,
              onTap: () {},
            ),
            const SizedBox(height: 14),
            _FeatureCard(
              icon: Icons.ios_share,
              title: 'Native iOS Share',
              subtitle: 'UIActivityViewController via the platform share sheet, anchored for iPad.',
              color: BrandColors.accentAlt,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ShareScreen()),
              ),
            ),
            const SizedBox(height: 14),
            _FeatureCard(
              icon: Icons.speed,
              title: 'Performance HUD',
              subtitle: 'Live FPS, build/raster ms, and jank % from real frame timings.',
              color: const Color(0xFF35C759),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PerfScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BrandColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}
