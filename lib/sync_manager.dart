import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'db/database_helper.dart';
import 'supabase/supabase_manager.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();

  factory SyncManager() => _instance;

  SyncManager._internal();

  StreamSubscription<ConnectivityResult>? _subscription;

  void start() {
    _subscription ??=
        Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncPendingData();
      }
    });
  }

  Future<void> _syncPendingData() async {
    final pending = await DatabaseHelper().getPendingSamples();
    for (final row in pending) {
      try {
        await SupabaseManager()
            .client
            .from('sample')
            .insert({'name': row['name']});
        await DatabaseHelper().markSampleSynced(row['id'] as int);
      } catch (_) {
        // If any insert fails, stop processing to retry later
        break;
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
