import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../cubit/theme_cubit.dart';

class AcountView extends StatefulWidget {
  final String nombre;
  final String email;

  const AcountView({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  State<AcountView> createState() => _AcountViewState();
}

class _AcountViewState extends State<AcountView> {
  late TextEditingController nombreController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombre);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final I10n = AppLocalizations.of(context)!;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          // Actualizar los controladores con los nuevos valores del estado
          if (state.nombre != null && state.nombre != nombreController.text) {
            nombreController.text = state.nombre!;
          }
          if (state.email != null && state.email != emailController.text) {
            emailController.text = state.email!;
          }
          
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Información actualizada correctamente',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF66BB6A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state.status == AuthStatus.failure) {
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error ?? 'No se pudo actualizar la información',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFD32F2F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            I10n.account,
            style: const TextStyle(
              color: Color(0xFF222222),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF222222)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con avatar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2e67a3).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF2e67a3),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF2e67a3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          Text(
                            state.nombre ?? widget.nombre,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.email ?? widget.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección de información personal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                    child: Text(
                      I10n.personalinformation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),

                  // Card de información
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            _buildInfoTile(
                              icon: Icons.person_outline,
                              label: I10n.name,
                              value: state.nombre ?? widget.nombre,
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            _buildInfoTile(
                              icon: Icons.email_outlined,
                              label: I10n.email,
                              value: state.email ?? widget.email,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón de editar información
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditDialog(context, I10n),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(
                        I10n.modifyinformation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2e67a3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón de cambiar contraseña
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _showChangePasswordDialog(context, I10n),
                      icon: const Icon(Icons.lock_outline),
                      label: const Text(
                        'Cambiar contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2e67a3),
                        side: const BorderSide(color: Color(0xFF2e67a3), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón de cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2e67a3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Color(0xFF2e67a3),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Cerrar sesión',
                                    style: TextStyle(
                                      color: Color(0xFF222222),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              '¿Estás seguro de que deseas cerrar sesión?',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey.shade600,
                                ),
                                child: Text(
                                  I10n.cancel,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ThemeCubit>().resetTheme();
                                  context.read<AuthBloc>().add(LogoutRequested());
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2e67a3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2e67a3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2e67a3),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF222222),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppLocalizations I10n) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2e67a3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFF2e67a3),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      I10n.modifyinformation,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: I10n.name,
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2e67a3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2e67a3), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: I10n.email,
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2e67a3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2e67a3), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(I10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final newNombre = nombreController.text.trim();
                        final newEmail = emailController.text.trim();
                        
                        // Validación básica
                        if (newNombre.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.warning_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'El nombre no puede estar vacío',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFFF57C00),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          return;
                        }
                        
                        if (newEmail.isEmpty || !newEmail.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.warning_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Ingresa un correo válido',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFFF57C00),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          return;
                        }
                        
                        // Cerrar el diálogo primero
                        Navigator.pop(context);
                        
                        // Enviar la actualización
                        context.read<AuthBloc>().add(
                          UpdateUserRequested(
                            nombre: newNombre,
                            email: newEmail,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2e67a3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(I10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppLocalizations I10n) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            // Cerrar diálogo si hubo éxito
            Navigator.pop(context);
          }
        },
        builder: (context, state) => StatefulBuilder(
          builder: (statefulContext, setState) {
            // Actualizar errorMessage si hay un error del backend
            if (state.status == AuthStatus.failure && state.error != null) {
              errorMessage = state.error;
            }
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2e67a3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF2e67a3),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Cambiar contraseña',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Mensaje de error
                      if (errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD32F2F).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFD32F2F),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFD32F2F),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                  // Contraseña actual
                  Text(
                    'Contraseña actual',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrentPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2e67a3)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          });
                        },
                      ),
                      hintText: 'Ingresa tu contraseña actual',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2e67a3), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nueva contraseña
                  Text(
                    'Nueva contraseña',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNewPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2e67a3)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                      hintText: 'Ingresa tu nueva contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2e67a3), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Rebuild para actualizar requisitos
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Requisitos de contraseña
                  _buildPasswordRequirement(
                    'Al menos 6 caracteres',
                    newPasswordController.text.length >= 6,
                  ),
                  _buildPasswordRequirement(
                    'Una letra mayúscula',
                    newPasswordController.text.contains(RegExp(r'[A-Z]')),
                  ),
                  _buildPasswordRequirement(
                    'Una letra minúscula',
                    newPasswordController.text.contains(RegExp(r'[a-z]')),
                  ),
                  _buildPasswordRequirement(
                    'Un número',
                    newPasswordController.text.contains(RegExp(r'[0-9]')),
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirmar contraseña
                  Text(
                    'Confirmar contraseña',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2e67a3)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                      hintText: 'Confirma tu nueva contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2e67a3), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            currentPasswordController.dispose();
                            newPasswordController.dispose();
                            confirmPasswordController.dispose();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(I10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final currentPassword = currentPasswordController.text.trim();
                            final newPassword = newPasswordController.text.trim();
                            final confirmPassword = confirmPasswordController.text.trim();
                            
                            // Validaciones
                            if (currentPassword.isEmpty) {
                              setState(() {
                                errorMessage = 'Ingresa tu contraseña actual';
                              });
                              return;
                            }
                            
                            if (newPassword.length < 6 ||
                                !newPassword.contains(RegExp(r'[A-Z]')) ||
                                !newPassword.contains(RegExp(r'[a-z]')) ||
                                !newPassword.contains(RegExp(r'[0-9]'))) {
                              setState(() {
                                errorMessage = 'La contraseña no cumple los requisitos';
                              });
                              return;
                            }
                            
                            if (newPassword != confirmPassword) {
                              setState(() {
                                errorMessage = 'Las contraseñas no coinciden';
                              });
                              return;
                            }
                            
                            // Limpiar mensaje de error antes de enviar
                            setState(() {
                              errorMessage = null;
                            });
                            
                            // Enviar evento para cambiar contraseña
                            context.read<AuthBloc>().add(
                              ChangePasswordFromAccountRequested(
                                currentPassword: currentPassword,
                                newPassword: newPassword,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2e67a3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: Text(I10n.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: isMet ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? Colors.green : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

