import 'package:flutter/material.dart';

import '../models/pending_user_model.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

class AdminPendingUsersScreen
    extends StatefulWidget {
  const AdminPendingUsersScreen({
    super.key,
  });

  @override
  State<AdminPendingUsersScreen>
  createState() =>
      _AdminPendingUsersScreenState();
}

class _AdminPendingUsersScreenState
    extends State<
        AdminPendingUsersScreen> {
  final AuthService _authService =
  AuthService();

  final SessionService _sessionService =
  SessionService();

  bool _isLoading = true;

  List<PendingUserModel>
  _pendingUsers = [];

  @override
  void initState() {
    super.initState();

    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    try {
      final token =
      await _sessionService.getToken();

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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _activateUser(
      PendingUserModel user,
      ) async {
    try {
      final token =
      await _sessionService.getToken();

      if (token == null) {
        return;
      }

      await _authService.activateUser(
        token: token,
        userId: user.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${user.fullName} autorizado correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await _loadPendingUsers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Usuarios pendientes',
        ),
        backgroundColor:
        const Color(0xFF0A3D91),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : _pendingUsers.isEmpty
          ? const Center(
        child: Text(
          'No hay usuarios pendientes',
        ),
      )
          : ListView.builder(
        padding:
        const EdgeInsets.all(
          16,
        ),
        itemCount:
        _pendingUsers.length,
        itemBuilder:
            (context, index) {
          final user =
          _pendingUsers[index];

          return Card(
            margin:
            const EdgeInsets.only(
              bottom: 16,
            ),
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),
            child: Padding(
              padding:
              const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    user.fullName,
                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    user.email,
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    user.role,
                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF0A3D91,
                      ),
                      fontWeight:
                      FontWeight
                          .w600,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    child:
                    ElevatedButton(
                      onPressed: () =>
                          _activateUser(
                            user,
                          ),
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        const Color(
                          0xFF0A3D91,
                        ),
                        foregroundColor:
                        Colors.white,
                      ),
                      child:
                      const Text(
                        'Autorizar acceso',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}