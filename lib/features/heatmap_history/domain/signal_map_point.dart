import '../../signal_tracking/domain/signal_reading.dart';

/// A signal reading associated with a geographic location for heatmap storage.
///
/// Extends the concept of [SignalReading] with additional metadata for
/// persistent storage and heatmap visualization.
class SignalMapPoint {
  /// Creates a signal map point.
  const SignalMapPoint({
    required this.id,
    required this.position,
    required this.radiusMeters,
    required this.reading,
    required this.recordedAt,
    this.isManualPin = false,
    this.label,
  });

  /// Unique identifier for this point.
  final String id;

  /// Geographic position where reading was taken.
  final GeoPosition position;

  /// Uncertainty radius in meters.
  ///
  /// Larger values indicate lower GPS accuracy.
  final double radiusMeters;

  /// The signal reading data.
  final SignalReading reading;

  /// When this point was recorded.
  final DateTime recordedAt;

  /// Whether user manually marked this location.
  ///
  /// Manual pins are preserved indefinitely and shown distinctly.
  final bool isManualPin;

  /// Optional user-provided label for manual pins.
  final String? label;

  /// Returns true if this is a low-confidence reading (accuracy > 50m).
  bool get isLowConfidence => radiusMeters > 50;

  /// Creates a copy with optional field overrides.
  SignalMapPoint copyWith({
    String? id,
    GeoPosition? position,
    double? radiusMeters,
    SignalReading? reading,
    DateTime? recordedAt,
    bool? isManualPin,
    String? label,
  }) {
    return SignalMapPoint(
      id: id ?? this.id,
      position: position ?? this.position,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      reading: reading ?? this.reading,
      recordedAt: recordedAt ?? this.recordedAt,
      isManualPin: isManualPin ?? this.isManualPin,
      label: label ?? this.label,
    );
  }

  @override
  String toString() =>
      'SignalMapPoint(id: $id, quality: ${reading.qualityScore}%, '
      '${isManualPin ? 'manual pin' : 'auto'})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignalMapPoint &&
          id == other.id &&
          position == other.position &&
          radiusMeters == other.radiusMeters &&
          reading == other.reading &&
          recordedAt == other.recordedAt &&
          isManualPin == other.isManualPin &&
          label == other.label;

  @override
  int get hashCode => Object.hash(
        id,
        position,
        radiusMeters,
        reading,
        recordedAt,
        isManualPin,
        label,
      );
}
