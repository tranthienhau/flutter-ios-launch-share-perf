import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'app.dart';

/// Demonstrates the native iOS share sheet (UIActivityViewController) through
/// share_plus, with the iPad popover anchor wired via [sharePositionOrigin] -
/// the common crash point when sharing on iPad is a missing anchor rect.
class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    await Share.share(
      'Check out my Unreal 5.7 sandbox build for iPad! High score: 14,250 points.',
      subject: 'Island 03 - my run',
      sharePositionOrigin: origin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native iOS Share'),
        backgroundColor: BrandColors.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BrandColors.accent, BrandColors.accentAlt],
                  ),
                ),
                child: const Icon(Icons.landscape, color: Colors.white, size: 96),
              ),
              const SizedBox(height: 28),
              const Text('Island 03',
                  style: TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Share your run via the iOS share sheet',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: BrandColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _share(context),
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Share to…', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
