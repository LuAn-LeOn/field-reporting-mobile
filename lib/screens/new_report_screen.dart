import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report_model.dart';
import '../services/report_storage_service.dart';

class NewReportScreen extends StatefulWidget {
  final ReportModel? reportToEdit;

  const NewReportScreen({
    super.key,
    this.reportToEdit,
  });

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController folioController = TextEditingController();
  final TextEditingController stationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController observationsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final ReportStorageService _storageService = ReportStorageService();

  final List<XFile> selectedImages = [];

  bool _isSaving = false;
  bool _isLoadingFolio = false;

  bool get _isEditing => widget.reportToEdit != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final report = widget.reportToEdit!;

      folioController.text = report.folio;
      stationController.text = report.stationName;
      locationController.text = report.location;
      observationsController.text = report.observations;

      selectedImages.addAll(
        report.images.map((image) => XFile(image.filePath)),
      );
    } else {
      _generateAutomaticFolio();
    }
  }

  Future<void> _generateAutomaticFolio() async {
    setState(() {
      _isLoadingFolio = true;
    });

    try {
      final folio = await _storageService.generateNextFolio();

      if (!mounted) return;

      setState(() {
        folioController.text = folio;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar folio: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFolio = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    if (selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo puedes agregar máximo 10 imágenes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImages.add(image);
      });
    }
  }

  Future<void> _saveReport() async {
    if (_isSaving || _isLoadingFolio) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos una evidencia fotográfica'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final report = await _storageService.saveReport(
        folio: folioController.text.trim(),
        stationName: stationController.text.trim(),
        location: locationController.text.trim(),
        observations: observationsController.text.trim(),
        images: selectedImages,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Reporte ${report.folio} actualizado localmente'
                : 'Reporte ${report.folio} guardado localmente',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el reporte: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    folioController.dispose();
    stationController.dispose();
    locationController.dispose();
    observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D91),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Editar Reporte' : 'Nuevo Reporte',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Folio',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: folioController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: _isLoadingFolio
                        ? 'Generando folio...'
                        : 'Folio automático',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    suffixIcon: _isLoadingFolio
                        ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                        : const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El folio automático no se pudo generar';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Nombre de la estación',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: stationController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: true,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el nombre de la estación',
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre de la estación es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Ubicación (opcional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa la ubicación',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Observaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: observationsController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: 'Describe el fallo, incidente u observación...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Las observaciones son obligatorias';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Evidencias (imágenes)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                GestureDetector(
                  onTap: _isSaving ? null : _takePhoto,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFB5C9F1),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFEAF2FF),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Color(0xFF0A3D91),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tomar foto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Máximo 10 imágenes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedImages.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final image = selectedImages[index];

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(image.path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (!_isSaving)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A3D91),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: (_isSaving || _isLoadingFolio)
                        ? null
                        : _saveReport,
                    child: _isSaving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _isEditing
                          ? 'Actualizar Reporte'
                          : 'Guardar Reporte',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}