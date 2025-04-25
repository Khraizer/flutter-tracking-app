import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class TrackingScreen extends StatefulWidget {
  final int userId;

  const TrackingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late Map<String, dynamic> _metadata = {};
  bool _isLoading = true;
  late Timer _updateTimer;
  final String _apiUrl = 'https://tracking-api-l4v2.onrender.com'; 

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 Iniciando seguimiento para usuario ID: ${widget.userId}');
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    debugPrint('⏹ TrackingScreen destruido');
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/metadata/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('📡 Respuesta API: ${response.body}'); // Log completo

        if (responseData['data'] != null && responseData['data'].isNotEmpty) {
          final metadata = responseData['data'][0];
          
          if (mounted) {
            setState(() {
              _metadata = metadata;
              _isLoading = false;
            });
          }
          debugPrint('✅ Datos actualizados: $_metadata');
        } else {
          throw Exception('El campo "data" está vacío en la respuesta');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      debugPrint('⏳ Tiempo de espera agotado');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El servidor no respondió a tiempo')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _startAutoRefresh() {
    _updateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      debugPrint('🔄 Actualización automática a las ${DateTime.now()}');
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo en Tiempo Real'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDataCard(
                    title: 'Ubicación',
                    icon: Icons.location_pin,
                    color: Colors.red,
                    children: [
                      _buildDataRow('Latitud', _metadata['latitud']?.toStringAsFixed(6) ?? 'N/A'),
                      _buildDataRow('Longitud', _metadata['longitud']?.toStringAsFixed(6) ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDataCard(
                    title: 'Movimiento',
                    icon: Icons.speed,
                    color: Colors.blue,
                    children: [
                      _buildDataRow('Velocidad', '${_metadata['velocidad']?.toStringAsFixed(2) ?? 'N/A'} km/h'),
                      _buildDataRow('Inclinación', '${_metadata['inclinacion']?.toStringAsFixed(2) ?? 'N/A'}°'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDataCard(
                    title: 'Medio Ambiente',
                    icon: Icons.air,
                    color: Colors.green,
                    children: [
                      _buildDataRow('Contaminación', '${_metadata['contaminacion']?.toStringAsFixed(2) ?? 'N/A'} ppm'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDataCard(
                    title: 'Información Temporal',
                    icon: Icons.access_time,
                    color: Colors.orange,
                    children: [
                      _buildDataRow('Hora', _metadata['hora']?.toString() ?? 'N/A'),
                      _buildDataRow('Fecha', _metadata['fecha']?.toString() ?? 'N/A'),
                      _buildDataRow('Última actualización', 
                        _metadata['updated_at']?.toString().replaceFirst('T', ' ') ?? 'N/A'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}