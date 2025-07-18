import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'supabase/supabase_manager.dart';
import 'sync_manager.dart';
import 'config_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager().init();
  await DatabaseHelper().database;
  SyncManager().start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siscont Restaurantes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = '';

  Future<void> _addSample() async {
    final id =
        await DatabaseHelper().insertSample('Registro ${DateTime.now()}');
    setState(() {
      _result = 'Inserido localmente id $id';
    });
  }

  Future<void> _fetchEmpresas() async {
    try {
      final data =
          await SupabaseManager().client.from('CADE_EMPRESA').select();
      setState(() {
        _result = 'Encontrado: ${data.length} registros';
      });
    } catch (e) {
      setState(() {
        _result = 'Erro ao conectar ao Supabase';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Siscont Restaurantes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vindo ao Siscont Restaurantes!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSample,
              child: const Text('Adicionar Registro Local'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchEmpresas,
              child: const Text('Testar Supabase'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfigPage(),
                  ),
                );
              },
              child: const Text('Configurar Empresa'),
            ),
            const SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
