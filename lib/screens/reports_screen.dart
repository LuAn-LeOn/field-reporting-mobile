import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/report_storage_service.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final ReportStorageService _storageService = ReportStorageService();

  List<ReportModel> _reports = [];
  List<ReportModel> _filteredReports = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _storageService.getReports();

      setState(() {
        _reports = reports;
        _filteredReports = reports;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar reportes: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openReportDetail(ReportModel report) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailScreen(report: report),
      ),
    );

    _loadReports();
  }

  void _filterReports(String query) {
    setState(() {
      _filteredReports = _reports.where((report) {
        return report.folio.toLowerCase().contains(query.toLowerCase()) ||
            report.stationName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Color _getSyncStatusColor(String syncStatus) {
    switch (syncStatus) {
      case 'LOCAL_ONLY':
        return Colors.blue;
      case 'PENDING_SYNC':
        return Colors.orange;
      case 'SYNCING':
        return Colors.purple;
      case 'SYNCED':
        return Colors.green;
      case 'SYNC_ERROR':
        return Colors.red;
      case 'LOCAL_DELETED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getSyncStatusText(String syncStatus) {
    switch (syncStatus) {
      case 'LOCAL_ONLY':
        return 'Local';
      case 'PENDING_SYNC':
        return 'Pendiente';
      case 'SYNCING':
        return 'Sincronizando';
      case 'SYNCED':
        return 'Sincronizado';
      case 'SYNC_ERROR':
        return 'Error';
      case 'LOCAL_DELETED':
        return 'Solo nube';
      default:
        return 'Desconocido';
    }
  }

  Color _getFormStatusColor(String formStatus) {
    switch (formStatus) {
      case 'DRAFT':
        return Colors.blueGrey;
      case 'READY_FOR_SYNC':
        return Colors.orange;
      case 'LOCKED':
        return Colors.green;
      case 'ARCHIVED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getFormStatusText(String formStatus) {
    switch (formStatus) {
      case 'DRAFT':
        return 'Editable';
      case 'READY_FOR_SYNC':
        return 'Listo';
      case 'LOCKED':
        return 'Bloqueado';
      case 'ARCHIVED':
        return 'Archivado';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          'Mis Reportes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterReports,
              decoration: InputDecoration(
                hintText: 'Buscar folio o estación...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_filteredReports.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay reportes guardados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los reportes locales aparecerán aquí',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadReports,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = _filteredReports[index];

                    return GestureDetector(
                      onTap: () => _openReportDetail(report),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  report.folio,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getSyncStatusColor(
                                      report.syncStatus,
                                    ).withOpacity(0.15),
                                    borderRadius:
                                    BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    _getSyncStatusText(
                                      report.syncStatus,
                                    ),
                                    style: TextStyle(
                                      color: _getSyncStatusColor(
                                        report.syncStatus,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              report.stationName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              report.location,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              report.observations,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getFormStatusColor(
                                          report.formStatus,
                                        ).withOpacity(0.12),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getFormStatusText(
                                          report.formStatus,
                                        ),
                                        style: TextStyle(
                                          color: _getFormStatusColor(
                                            report.formStatus,
                                          ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.photo_library,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${report.images.length}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}