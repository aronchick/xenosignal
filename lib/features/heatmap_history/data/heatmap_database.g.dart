// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap_database.dart';

// ignore_for_file: type=lint
class $SignalMapPointsTable extends SignalMapPoints
    with TableInfo<$SignalMapPointsTable, SignalMapPointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalMapPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<double> radiusMeters = GeneratedColumn<double>(
    'radius_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityScoreMeta = const VerificationMeta(
    'qualityScore',
  );
  @override
  late final GeneratedColumn<int> qualityScore = GeneratedColumn<int>(
    'quality_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signalTypeMeta = const VerificationMeta(
    'signalType',
  );
  @override
  late final GeneratedColumn<String> signalType = GeneratedColumn<String>(
    'signal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dbmMeta = const VerificationMeta('dbm');
  @override
  late final GeneratedColumn<double> dbm = GeneratedColumn<double>(
    'dbm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _networkNameMeta = const VerificationMeta(
    'networkName',
  );
  @override
  late final GeneratedColumn<String> networkName = GeneratedColumn<String>(
    'network_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _connectionTypeMeta = const VerificationMeta(
    'connectionType',
  );
  @override
  late final GeneratedColumn<String> connectionType = GeneratedColumn<String>(
    'connection_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isManualPinMeta = const VerificationMeta(
    'isManualPin',
  );
  @override
  late final GeneratedColumn<bool> isManualPin = GeneratedColumn<bool>(
    'is_manual_pin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manual_pin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latitude,
    longitude,
    altitude,
    radiusMeters,
    qualityScore,
    signalType,
    dbm,
    networkName,
    connectionType,
    recordedAt,
    isManualPin,
    label,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signal_map_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<SignalMapPointRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_radiusMetersMeta);
    }
    if (data.containsKey('quality_score')) {
      context.handle(
        _qualityScoreMeta,
        qualityScore.isAcceptableOrUnknown(
          data['quality_score']!,
          _qualityScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qualityScoreMeta);
    }
    if (data.containsKey('signal_type')) {
      context.handle(
        _signalTypeMeta,
        signalType.isAcceptableOrUnknown(data['signal_type']!, _signalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_signalTypeMeta);
    }
    if (data.containsKey('dbm')) {
      context.handle(
        _dbmMeta,
        dbm.isAcceptableOrUnknown(data['dbm']!, _dbmMeta),
      );
    }
    if (data.containsKey('network_name')) {
      context.handle(
        _networkNameMeta,
        networkName.isAcceptableOrUnknown(
          data['network_name']!,
          _networkNameMeta,
        ),
      );
    }
    if (data.containsKey('connection_type')) {
      context.handle(
        _connectionTypeMeta,
        connectionType.isAcceptableOrUnknown(
          data['connection_type']!,
          _connectionTypeMeta,
        ),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('is_manual_pin')) {
      context.handle(
        _isManualPinMeta,
        isManualPin.isAcceptableOrUnknown(
          data['is_manual_pin']!,
          _isManualPinMeta,
        ),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignalMapPointRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignalMapPointRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_meters'],
      )!,
      qualityScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality_score'],
      )!,
      signalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signal_type'],
      )!,
      dbm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dbm'],
      ),
      networkName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network_name'],
      ),
      connectionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_type'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      isManualPin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manual_pin'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $SignalMapPointsTable createAlias(String alias) {
    return $SignalMapPointsTable(attachedDatabase, alias);
  }
}

