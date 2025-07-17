import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseManager _instance = SupabaseManager._internal();

  factory SupabaseManager() => _instance;

  SupabaseManager._internal();

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://boshhbyxjgbqqjshtlgp.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJvc2hoYnl4amdicXFqc2h0bGdwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Mjc3OTY4OSwiZXhwIjoyMDY4MzU1Njg5fQ.9umD1qmK1NUnRyZDdgkJs6bDXIFS_1374Pq5PkdvXTM',
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}
