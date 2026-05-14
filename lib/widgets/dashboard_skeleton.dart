import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader para el dashboard mientras cargan los datos
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E2336),
      highlightColor: const Color(0xFF2C3356),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header skeleton
            _skeletonBox(height: 100, radius: 20),
            const SizedBox(height: 20),
            // 3 cards skeleton
            Row(
              children: [
                Expanded(child: _skeletonBox(height: 110, radius: 20)),
                const SizedBox(width: 12),
                Expanded(child: _skeletonBox(height: 110, radius: 20)),
              ],
            ),
            const SizedBox(height: 12),
            _skeletonBox(height: 110, radius: 20),
            const SizedBox(height: 20),
            // Chart skeleton
            _skeletonBox(height: 200, radius: 16),
            const SizedBox(height: 20),
            // List skeleton
            _skeletonBox(height: 70, radius: 12),
            const SizedBox(height: 10),
            _skeletonBox(height: 70, radius: 12),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBox({required double height, double radius = 8}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2336),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
