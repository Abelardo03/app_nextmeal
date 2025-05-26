import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_nextmeal/pages/config.dart';
class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);
  @override
  _DebugPageState createState() => _DebugPageState();
}
class _DebugPageState extends State<DebugPage> {
  bool _isLoading = false;
  String _responseData = 'No hay datos';
  String _currentEndpoint = '/api/dashboard/resumen';
  final TextEditingController _endpointController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _endpointController.text = _currentEndpoint;
  }
  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _responseData = 'Cargando...';
    });
    try {
      final String baseUrl = 'http://${Config.apiurl}';
      final String endpoint = _endpointController.text.trim();
      print('Solicitando datos de: $baseUrl$endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Respuesta del servidor: ${response.statusCode}');
      if (response.statusCode == 200) {
        // Intentar formatear el JSON para mejor legibilidad
        try {
          final dynamic jsonData = json.decode(response.body);
          final String prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);
          setState(() {
            _responseData = prettyJson;
            _currentEndpoint = endpoint;
          });
        } catch (e) {
          setState(() {
            _responseData = 'Error al formatear JSON: $e\n\nRespuesta cruda:\n${response.body}';
          });
        }
      } else {
        setState(() {
          _responseData = 'Error ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseData = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depuración API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'URL Base: http://${Config.apiurl}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _endpointController,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint',
                      border: OutlineInputBorder(),
                      hintText: '/api/dashboard/resumen',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchData,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Probar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickButton('/api/dashboard/resumen'),
                _buildQuickButton('/api/dashboard/ventas-recientes'),
                _buildQuickButton('/api/dashboard/estadisticas/semanal'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Respuesta:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_responseData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuickButton(String endpoint) {
    return TextButton(
      onPressed: () {
        _endpointController.text = endpoint;
        _fetchData();
      },
      child: Text(endpoint.split('/').last),
    );
  }
}