import 'package:flutter/material.dart';

import '../models/login_response_model.dart';
import '../models/pending_user_model.dart';
import '../models/report_model.dart';

import '../services/auth_service.dart';
import '../services/report_storage_service.dart';
import '../services/session_service.dart';

import 'admin_pending_users_screen.dart';
import 'login_screen.dart';
import 'new_report_screen.dart';
import 'report_detail_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  final ReportStorageService
  _storageService =
  ReportStorageService();

  final AuthService _authService =
  AuthService();

  final SessionService
  _sessionService =
  SessionService();

  List<ReportModel> _recentReports =
  [];

  List<PendingUserModel>
  _pendingUsers = [];

  LoginResponseModel? _currentUser;

  bool _isLoadingReports = true;

  bool _isLoadingPendingUsers =
  false;

  @override
  void initState() {
    super.initState();

    _initializeDashboard();
  }

  Future<void>
  _initializeDashboard() async {
    await _loadCurrentUser();

    await _loadRecentReports();

    if (_currentUser?.user.role ==
        'Administrador') {
      await _loadPendingUsers();
    }
  }

  Future<void>
  _loadCurrentUser() async {
    final user =
    await _sessionService
        .getSession();

    if (!mounted) return;

    setState(() {
      _currentUser = user;
    });
  }

  Future<void>
  _loadPendingUsers() async {
    try {
      setState(() {
        _isLoadingPendingUsers =
        true;
      });

      final token =
      await _sessionService
          .getToken();

      if (token == null) {
        return;
      }

      final users =
      await _authService
          .getPendingUsers(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _pendingUsers = users;
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPendingUsers =
          false;
        });
      }
    }
  }

  Future<void>
  _loadRecentReports() async {
    try {
      final reports =
      await _storageService
          .getReports();

      setState(() {
        _recentReports =
            reports.take(3).toList();

        _isLoadingReports = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingReports = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar reportes: $error',
          ),
          backgroundColor:
          Colors.red,
        ),
      );
    }
  }

  void _logout(
      BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const LoginScreen(),
      ),
          (route) => false,
    );
  }

  Future<void> _goToReports(
      BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const ReportsScreen(),
      ),
    );

    _loadRecentReports();
  }

  Future<void> _goToNewReport(
      BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const NewReportScreen(),
      ),
    );

    _loadRecentReports();
  }

  Future<void>
  _goToReportDetail(
      BuildContext context,
      ReportModel report,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReportDetailScreen(
              report: report,
            ),
      ),
    );

    _loadRecentReports();
  }

  Color _getSyncStatusColor(
      String syncStatus) {
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

  String _getSyncStatusText(
      String syncStatus) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration:
              const BoxDecoration(
                color:
                Color(0xFF0A3D91),
              ),
              accountName: Text(
                _currentUser
                    ?.user.fullName ??
                    'Usuario',
              ),
              accountEmail: Text(
                _currentUser
                    ?.user.email ??
                    '',
              ),
              currentAccountPicture:
              const CircleAvatar(
                backgroundColor:
                Colors.white,
                child: Icon(
                  Icons.person,
                  color:
                  Color(0xFF0A3D91),
                  size: 40,
                ),
              ),
            ),

            ListTile(
              leading:
              const Icon(Icons.home),
              title:
              const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.description,
              ),
              title: const Text(
                'Reportes',
              ),
              onTap: () {
                Navigator.pop(context);

                _goToReports(context);
              },
            ),

            ListTile(
              leading:
              const Icon(Icons.sync),
              title: const Text(
                'Sincronizar',
              ),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text(
                'Configuración',
              ),
              onTap: () {},
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              onTap: () =>
                  _logout(context),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      backgroundColor:
      const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFF0A3D91),
        foregroundColor:
        Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon:
              const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context)
                    .openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:
          _loadRecentReports,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  'Hola, ${_currentUser?.user.fullName.split(' ').first ?? 'Usuario'} 👋',
                  style:
                  const TextStyle(
                    fontSize: 30,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Colors.black87,
                  ),
                ),

                const SizedBox(
                    height: 6),

                Text(
                  'Bienvenido al sistema',
                  style: TextStyle(
                    color: Colors
                        .grey.shade600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                    height: 28),

                if (_currentUser
                    ?.user.role ==
                    'Administrador')
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator
                              .push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const AdminPendingUsersScreen(),
                            ),
                          );

                          _loadPendingUsers();
                        },
                        child: Container(
                          width:
                          double.infinity,
                          padding:
                          const EdgeInsets
                              .all(18),
                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white,
                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                  0.04,
                                ),
                                blurRadius:
                                10,
                                offset:
                                const Offset(
                                  0,
                                  4,
                                ),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration:
                                BoxDecoration(
                                  color: Colors
                                      .orange,
                                  borderRadius:
                                  BorderRadius.circular(
                                    18,
                                  ),
                                ),
                                child:
                                const Icon(
                                  Icons
                                      .admin_panel_settings,
                                  color: Colors
                                      .white,
                                  size: 34,
                                ),
                              ),

                              const SizedBox(
                                width: 18,
                              ),

                              Expanded(
                                child:
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Usuarios pendientes',
                                      style:
                                      TextStyle(
                                        fontSize:
                                        20,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height:
                                      6,
                                    ),

                                    Text(
                                      _isLoadingPendingUsers
                                          ? 'Consultando solicitudes...'
                                          : _pendingUsers.isEmpty
                                          ? 'No hay usuarios pendientes'
                                          : 'Tienes ${_pendingUsers.length} usuarios esperando autorización',
                                      style:
                                      TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 28),
                    ],
                  ),

                GestureDetector(
                  onTap: () =>
                      _goToNewReport(
                        context,
                      ),
                  child: Container(
                    padding:
                    const EdgeInsets
                        .all(18),
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,
                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                            0.04,
                          ),
                          blurRadius: 10,
                          offset:
                          const Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFF0A3D91,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                          ),
                          child:
                          const Icon(
                            Icons.add,
                            color: Colors
                                .white,
                            size: 36,
                          ),
                        ),

                        const SizedBox(
                            width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              const Text(
                                'Nuevo Reporte',
                                style:
                                TextStyle(
                                  fontSize:
                                  22,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                  6),

                              Text(
                                'Crear un nuevo reporte',
                                style:
                                TextStyle(
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons
                              .arrow_forward_ios,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                    height: 34),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
                  children: [
                    const Text(
                      'Reportes recientes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _goToReports(
                          context,
                        );
                      },
                      child:
                      const Text(
                        'Ver todos',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 12),

                if (_isLoadingReports)
                  const Center(
                    child:
                    CircularProgressIndicator(),
                  )
                else if (_recentReports
                    .isEmpty)
                  Container(
                    width:
                    double.infinity,
                    padding:
                    const EdgeInsets
                        .all(24),
                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,
                      borderRadius:
                      BorderRadius
                          .circular(
                        18,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .folder_open,
                          size: 60,
                          color: Colors
                              .grey
                              .shade400,
                        ),
                        const SizedBox(
                            height: 12),
                        Text(
                          'No hay reportes recientes',
                          style:
                          TextStyle(
                            fontSize:
                            18,
                            fontWeight:
                            FontWeight
                                .bold,
                            color: Colors
                                .grey
                                .shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._recentReports
                      .map(
                        (report) {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child:
                        GestureDetector(
                          onTap: () =>
                              _goToReportDetail(
                                context,
                                report,
                              ),
                          child:
                          _buildReportCard(
                            folio:
                            report.folio,
                            station:
                            report.stationName,
                            date:
                            '${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}',
                            time:
                            '${report.reportDate.hour.toString().padLeft(2, '0')}:${report.reportDate.minute.toString().padLeft(2, '0')}',
                            syncStatus:
                            report.syncStatus,
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(
                    height: 40),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor:
        const Color(0xFF0A3D91),
        unselectedItemColor:
        Colors.grey,
        type:
        BottomNavigationBarType
            .fixed,
        onTap: (index) {
          if (index == 1) {
            _goToReports(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons
                  .description_outlined,
            ),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Sincronizar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String folio,
    required String station,
    required String date,
    required String time,
    required String syncStatus,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.03),
            blurRadius: 8,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  folio,
                  style:
                  const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 6),

                Text(
                  station,
                  style: TextStyle(
                    color: Colors
                        .grey.shade700,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(
                  '$date • $time',
                  style: TextStyle(
                    color: Colors
                        .grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color: _getSyncStatusColor(
                      syncStatus)
                      .withOpacity(
                    0.15,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    30,
                  ),
                ),
                child: Text(
                  _getSyncStatusText(
                    syncStatus,
                  ),
                  style: TextStyle(
                    color:
                    _getSyncStatusColor(
                      syncStatus,
                    ),
                    fontWeight:
                    FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(
                  height: 18),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}