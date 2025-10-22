// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Ferremateriales';

  @override
  String get profile => 'Perfil';

  @override
  String get favorite => 'Favorito';

  @override
  String get donthaveproductcategory => 'No hay productos en esta categoría';

  @override
  String get productsin => 'Productos en';

  @override
  String get buy => 'Comprar';

  @override
  String get donthavefavorite => 'No tienes productos favoritos';

  @override
  String get addToCart => 'Agregar al carrito';

  @override
  String get errorLoadingProducts => 'Error al cargar productos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get personalinformation => 'Informacion Personal';

  @override
  String get modifyinformation => 'Modificar informacion';

  @override
  String get account => 'Cuenta';

  @override
  String get settings => 'Configuración';

  @override
  String get darkTheme => 'Tema oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get name => 'Nombre';

  @override
  String get cart => 'Carrito';

  @override
  String get products => 'Productos';

  @override
  String get searchHint => 'Buscar productos...';

  @override
  String get categories => 'Categorías';

  @override
  String get tools => 'Herramientas';

  @override
  String get hardware => 'Tornillería y Fijaciones';

  @override
  String get plumbing => 'Plomería';

  @override
  String get electricity => 'Electricidad';

  @override
  String get construction => 'Construcción y Materiales';

  @override
  String get paint => 'Pintura y Acabados';

  @override
  String get homeHardware => 'Ferretería para el hogar';

  @override
  String get cleaning => 'Limpieza y Mantenimiento';

  @override
  String get adhesives => 'Adhesivos y Selladores';

  @override
  String get gardening => 'Jardinería';

  @override
  String get featuredProducts => 'Productos Destacados';

  @override
  String get price => 'Precio';

  @override
  String get quantity => 'Cantidad';

  @override
  String get total => 'Total';

  @override
  String get checkout => 'Finalizar compra';

  @override
  String get myCart => 'Mi Carrito';

  @override
  String get emptyCart => 'Tu carrito está vacío 🛒';

  @override
  String get finishPurchase => 'Finalizar Compra';

  @override
  String addedToCart(String product) {
    return '$product agregado al carrito 🛒';
  }

  @override
  String get addedToFavorites => 'Agregado a favoritos ❤️';

  @override
  String get removedFromFavorites => 'Eliminado de favoritos 💔';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get noNotifications => 'No hay notificaciones';

  @override
  String get registrationSuccess => 'Usuario registrado exitosamente';

  @override
  String get noAccount => '¿No tienes cuenta? Regístrate aquí';

  @override
  String get yesAccount => 'Do have an account? Login here';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get resetPassword => 'Recuperar contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get sendReset => 'Enviar recuperación';

  @override
  String get backToLogin => 'Volver al inicio de sesión';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get required => 'Campo requerido';

  @override
  String get invalidEmail => 'Correo no válido';

  @override
  String get resetPasswordTitle => 'Recuperar contraseña';

  @override
  String get emailRequired => 'El correo es obligatorio';

  @override
  String get sendRecovery => 'Enviar recuperación';

  @override
  String get requestSent => 'Solicitud enviada';
}
