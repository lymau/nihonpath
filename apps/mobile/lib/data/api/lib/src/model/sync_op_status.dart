//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_op_status.g.dart';

/// Status pemrosesan operasi di server (§7.2)
class SyncOpStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accepted')
  static const SyncOpStatus accepted = _$accepted;
  @BuiltValueEnumConst(wireName: r'duplicate')
  static const SyncOpStatus duplicate = _$duplicate;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const SyncOpStatus rejected = _$rejected;

  static Serializer<SyncOpStatus> get serializer => _$syncOpStatusSerializer;

  const SyncOpStatus._(String name) : super(name);

  static BuiltSet<SyncOpStatus> get values => _$values;
  static SyncOpStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class SyncOpStatusMixin = Object with _$SyncOpStatusMixin;
