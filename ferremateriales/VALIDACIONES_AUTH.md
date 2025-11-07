# Validaciones de Autenticación

Este documento describe las validaciones implementadas en el sistema de autenticación.

## 📧 Validación de Email

### Reglas implementadas:
- **Campo obligatorio**: No puede estar vacío
- **Formato válido**: Debe contener `@` y un dominio válido
- **Dominio válido**: Debe tener un punto después del `@`
- **Extensión válida**: Mínimo 2 caracteres después del último punto
- **Longitud mínima**: Al menos 5 caracteres

### Ejemplos:
✅ **Válidos**:
- usuario@ejemplo.com
- nombre.apellido@empresa.co
- test123@dominio.org

❌ **Inválidos**:
- usuario (falta @)
- usuario@ejemplo (falta extensión)
- @ejemplo.com (falta usuario)
- usuario@.com (dominio inválido)

---

## 🔒 Validación de Contraseña

### Reglas implementadas:

#### 1. **Longitud mínima**
- Mínimo 8 caracteres

#### 2. **Complejidad**
La contraseña debe contener:
- Al menos **1 letra mayúscula** (A-Z)
- Al menos **1 letra minúscula** (a-z)
- Al menos **1 número** (0-9)
- Al menos **1 carácter especial** (!@#$%^&*(),.?":{}|<>)

#### 3. **Contraseñas comunes prohibidas**
Se rechazarán contraseñas en esta lista:
- 123456, password, 12345678, qwerty, 123456789
- password1, admin, letmein, monkey, abc123
- superman, princess, welcome, sunshine, master
- Y otras 40+ contraseñas comunes comprometidas

### Indicador de fortaleza
El sistema muestra un indicador visual con 5 niveles:
- 🔴 **Muy débil** (0-29%): No cumple requisitos básicos
- 🟠 **Débil** (30-49%): Cumple algunos requisitos
- 🟡 **Media** (50-69%): Cumple requisitos mínimos
- 🟢 **Fuerte** (70-89%): Buena contraseña
- 🟢 **Muy fuerte** (90-100%): Excelente contraseña

### Ejemplos:
✅ **Válidas**:
- Ejemplo123!
- MiContra$2024
- Segura#Pass99

❌ **Inválidas**:
- password (contraseña común)
- 12345678 (solo números)
- Abcdefgh (falta número y carácter especial)
- abc123! (falta mayúscula)
- ABC123! (falta minúscula)

---

## 👤 Validación de Registro

### Reglas adicionales:

#### 1. **Nombre completo**
- Campo obligatorio
- No puede estar vacío

#### 2. **Confirmación de contraseña**
- Debe coincidir exactamente con la contraseña ingresada
- Campo obligatorio

#### 3. **Email duplicado** (validado por backend)
- El sistema rechaza correos ya registrados
- Mensaje: "Este correo electrónico ya está registrado"

---

## 🚫 Mensajes de Error

### En Login:
- "El correo electrónico es requerido"
- "El formato del correo electrónico no es válido"
- "Correo o contraseña incorrectos" (error 401)
- "Datos de inicio de sesión inválidos" (error 422)

### En Registro:
- "La contraseña debe tener al menos 8 caracteres"
- "La contraseña debe contener al menos una letra mayúscula"
- "La contraseña debe contener al menos una letra minúscula"
- "La contraseña debe contener al menos un número"
- "La contraseña debe contener al menos un carácter especial"
- "Esta contraseña es muy común. Por favor elige una más segura"
- "Las contraseñas no coinciden"
- "Este correo electrónico ya está registrado" (error 409)

---

## 🎨 Interfaz de Usuario

### Indicadores visuales:
1. **Mensajes de error en tiempo real**: Se muestran debajo de cada campo
2. **Barra de fortaleza**: En el campo de contraseña del registro
3. **SnackBar con errores**: Mensajes emergentes con color rojo
4. **Íconos de error**: Se muestran en los mensajes de validación

### Colores de fortaleza:
- Rojo (#D32F2F) - Muy débil
- Naranja (#FF6F00) - Débil
- Amarillo (#FBC02D) - Media
- Verde claro (#7CB342) - Fuerte
- Verde oscuro (#388E3C) - Muy fuerte

---

## 🔧 Implementación Técnica

### Archivos creados:
1. `lib/features/auth/utils/password_validator.dart`
   - Clase `PasswordValidator` con métodos estáticos
   - Lista de contraseñas comunes
   - Cálculo de fortaleza

2. `lib/features/auth/utils/email_validator.dart`
   - Clase `EmailValidator` con validación por regex
   - Normalización de emails

### Integración:
- **LoginForm**: Usa `EmailValidator.validate`
- **RegisterView**: Usa ambos validadores + indicador visual
- **AuthBloc**: Captura errores específicos del backend
- **AuthService**: Maneja códigos de error HTTP (401, 409, 422)

---

## 📝 Notas de Seguridad

1. ✅ Las contraseñas débiles son rechazadas en el frontend
2. ✅ Se valida formato de email antes de enviar al backend
3. ✅ Los mensajes de error son claros y específicos
4. ✅ No se revela información sensible en los mensajes
5. ✅ El backend debe validar nuevamente (defensa en profundidad)

---

## 🧪 Casos de Prueba

### Login:
1. Email vacío → "El correo electrónico es requerido"
2. Email sin @ → "El correo debe contener el símbolo @"
3. Email inválido → "El formato del correo electrónico no es válido"
4. Credenciales incorrectas → Error del backend

### Registro:
1. Contraseña < 8 caracteres → "La contraseña debe tener al menos 8 caracteres"
2. Contraseña sin mayúscula → Error específico
3. Contraseña común (password) → "Esta contraseña es muy común..."
4. Contraseñas no coinciden → "Las contraseñas no coinciden"
5. Email duplicado → "Este correo electrónico ya está registrado"
