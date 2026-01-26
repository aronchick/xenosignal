import 'geo_bounds.dart';

/// Aggregated signal data for a geographic tile in the heatmap.
///
/// Tiles provide efficient rendering by pre-computing statistics
/// for rectangular regions rather than querying individual points.
class HeatmapTile {
  /// Creates a heatmap tile.
  const HeatmapTile({
    required this.bounds,
    required this.avgSignalQuality,
    required this.peakSignalQuality,
    required this.sampleCount,
    required this.lastUpdated,
  });

  /// Geographic bounds of this tile.
  final GeoBounds bounds;

  /// Average signal quality (0-100) of readings in this tile.
  final double avgSignalQuality;

  /// Best recorded signal quality (0-100) in this tile.
  final double peakSignalQuality;

  /// Number of readings aggregated into this tile.
  final int sampleCount;

  /// When this tile was last updated with new data.
  final DateTime lastUpdated;

  /// Whether this tile has sufficient data for reliable display.
  bool get hasSufficientData => sampleCount >= 3;

  /// Intensity value for heatmap rendering (0.0-1.0).
  double get intensity => avgSignalQuality / 100.0;

  /// Peak intensity for "best spot" indicators.
  double get peakIntensity => peakSignalQuality / 100.0;

  /// Whether the data is considered fresh (updated within 7 days).
  bool get isFresh =>
      DateTime.now().difference(lastUpdated).inDays < 7;

  /// Creates a tile by aggregating multiple readings.
  factory HeatmapTile.aggregate({
    required GeoBounds bounds,
    required List<int> qualityScores,
    required DateTime lastUpdated,
  }) {
    if (qualityScores.isEmpty) {
      return HeatmapTile(
        bounds: bounds,
        avgSignalQuality: 0,
        peakSignalQuality: 0,
        sampleCount: 0,
        lastUpdated: lastUpdated,
      );
    }

    final sum = qualityScores.fold(0, (a, b) => a + b);
    final peak = qualityScores.reduce((a, b) => a > b ? a : b);

    return HeatmapTile(
      bounds: bounds,
      avgSignalQuality: sum / qualityScores.length,
      peakSignalQuality: peak.toDouble(),
      sampleCount: qualityScores.length,
      lastUpdated: lastUpdated,
    );
  }

  /// Merges this tile with another, combining their statistics.
  HeatmapTile merge(HeatmapTile other) {
    final totalCount = sampleCount + other.sampleCount;
    if (totalCount == 0) return this;

    // Weighted average based on sample counts
    final combinedAvg = (avgSignalQuality * sampleCount +
            other.avgSignalQuality * other.sampleCount) /
        totalCount;

    return HeatmapTile(
      bounds: bounds,
      avgSignalQuality: combinedAvg,
      peakSignalQuality: peakSignalQuality > other.peakSignalQuality
          ? peakSignalQuality
          : other.peakSignalQuality,
      sampleCount: totalCount,
      lastUpdated: lastUpdated.isAfter(other.lastUpdated)
          ? lastUpdated
          : other.lastUpdated,
    );
  }

  @override
  String toString() =>
      'HeatmapTile(avg: ${avgSignalQuality.toStringAsFixed(1)}%, '
      'peak: ${peakSignalQuality.toStringAsFixed(1)}%, '
      'samples: $sampleCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeatmapTile &&
          bounds == other.bounds &&
          avgSignalQuality == other.avgSignalQuality &&
          peakSignalQuality == other.peakSignalQuality &&
          sampleCount == other.sampleCount &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode => Object.hash(
        bounds,
        avgSignalQuality,
        peakSignalQuality,
        sampleCount,
        lastUpdated,
      );
}
