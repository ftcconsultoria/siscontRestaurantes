import 'package:flutter/material.dart';
import 'supabase/supabase_manager.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final TextEditingController _cnpjController = TextEditingController();
  String _result = '';

  Future<void> _fetchEmpresa() async {
    final cnpj = _cnpjController.text.trim();
    if (cnpj.isEmpty) return;
    try {
      final data = await SupabaseManager()
          .client
          .from('CADE_EMPRESA')
          .select()
          .eq('cemp_cnpj', cnpj)
          .maybeSingle();
      setState(() {
        if (data == null) {
          _result = 'Empresa não encontrada';
        } else {
          _result = 'Empresa: ${data['cemp_nome_fantasia'] ?? 'sem nome'}';
        }
      });
    } catch (_) {
      setState(() {
        _result = 'Erro ao buscar empresa';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _cnpjController,
              decoration: const InputDecoration(labelText: 'CNPJ'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchEmpresa,
              child: const Text('Buscar Empresa'),
            ),
            const SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