class SignalMapPointRow extends DataClass
    implements Insertable<SignalMapPointRow> {
  /// Unique identifier (UUID).
  final String id;

  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  /// Altitude in meters (nullable).
  final double? altitude;

  /// GPS accuracy radius in meters.
  final double radiusMeters;

  /// Signal quality score (0-100).
  final int qualityScore;

  /// Signal type: 'wifi' or 'cellular'.
  final String signalType;

  /// Raw dBm value (nullable, Android only).
  final double? dbm;

  /// Network name/SSID (nullable).
  final String? networkName;

  /// Connection type details (nullable).
  final String? connectionType;

  /// When the reading was recorded.
  final DateTime recordedAt;

  /// Whether this is a manual pin.
  final bool isManualPin;

  /// User label for manual pins (nullable).
  final String? label;
  const SignalMapPointRow({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.radiusMeters,
    required this.qualityScore,
    required this.signalType,
    this.dbm,
    this.networkName,
    this.connectionType,
    required this.recordedAt,
    required this.isManualPin,
    this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['radius_meters'] = Variable<double>(radiusMeters);
    map['quality_score'] = Variable<int>(qualityScore);
    map['signal_type'] = Variable<String>(signalType);
    if (!nullToAbsent || dbm != null) {
      map['dbm'] = Variable<double>(dbm);
    }
    if (!nullToAbsent || networkName != null) {
      map['network_name'] = Variable<String>(networkName);
    }
    if (!nullToAbsent || connectionType != null) {
      map['connection_type'] = Variable<String>(connectionType);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['is_manual_pin'] = Variable<bool>(isManualPin);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  SignalMapPointsCompanion toCompanion(bool nullToAbsent) {
    return SignalMapPointsCompanion(
      id: Value(id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      radiusMeters: Value(radiusMeters),
      qualityScore: Value(qualityScore),
      signalType: Value(signalType),
      dbm: dbm == null && nullToAbsent ? const Value.absent() : Value(dbm),
      networkName: networkName == null && nullToAbsent
          ? const Value.absent()
          : Value(networkName),
      connectionType: connectionType == null && nullToAbsent
          ? const Value.absent()
          : Value(connectionType),
      recordedAt: Value(recordedAt),
      isManualPin: Value(isManualPin),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory SignalMapPointRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignalMapPointRow(
      id: serializer.fromJson<String>(json['id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      radiusMeters: serializer.fromJson<double>(json['radiusMeters']),
      qualityScore: serializer.fromJson<int>(json['qualityScore']),
      signalType: serializer.fromJson<String>(json['signalType']),
      dbm: serializer.fromJson<double?>(json['dbm']),
      networkName: serializer.fromJson<String?>(json['networkName']),
      connectionType: serializer.fromJson<String?>(json['connectionType']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      isManualPin: serializer.fromJson<bool>(json['isManualPin']),
      label: serializer.fromJson<String?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'radiusMeters': serializer.toJson<double>(radiusMeters),
      'qualityScore': serializer.toJson<int>(qualityScore),
      'signalType': serializer.toJson<String>(signalType),
      'dbm': serializer.toJson<double?>(dbm),
      'networkName': serializer.toJson<String?>(networkName),
      'connectionType': serializer.toJson<String?>(connectionType),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'isManualPin': serializer.toJson<bool>(isManualPin),
      'label': serializer.toJson<String?>(label),
    };
  }

  SignalMapPointRow copyWith({
    String? id,
    double? latitude,
    double? longitude,
    Value<double?> altitude = const Value.absent(),
    double? radiusMeters,
    int? qualityScore,
    String? signalType,
    Value<double?> dbm = const Value.absent(),
    Value<String?> networkName = const Value.absent(),
    Value<String?> connectionType = const Value.absent(),
    DateTime? recordedAt,
    bool? isManualPin,
    Value<String?> label = const Value.absent(),
  }) => SignalMapPointRow(
    id: id ?? this.id,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    qualityScore: qualityScore ?? this.qualityScore,
    signalType: signalType ?? this.signalType,
    dbm: dbm.present ? dbm.value : this.dbm,
    networkName: networkName.present ? networkName.value : this.networkName,
    connectionType: connectionType.present
        ? connectionType.value
        : this.connectionType,
    recordedAt: recordedAt ?? this.recordedAt,
    isManualPin: isManualPin ?? this.isManualPin,
    label: label.present ? label.value : this.label,
  );
  SignalMapPointRow copyWithCompanion(SignalMapPointsCompanion data) {
    return SignalMapPointRow(
      id: data.id.present ? data.id.value : this.id,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      radiusMeters: data.radiusMeters.present
          ? data.radiusMeters.value
          : this.radiusMeters,
      qualityScore: data.qualityScore.present
          ? data.qualityScore.value
          : this.qualityScore,
      signalType: data.signalType.present
          ? data.signalType.value
          : this.signalType,
      dbm: data.dbm.present ? data.dbm.value : this.dbm,
      networkName: data.networkName.present
          ? data.networkName.value
          : this.networkName,
      connectionType: data.connectionType.present
          ? data.connectionType.value
          : this.connectionType,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      isManualPin: data.isManualPin.present
          ? data.isManualPin.value
          : this.isManualPin,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignalMapPointRow(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('signalType: $signalType, ')
          ..write('dbm: $dbm, ')
          ..write('networkName: $networkName, ')
          ..write('connectionType: $connectionType, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('isManualPin: $isManualPin, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    latitude,
    longitude,
    altitude,
    radiusMeters,
    qualityScore,
    signalType,
    dbm,
    networkName,
    connectionType,
    recordedAt,
    isManualPin,
    label,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignalMapPointRow &&
          other.id == this.id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.radiusMeters == this.radiusMeters &&
          other.qualityScore == this.qualityScore &&
          other.signalType == this.signalType &&
          other.dbm == this.dbm &&
          other.networkName == this.networkName &&
          other.connectionType == this.connectionType &&
          other.recordedAt == this.recordedAt &&
          other.isManualPin == this.isManualPin &&
          other.label == this.label);
}

class SignalMapPointsCompanion extends UpdateCompanion<SignalMapPointRow> {
  final Value<String> id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<double> radiusMeters;
  final Value<int> qualityScore;
  final Value<String> signalType;
  final Value<double?> dbm;
  final Value<String?> networkName;
  final Value<String?> connectionType;
  final Value<DateTime> recordedAt;
  final Value<bool> isManualPin;
  final Value<String?> label;
  final Value<int> rowid;
  const SignalMapPointsCompanion({
    this.id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.signalType = const Value.absent(),
    this.dbm = const Value.absent(),
    this.networkName = const Value.absent(),
    this.connectionType = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.isManualPin = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SignalMapPointsCompanion.insert({
    required String id,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    required double radiusMeters,
    required int qualityScore,
    required String signalType,
    this.dbm = const Value.absent(),
    this.networkName = const Value.absent(),
    this.connectionType = const Value.absent(),
    required DateTime recordedAt,
    this.isManualPin = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       latitude = Value(latitude),
       longitude = Value(longitude),
       radiusMeters = Value(radiusMeters),
       qualityScore = Value(qualityScore),
       signalType = Value(signalType),
       recordedAt = Value(recordedAt);
  static Insertable<SignalMapPointRow> custom({
    Expression<String>? id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? radiusMeters,
    Expression<int>? qualityScore,
    Expression<String>? signalType,
    Expression<double>? dbm,
    Expression<String>? networkName,
    Expression<String>? connectionType,
    Expression<DateTime>? recordedAt,
    Expression<bool>? isManualPin,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (qualityScore != null) 'quality_score': qualityScore,
      if (signalType != null) 'signal_type': signalType,
      if (dbm != null) 'dbm': dbm,
      if (networkName != null) 'network_name': networkName,
      if (connectionType != null) 'connection_type': connectionType,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (isManualPin != null) 'is_manual_pin': isManualPin,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SignalMapPointsCompanion copyWith({
    Value<String>? id,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitude,
    Value<double>? radiusMeters,
    Value<int>? qualityScore,
    Value<String>? signalType,
    Value<double?>? dbm,
    Value<String?>? networkName,
    Value<String?>? connectionType,
    Value<DateTime>? recordedAt,
    Value<bool>? isManualPin,
    Value<String?>? label,
    Value<int>? rowid,
  }) {
    return SignalMapPointsCompanion(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      qualityScore: qualityScore ?? this.qualityScore,
      signalType: signalType ?? this.signalType,
      dbm: dbm ?? this.dbm,
      networkName: networkName ?? this.networkName,
      connectionType: connectionType ?? this.connectionType,
      recordedAt: recordedAt ?? this.recordedAt,
      isManualPin: isManualPin ?? this.isManualPin,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<double>(radiusMeters.value);
    }
    if (qualityScore.present) {
      map['quality_score'] = Variable<int>(qualityScore.value);
    }
    if (signalType.present) {
      map['signal_type'] = Variable<String>(signalType.value);
    }
    if (dbm.present) {
      map['dbm'] = Variable<double>(dbm.value);
    }
    if (networkName.present) {
      map['network_name'] = Variable<String>(networkName.value);
    }
    if (connectionType.present) {
      map['connection_type'] = Variable<String>(connectionType.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (isManualPin.present) {
      map['is_manual_pin'] = Variable<bool>(isManualPin.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalMapPointsCompanion(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('signalType: $signalType, ')
          ..write('dbm: $dbm, ')
          ..write('networkName: $networkName, ')
          ..write('connectionType: $connectionType, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('isManualPin: $isManualPin, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HeatmapTilesTable extends HeatmapTiles
    with TableInfo<$HeatmapTilesTable, HeatmapTileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeatmapTilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _northMeta = const VerificationMeta('north');
  @override
  late final GeneratedColumn<double> north = GeneratedColumn<double>(
    'north',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _southMeta = const VerificationMeta('south');
  @override
  late final GeneratedColumn<double> south = GeneratedColumn<double>(
    'south',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eastMeta = const VerificationMeta('east');
  @override
  late final GeneratedColumn<double> east = GeneratedColumn<double>(
    'east',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _westMeta = const VerificationMeta('west');
  @override
  late final GeneratedColumn<double> west = GeneratedColumn<double>(
    'west',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgSignalQualityMeta = const VerificationMeta(
    'avgSignalQuality',
  );
  @override
  late final GeneratedColumn<double> avgSignalQuality = GeneratedColumn<double>(
    'avg_signal_quality',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakSignalQualityMeta = const VerificationMeta(
    'peakSignalQuality',
  );
  @override
  late final GeneratedColumn<double> peakSignalQuality =
      GeneratedColumn<double>(
        'peak_signal_quality',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    north,
    south,
    east,
    west,
    avgSignalQuality,
    peakSignalQuality,
    sampleCount,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'heatmap_tiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<HeatmapTileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('north')) {
      context.handle(
        _northMeta,
        north.isAcceptableOrUnknown(data['north']!, _northMeta),
      );
    } else if (isInserting) {
      context.missing(_northMeta);
    }
    if (data.containsKey('south')) {
      context.handle(
        _southMeta,
        south.isAcceptableOrUnknown(data['south']!, _southMeta),
      );
    } else if (isInserting) {
      context.missing(_southMeta);
    }
    if (data.containsKey('east')) {
      context.handle(
        _eastMeta,
        east.isAcceptableOrUnknown(data['east']!, _eastMeta),
      );
    } else if (isInserting) {
      context.missing(_eastMeta);
    }
    if (data.containsKey('west')) {
      context.handle(
        _westMeta,
        west.isAcceptableOrUnknown(data['west']!, _westMeta),
      );
    } else if (isInserting) {
      context.missing(_westMeta);
    }
    if (data.containsKey('avg_signal_quality')) {
      context.handle(
        _avgSignalQualityMeta,
        avgSignalQuality.isAcceptableOrUnknown(
          data['avg_signal_quality']!,
          _avgSignalQualityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgSignalQualityMeta);
    }
    if (data.containsKey('peak_signal_quality')) {
      context.handle(
        _peakSignalQualityMeta,
        peakSignalQuality.isAcceptableOrUnknown(
          data['peak_signal_quality']!,
          _peakSignalQualityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peakSignalQualityMeta);
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sampleCountMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HeatmapTileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeatmapTileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      north: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}north'],
      )!,
      south: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}south'],
      )!,
      east: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}east'],
      )!,
      west: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}west'],
      )!,
      avgSignalQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_signal_quality'],
      )!,
      peakSignalQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_signal_quality'],
      )!,
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $HeatmapTilesTable createAlias(String alias) {
    return $HeatmapTilesTable(attachedDatabase, alias);
  }
}

class HeatmapTileRow extends DataClass implements Insertable<HeatmapTileRow> {
  /// Tile identifier based on bounds.
  final String id;

  /// Northern latitude boundary.
  final double north;

  /// Southern latitude boundary.
  final double south;

  /// Eastern longitude boundary.
  final double east;

  /// Western longitude boundary.
  final double west;

  /// Average signal quality (0-100).
  final double avgSignalQuality;

  /// Peak signal quality (0-100).
  final double peakSignalQuality;

  /// Number of samples in this tile.
  final int sampleCount;

  /// Last update timestamp.
  final DateTime lastUpdated;
  const HeatmapTileRow({
    required this.id,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.avgSignalQuality,
    required this.peakSignalQuality,
    required this.sampleCount,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['north'] = Variable<double>(north);
    map['south'] = Variable<double>(south);
    map['east'] = Variable<double>(east);
    map['west'] = Variable<double>(west);
    map['avg_signal_quality'] = Variable<double>(avgSignalQuality);
    map['peak_signal_quality'] = Variable<double>(peakSignalQuality);
    map['sample_count'] = Variable<int>(sampleCount);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  HeatmapTilesCompanion toCompanion(bool nullToAbsent) {
    return HeatmapTilesCompanion(
      id: Value(id),
      north: Value(north),
      south: Value(south),
      east: Value(east),
      west: Value(west),
      avgSignalQuality: Value(avgSignalQuality),
      peakSignalQuality: Value(peakSignalQuality),
      sampleCount: Value(sampleCount),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory HeatmapTileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeatmapTileRow(
      id: serializer.fromJson<String>(json['id']),
      north: serializer.fromJson<double>(json['north']),
      south: serializer.fromJson<double>(json['south']),
      east: serializer.fromJson<double>(json['east']),
      west: serializer.fromJson<double>(json['west']),
      avgSignalQuality: serializer.fromJson<double>(json['avgSignalQuality']),
      peakSignalQuality: serializer.fromJson<double>(json['peakSignalQuality']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'north': serializer.toJson<double>(north),
      'south': serializer.toJson<double>(south),
      'east': serializer.toJson<double>(east),
      'west': serializer.toJson<double>(west),
      'avgSignalQuality': serializer.toJson<double>(avgSignalQuality),
      'peakSignalQuality': serializer.toJson<double>(peakSignalQuality),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  HeatmapTileRow copyWith({
    String? id,
    double? north,
    double? south,
    double? east,
    double? west,
    double? avgSignalQuality,
    double? peakSignalQuality,
    int? sampleCount,
    DateTime? lastUpdated,
  }) => HeatmapTileRow(
    id: id ?? this.id,
    north: north ?? this.north,
    south: south ?? this.south,
    east: east ?? this.east,
    west: west ?? this.west,
    avgSignalQuality: avgSignalQuality ?? this.avgSignalQuality,
    peakSignalQuality: peakSignalQuality ?? this.peakSignalQuality,
    sampleCount: sampleCount ?? this.sampleCount,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  HeatmapTileRow copyWithCompanion(HeatmapTilesCompanion data) {
    return HeatmapTileRow(
      id: data.id.present ? data.id.value : this.id,
      north: data.north.present ? data.north.value : this.north,
      south: data.south.present ? data.south.value : this.south,
      east: data.east.present ? data.east.value : this.east,
      west: data.west.present ? data.west.value : this.west,
      avgSignalQuality: data.avgSignalQuality.present
          ? data.avgSignalQuality.value
          : this.avgSignalQuality,
      peakSignalQuality: data.peakSignalQuality.present
          ? data.peakSignalQuality.value
          : this.peakSignalQuality,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeatmapTileRow(')
          ..write('id: $id, ')
          ..write('north: $north, ')
          ..write('south: $south, ')
          ..write('east: $east, ')
          ..write('west: $west, ')
          ..write('avgSignalQuality: $avgSignalQuality, ')
          ..write('peakSignalQuality: $peakSignalQuality, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    north,
    south,
    east,
    west,
    avgSignalQuality,
    peakSignalQuality,
    sampleCount,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeatmapTileRow &&
          other.id == this.id &&
          other.north == this.north &&
          other.south == this.south &&
          other.east == this.east &&
          other.west == this.west &&
          other.avgSignalQuality == this.avgSignalQuality &&
          other.peakSignalQuality == this.peakSignalQuality &&
          other.sampleCount == this.sampleCount &&
          other.lastUpdated == this.lastUpdated);
}

class HeatmapTilesCompanion extends UpdateCompanion<HeatmapTileRow> {
  final Value<String> id;
  final Value<double> north;
  final Value<double> south;
  final Value<double> east;
  final Value<double> west;
  final Value<double> avgSignalQuality;
  final Value<double> peakSignalQuality;
  final Value<int> sampleCount;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const HeatmapTilesCompanion({
    this.id = const Value.absent(),
    this.north = const Value.absent(),
    this.south = const Value.absent(),
    this.east = const Value.absent(),
    this.west = const Value.absent(),
    this.avgSignalQuality = const Value.absent(),
    this.peakSignalQuality = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeatmapTilesCompanion.insert({
    required String id,
    required double north,
    required double south,
    required double east,
    required double west,
    required double avgSignalQuality,
    required double peakSignalQuality,
    required int sampleCount,
    required DateTime lastUpdated,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       north = Value(north),
       south = Value(south),
       east = Value(east),
       west = Value(west),
       avgSignalQuality = Value(avgSignalQuality),
       peakSignalQuality = Value(peakSignalQuality),
       sampleCount = Value(sampleCount),
       lastUpdated = Value(lastUpdated);
  static Insertable<HeatmapTileRow> custom({
    Expression<String>? id,
    Expression<double>? north,
    Expression<double>? south,
    Expression<double>? east,
    Expression<double>? west,
    Expression<double>? avgSignalQuality,
    Expression<double>? peakSignalQuality,
    Expression<int>? sampleCount,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (north != null) 'north': north,
      if (south != null) 'south': south,
      if (east != null) 'east': east,
      if (west != null) 'west': west,
      if (avgSignalQuality != null) 'avg_signal_quality': avgSignalQuality,
      if (peakSignalQuality != null) 'peak_signal_quality': peakSignalQuality,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeatmapTilesCompanion copyWith({
    Value<String>? id,
    Value<double>? north,
    Value<double>? south,
    Value<double>? east,
    Value<double>? west,
    Value<double>? avgSignalQuality,
    Value<double>? peakSignalQuality,
    Value<int>? sampleCount,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return HeatmapTilesCompanion(
      id: id ?? this.id,
      north: north ?? this.north,
      south: south ?? this.south,
      east: east ?? this.east,
      west: west ?? this.west,
      avgSignalQuality: avgSignalQuality ?? this.avgSignalQuality,
      peakSignalQuality: peakSignalQuality ?? this.peakSignalQuality,
      sampleCount: sampleCount ?? this.sampleCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (north.present) {
      map['north'] = Variable<double>(north.value);
    }
    if (south.present) {
      map['south'] = Variable<double>(south.value);
    }
    if (east.present) {
      map['east'] = Variable<double>(east.value);
    }
    if (west.present) {
      map['west'] = Variable<double>(west.value);
    }
    if (avgSignalQuality.present) {
      map['avg_signal_quality'] = Variable<double>(avgSignalQuality.value);
    }
    if (peakSignalQuality.present) {
      map['peak_signal_quality'] = Variable<double>(peakSignalQuality.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeatmapTilesCompanion(')
          ..write('id: $id, ')
          ..write('north: $north, ')
          ..write('south: $south, ')
          ..write('east: $east, ')
          ..write('west: $west, ')
          ..write('avgSignalQuality: $avgSignalQuality, ')
          ..write('peakSignalQuality: $peakSignalQuality, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HeatmapDatabase extends GeneratedDatabase {
  _$HeatmapDatabase(QueryExecutor e) : super(e);
  $HeatmapDatabaseManager get managers => $HeatmapDatabaseManager(this);
  late final $SignalMapPointsTable signalMapPoints = $SignalMapPointsTable(
    this,
  );
  late final $HeatmapTilesTable heatmapTiles = $HeatmapTilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    signalMapPoints,
    heatmapTiles,
  ];
}

typedef $$SignalMapPointsTableCreateCompanionBuilder =
    SignalMapPointsCompanion Function({
      required String id,
      required double latitude,
      required double longitude,
      Value<double?> altitude,
      required double radiusMeters,
      required int qualityScore,
      required String signalType,
      Value<double?> dbm,
      Value<String?> networkName,
      Value<String?> connectionType,
      required DateTime recordedAt,
      Value<bool> isManualPin,
      Value<String?> label,
      Value<int> rowid,
    });
typedef $$SignalMapPointsTableUpdateCompanionBuilder =
    SignalMapPointsCompanion Function({
      Value<String> id,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitude,
      Value<double> radiusMeters,
      Value<int> qualityScore,
      Value<String> signalType,
      Value<double?> dbm,
      Value<String?> networkName,
      Value<String?> connectionType,
      Value<DateTime> recordedAt,
      Value<bool> isManualPin,
      Value<String?> label,
      Value<int> rowid,
    });

class $$SignalMapPointsTableFilterComposer
    extends Composer<_$HeatmapDatabase, $SignalMapPointsTable> {
  $$SignalMapPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qualityScore => $composableBuilder(
    column: $table.qualityScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signalType => $composableBuilder(
    column: $table.signalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dbm => $composableBuilder(
    column: $table.dbm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get networkName => $composableBuilder(
    column: $table.networkName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isManualPin => $composableBuilder(
    column: $table.isManualPin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SignalMapPointsTableOrderingComposer
    extends Composer<_$HeatmapDatabase, $SignalMapPointsTable> {
  $$SignalMapPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qualityScore => $composableBuilder(
    column: $table.qualityScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signalType => $composableBuilder(
    column: $table.signalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dbm => $composableBuilder(
    column: $table.dbm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get networkName => $composableBuilder(
    column: $table.networkName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isManualPin => $composableBuilder(
    column: $table.isManualPin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SignalMapPointsTableAnnotationComposer
    extends Composer<_$HeatmapDatabase, $SignalMapPointsTable> {
  $$SignalMapPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qualityScore => $composableBuilder(
    column: $table.qualityScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get signalType => $composableBuilder(
    column: $table.signalType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dbm =>
      $composableBuilder(column: $table.dbm, builder: (column) => column);

  GeneratedColumn<String> get networkName => $composableBuilder(
    column: $table.networkName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get connectionType => $composableBuilder(
    column: $table.connectionType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isManualPin => $composableBuilder(
    column: $table.isManualPin,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);
}

class $$SignalMapPointsTableTableManager
    extends
        RootTableManager<
          _$HeatmapDatabase,
          $SignalMapPointsTable,
          SignalMapPointRow,
          $$SignalMapPointsTableFilterComposer,
          $$SignalMapPointsTableOrderingComposer,
          $$SignalMapPointsTableAnnotationComposer,
          $$SignalMapPointsTableCreateCompanionBuilder,
          $$SignalMapPointsTableUpdateCompanionBuilder,
          (
            SignalMapPointRow,
            BaseReferences<
              _$HeatmapDatabase,
              $SignalMapPointsTable,
              SignalMapPointRow
            >,
          ),
          SignalMapPointRow,
          PrefetchHooks Function()
        > {
  $$SignalMapPointsTableTableManager(
    _$HeatmapDatabase db,
    $SignalMapPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalMapPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalMapPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalMapPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double> radiusMeters = const Value.absent(),
                Value<int> qualityScore = const Value.absent(),
                Value<String> signalType = const Value.absent(),
                Value<double?> dbm = const Value.absent(),
                Value<String?> networkName = const Value.absent(),
                Value<String?> connectionType = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<bool> isManualPin = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SignalMapPointsCompanion(
                id: id,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                radiusMeters: radiusMeters,
                qualityScore: qualityScore,
                signalType: signalType,
                dbm: dbm,
                networkName: networkName,
                connectionType: connectionType,
                recordedAt: recordedAt,
                isManualPin: isManualPin,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double latitude,
                required double longitude,
                Value<double?> altitude = const Value.absent(),
                required double radiusMeters,
                required int qualityScore,
                required String signalType,
                Value<double?> dbm = const Value.absent(),
                Value<String?> networkName = const Value.absent(),
                Value<String?> connectionType = const Value.absent(),
                required DateTime recordedAt,
                Value<bool> isManualPin = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SignalMapPointsCompanion.insert(
                id: id,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                radiusMeters: radiusMeters,
                qualityScore: qualityScore,
                signalType: signalType,
                dbm: dbm,
                networkName: networkName,
                connectionType: connectionType,
                recordedAt: recordedAt,
                isManualPin: isManualPin,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SignalMapPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$HeatmapDatabase,
      $SignalMapPointsTable,
      SignalMapPointRow,
      $$SignalMapPointsTableFilterComposer,
      $$SignalMapPointsTableOrderingComposer,
      $$SignalMapPointsTableAnnotationComposer,
      $$SignalMapPointsTableCreateCompanionBuilder,
      $$SignalMapPointsTableUpdateCompanionBuilder,
      (
        SignalMapPointRow,
        BaseReferences<
          _$HeatmapDatabase,
          $SignalMapPointsTable,
          SignalMapPointRow
        >,
      ),
      SignalMapPointRow,
      PrefetchHooks Function()
    >;
typedef $$HeatmapTilesTableCreateCompanionBuilder =
    HeatmapTilesCompanion Function({
      required String id,
      required double north,
      required double south,
      required double east,
      required double west,
      required double avgSignalQuality,
      required double peakSignalQuality,
      required int sampleCount,
      required DateTime lastUpdated,
      Value<int> rowid,
    });
typedef $$HeatmapTilesTableUpdateCompanionBuilder =
    HeatmapTilesCompanion Function({
      Value<String> id,
      Value<double> north,
      Value<double> south,
      Value<double> east,
      Value<double> west,
      Value<double> avgSignalQuality,
      Value<double> peakSignalQuality,
      Value<int> sampleCount,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

class $$HeatmapTilesTableFilterComposer
    extends Composer<_$HeatmapDatabase, $HeatmapTilesTable> {
  $$HeatmapTilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get north => $composableBuilder(
    column: $table.north,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get south => $composableBuilder(
    column: $table.south,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get east => $composableBuilder(
    column: $table.east,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get west => $composableBuilder(
    column: $table.west,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSignalQuality => $composableBuilder(
    column: $table.avgSignalQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakSignalQuality => $composableBuilder(
    column: $table.peakSignalQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HeatmapTilesTableOrderingComposer
    extends Composer<_$HeatmapDatabase, $HeatmapTilesTable> {
  $$HeatmapTilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get north => $composableBuilder(
    column: $table.north,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get south => $composableBuilder(
    column: $table.south,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get east => $composableBuilder(
    column: $table.east,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get west => $composableBuilder(
    column: $table.west,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSignalQuality => $composableBuilder(
    column: $table.avgSignalQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakSignalQuality => $composableBuilder(
    column: $table.peakSignalQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HeatmapTilesTableAnnotationComposer
    extends Composer<_$HeatmapDatabase, $HeatmapTilesTable> {
  $$HeatmapTilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get north =>
      $composableBuilder(column: $table.north, builder: (column) => column);

  GeneratedColumn<double> get south =>
      $composableBuilder(column: $table.south, builder: (column) => column);

  GeneratedColumn<double> get east =>
      $composableBuilder(column: $table.east, builder: (column) => column);

  GeneratedColumn<double> get west =>
      $composableBuilder(column: $table.west, builder: (column) => column);

  GeneratedColumn<double> get avgSignalQuality => $composableBuilder(
    column: $table.avgSignalQuality,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakSignalQuality => $composableBuilder(
    column: $table.peakSignalQuality,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$HeatmapTilesTableTableManager
    extends
        RootTableManager<
          _$HeatmapDatabase,
          $HeatmapTilesTable,
          HeatmapTileRow,
          $$HeatmapTilesTableFilterComposer,
          $$HeatmapTilesTableOrderingComposer,
          $$HeatmapTilesTableAnnotationComposer,
          $$HeatmapTilesTableCreateCompanionBuilder,
          $$HeatmapTilesTableUpdateCompanionBuilder,
          (
            HeatmapTileRow,
            BaseReferences<
              _$HeatmapDatabase,
              $HeatmapTilesTable,
              HeatmapTileRow
            >,
          ),
          HeatmapTileRow,
          PrefetchHooks Function()
        > {
  $$HeatmapTilesTableTableManager(
    _$HeatmapDatabase db,
    $HeatmapTilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeatmapTilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeatmapTilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeatmapTilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> north = const Value.absent(),
                Value<double> south = const Value.absent(),
                Value<double> east = const Value.absent(),
                Value<double> west = const Value.absent(),
                Value<double> avgSignalQuality = const Value.absent(),
                Value<double> peakSignalQuality = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeatmapTilesCompanion(
                id: id,
                north: north,
                south: south,
                east: east,
                west: west,
                avgSignalQuality: avgSignalQuality,
                peakSignalQuality: peakSignalQuality,
                sampleCount: sampleCount,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double north,
                required double south,
                required double east,
                required double west,
                required double avgSignalQuality,
                required double peakSignalQuality,
                required int sampleCount,
                required DateTime lastUpdated,
                Value<int> rowid = const Value.absent(),
              }) => HeatmapTilesCompanion.insert(
                id: id,
                north: north,
                south: south,
                east: east,
                west: west,
                avgSignalQuality: avgSignalQuality,
                peakSignalQuality: peakSignalQuality,
                sampleCount: sampleCount,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HeatmapTilesTableProcessedTableManager =
    ProcessedTableManager<
      _$HeatmapDatabase,
      $HeatmapTilesTable,
      HeatmapTileRow,
      $$HeatmapTilesTableFilterComposer,
      $$HeatmapTilesTableOrderingComposer,
      $$HeatmapTilesTableAnnotationComposer,
      $$HeatmapTilesTableCreateCompanionBuilder,
      $$HeatmapTilesTableUpdateCompanionBuilder,
      (
        HeatmapTileRow,
        BaseReferences<_$HeatmapDatabase, $HeatmapTilesTable, HeatmapTileRow>,
      ),
      HeatmapTileRow,
      PrefetchHooks Function()
    >;

class $HeatmapDatabaseManager {
  final _$HeatmapDatabase _db;
  $HeatmapDatabaseManager(this._db);
  $$SignalMapPointsTableTableManager get signalMapPoints =>
      $$SignalMapPointsTableTableManager(_db, _db.signalMapPoints);
  $$HeatmapTilesTableTableManager get heatmapTiles =>
      $$HeatmapTilesTableTableManager(_db, _db.heatmapTiles);
}
