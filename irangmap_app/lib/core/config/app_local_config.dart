import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppLocalConfig {
  final String iosBannerAdUnitId;
  final String androidBannerAdUnitId;

  const AppLocalConfig({
    this.iosBannerAdUnitId = '',
    this.androidBannerAdUnitId = '',
  });

  static const empty = AppLocalConfig();

  factory AppLocalConfig.fromJson(Map<String, dynamic> json) {
    return AppLocalConfig(
      iosBannerAdUnitId: (json['iosBannerAdUnitId'] as String? ?? '').trim(),
      androidBannerAdUnitId: (json['androidBannerAdUnitId'] as String? ?? '').trim(),
    );
  }

  String get bannerAdUnitId {
    if (kIsWeb) {
      return '';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosBannerAdUnitId;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidBannerAdUnitId;
    }
    return '';
  }
}

final appLocalConfigProvider = FutureProvider<AppLocalConfig>((ref) async {
  try {
    final raw = await rootBundle.loadString('assets/config/app.local.json');
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return AppLocalConfig.fromJson(decoded);
    }
  } catch (_) {
    // Local config is optional. Missing file should not affect app startup.
  }

  return AppLocalConfig.empty;
});
