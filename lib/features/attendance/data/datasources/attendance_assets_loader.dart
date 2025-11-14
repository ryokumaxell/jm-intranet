import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_import_service.dart';

class AttendanceAssetsLoader {
  final FirebaseFirestore _firestore;

  AttendanceAssetsLoader(this._firestore);

  /// Carga y procesa automáticamente los archivos JSON de assets
  /// Detecta la compañía del nombre del archivo
  Future<void> loadAndImportFromAssets() async {
    try {
      // Lista de archivos JSON conocidos
      final files = [
        'assets/data/asis_helaco_20-10-25a25-10-25.json',
        // Agregar más archivos aquí según sea necesario
      ];

      for (final filePath in files) {
        try {
          // Cargar el archivo
          final jsonString = await rootBundle.loadString(filePath);
          final jsonData = jsonDecode(jsonString);

          // Detectar compañía del nombre del archivo
          final company = _detectCompanyFromFileName(filePath);

          if (company != null && jsonData is List) {
            // Importar los datos
            final service = AttendanceImportService(_firestore);
            await service.importAttendanceFromJson(jsonData, company);
            print('✅ Importados datos de $company desde $filePath');
          }
        } catch (e) {
          print('⚠️ Error procesando $filePath: $e');
        }
      }
    } catch (e) {
      print('❌ Error en loadAndImportFromAssets: $e');
    }
  }

  /// Detecta la compañía del nombre del archivo
  /// Ej: "asis_helaco_20-10-25a25-10-25.json" -> "Helaco"
  String? _detectCompanyFromFileName(String filePath) {
    final fileName = filePath.toLowerCase();

    if (fileName.contains('helaco')) {
      return 'Helaco';
    } else if (fileName.contains('jaysa') ||
        fileName.contains('jaysa_muebles')) {
      return 'Jaysa Muebles';
    }

    return null;
  }

  /// Obtiene la lista de archivos JSON disponibles en assets con información de fechas
  Future<List<Map<String, String>>> getAvailableFilesWithDates() async {
    final files = [
      'assets/data/asis_helaco_01a06-09-25.json',
      'assets/data/asis_helaco_02a07-06-25.json',
      'assets/data/asis_helaco_03-11-25 a 08-11-25.json',
      'assets/data/asis_helaco_04a09-08-25.json',
      'assets/data/asis_helaco_06-10-25 a 11-10-25.json',
      'assets/data/asis_helaco_07a12-07-25.json',
      'assets/data/asis_helaco_08a13-09-25.json',
      'assets/data/asis_helaco_09a14-06-25.json',
      'assets/data/asis_helaco_11a16-08-25.json',
      'assets/data/asis_helaco_12a17-05-25.json',
      'assets/data/asis_helaco_13-10-25 a 18-10-25.json',
      'assets/data/asis_helaco_14a19-07-25.json',
      'assets/data/asis_helaco_15a20-09-25.json',
      'assets/data/asis_helaco_16a21-06-25.json',
      'assets/data/asis_helaco_18a23-08-25.json',
      'assets/data/asis_helaco_19a24-05-25.json',
      'assets/data/asis_helaco_20-10-25 a 25-10-25.json',
      'assets/data/asis_helaco_20-10-25a25-10-25.json',
      'assets/data/asis_helaco_21a26-07-25.json',
      'assets/data/asis_helaco_22a27-09-25.json',
      'assets/data/asis_helaco_23a28-06-25.json',
      'assets/data/asis_helaco_25a30-08-25.json',
      'assets/data/asis_helaco_26a31-05-25.json',
      'assets/data/asis_helaco_27-10-25 a 01-11-25.json',
      'assets/data/asis_helaco_28-07a02-08-25.json',
      'assets/data/asis_helaco_29-09-25 a 04-10-25.json',
      'assets/data/asis_helaco_30-06a04-07-25.json',
      'assets/data/asis_jaysamuebles_01a06-09-25.json',
      'assets/data/asis_jaysamuebles_02a07-06-25.json',
      'assets/data/asis_jaysamuebles_03-11-25 a 08-11-25.json',
      'assets/data/asis_jaysamuebles_04a09-08-25.json',
      'assets/data/asis_jaysamuebles_06-10-25 a 11-10-25.json',
      'assets/data/asis_jaysamuebles_07a12-07-25.json',
      'assets/data/asis_jaysamuebles_08a13-09-25.json',
      'assets/data/asis_jaysamuebles_09a14-06-25.json',
      'assets/data/asis_jaysamuebles_11a16-08-25.json',
      'assets/data/asis_jaysamuebles_12a17-05-25.json',
      'assets/data/asis_jaysamuebles_13-10-25 a 18-10-25.json',
      'assets/data/asis_jaysamuebles_14a19-07-25.json',
      'assets/data/asis_jaysamuebles_15a20-09-25.json',
      'assets/data/asis_jaysamuebles_16a21-06-25.json',
      'assets/data/asis_jaysamuebles_18a23-08-25.json',
      'assets/data/asis_jaysamuebles_19a24-05-25.json',
      'assets/data/asis_jaysamuebles_20-10-25 a 25-10-25.json',
      'assets/data/asis_jaysamuebles_21a26-07-25.json',
      'assets/data/asis_jaysamuebles_22a27-09-25.json',
      'assets/data/asis_jaysamuebles_23a28-06-25.json',
      'assets/data/asis_jaysamuebles_25a30-08-25.json',
      'assets/data/asis_jaysamuebles_26a31-05-25.json',
      'assets/data/asis_jaysamuebles_27-10-25 a 01-11-25.json',
      'assets/data/asis_jaysamuebles_28-07a02-08-25.json',
      'assets/data/asis_jaysamuebles_29-09-25 a 04-10-25.json',
      'assets/data/asis_jaysamuebles_30-06a04-07-25.json',
    ];

    return files.map((filePath) {
      final fileName = filePath.split('/').last.replaceAll('.json', '');
      final company = _detectCompanyFromFileName(filePath);
      final dateRange = _extractDateRange(fileName);

      return {
        'path': filePath,
        'fileName': fileName,
        'company': company ?? 'Desconocida',
        'dateRange': dateRange,
      };
    }).toList();
  }

  /// Extrae el rango de fechas del nombre del archivo
  /// Ej: "asis_helaco_20-10-25a25-10-25" -> "20-10-25 a 25-10-25"
  String _extractDateRange(String fileName) {
    // Remover prefijo "asis_helaco_" o "asis_jaysamuebles_"
    String dateStr =
        fileName.replaceAll(RegExp(r'^asis_(helaco|jaysamuebles)_'), '');
    return dateStr;
  }
}
