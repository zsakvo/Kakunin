// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: avoid_private_typedef_functions, non_constant_identifier_names, subtype_of_sealed_class, invalid_use_of_internal_member, unused_element, constant_identifier_names, unnecessary_raw_strings, library_private_types_in_public_api

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

String _$helloWorldHash() => r'abb9256da92254087fad4bb1aa878e7aab701c63';

/// See also [helloWorld].
final helloWorldProvider = AutoDisposeProvider<String>(
  helloWorld,
  name: r'helloWorldProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$helloWorldHash,
);
typedef HelloWorldRef = AutoDisposeProviderRef<String>;
String _$progressValueHash() => r'a0892bfbacc721fe904504f018cdd65c7754639c';

/// See also [progressValue].
final progressValueProvider = AutoDisposeProvider<double>(
  progressValue,
  name: r'progressValueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressValueHash,
);
typedef ProgressValueRef = AutoDisposeProviderRef<double>;
