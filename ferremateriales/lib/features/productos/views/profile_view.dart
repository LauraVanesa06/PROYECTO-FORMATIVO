import 'package:ferremateriales/features/auth/bloc/auth_event.dart';
import 'package:ferremateriales/features/auth/bloc/auth_state.dart';
import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/views/login_view.dart';
import '../../auth/views/register_view.dart';
import 'acount_view.dart';
import 'config_view.dart';

class ProfileView extends StatelessWidget {
  final String userName;
  final String? userPhotoUrl;

  const ProfileView({super.key, this.userName = "", this.userPhotoUrl});

  @override
  Widget build(BuildContext context) {
    final I10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;

    // Si el usuario es invitado, mostrar pantalla de bienvenida
    if (authState.status == AuthStatus.guest) {
      return _buildGuestView(context, isDark);
    }

    // Si el usuario está autenticado, mostrar perfil normal
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status == AuthStatus.loggedOut,
      listener: (context, state) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
          elevation: 0,
          title: Text(
            I10n.profile,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF222222),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Header con avatar y nombre
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2e67a3),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2e67a3).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 58,
                        backgroundColor: const Color(0xFF2e67a3).withOpacity(0.1),
                        backgroundImage: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                            ? NetworkImage(userPhotoUrl!)
                            : null,
                        child: (userPhotoUrl == null || userPhotoUrl!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF2e67a3),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userName.isNotEmpty ? userName : "Usuario",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2e67a3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Opciones de perfil
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMenuCard(
                      context: context,
                      icon: Icons.account_circle_outlined,
                      title: I10n.account,
                      subtitle: 'Administra tu información personal',
                      onTap: () {
                        final authState = context.read<AuthBloc>().state;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AcountView(
                              nombre: authState.nombre ?? "",
                              email: authState.email ?? "",
                            ),
                          ),
                        );
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.settings_outlined,
                      title: I10n.settings,
                      subtitle: 'Preferencias y configuración',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConfigView(),
                          ),
                        );
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.help_outline,
                      title: 'Ayuda y soporte',
                      subtitle: 'Preguntas frecuentes y contacto',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Función en desarrollo'),
                            backgroundColor: const Color(0xFF2e67a3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.info_outline,
                      title: 'Acerca de',
                      subtitle: 'Información de la aplicación',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Ferremateriales'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Versión 3.1.4',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '© 2025 Ferremateriales',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tu tienda de confianza para materiales de construcción y herramientas.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 32),

                    // Botón de cerrar sesión
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Cerrar sesión'),
                              content: const Text(
                                '¿Estás seguro de que deseas cerrar sesión?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.read<AuthBloc>().add(LogoutRequested());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Cerrar sesión'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: Text(
                          I10n.logout,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2e67a3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2e67a3),
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista para usuarios invitados (no autenticados)
  Widget _buildGuestView(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        elevation: 0,
        title: Text(
          'Perfil',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Ícono grande
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2e67a3).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF2e67a3).withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 70,
                  color: Color(0xFF2e67a3),
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 12),

              // Descripción
              Text(
                'Inicia sesión o regístrate para acceder a todas las funcionalidades',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 48),

              // Botón de Iniciar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginView()),
                    );
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2e67a3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón de Registrarse
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterView()),
                    );
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: isDark ? Colors.white : const Color(0xFF2e67a3),
                  ),
                  label: Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2e67a3),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: isDark ? Colors.white : const Color(0xFF2e67a3),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Características
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.shopping_cart,
                      title: 'Realizar compras',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.star,
                      title: 'Guardar favoritos',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.history,
                      title: 'Ver historial de pedidos',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.local_shipping,
                      title: 'Seguimiento de envíos',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2e67a3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2e67a3),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
