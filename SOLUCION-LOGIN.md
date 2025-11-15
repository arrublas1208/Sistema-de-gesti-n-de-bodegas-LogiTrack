# Solución al Problema de Login

## ⚠️ Información Importante

### Error 403 en Register-Admin es NORMAL ✅

El endpoint `/api/auth/register-admin` está **protegido por seguridad** y requiere:
- Estar autenticado como ADMIN
- Enviar un token JWT válido

Por eso da error 403 - es el comportamiento correcto.

### Error "Bad Credentials" en Login ❌

Significa que:
1. El usuario `admin` NO existe en la base de datos, O
2. La contraseña es incorrecta

---

## 🔍 Paso 1: Diagnosticar el Problema

Ejecuta este script para ver qué está pasando:

```bash
./diagnosticar-bd.sh
```

Ingresa tu contraseña de MySQL root cuando lo pida.

**Qué buscar:**
- ¿Existe la base de datos `logitrack_db`? ✅/❌
- ¿Hay tablas? (`usuario`, `empresa`, `producto`, etc.) ✅/❌
- ¿Existe el usuario `admin`? ✅/❌

---

## 🛠️ Paso 2: Solucionar Según el Diagnóstico

### Caso A: Si NO existen las tablas

Las tablas deberían haberse creado automáticamente desde `schema.sql`. Si no existen:

```bash
# Conectar a MySQL
mysql -u root -p

# Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS logitrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE logitrack_db;

# Salir
EXIT;

# Ejecutar el schema manualmente
mysql -u root -p logitrack_db < src/main/resources/schema.sql
mysql -u root -p logitrack_db < src/main/resources/data.sql
```

### Caso B: Si las tablas existen pero NO hay usuario admin

Ejecuta el script que creé:

```bash
./crear-admin-manual.sh
```

Esto creará el usuario admin con:
- **Usuario:** `admin`
- **Contraseña:** `Admin123!`

### Caso C: Si el usuario admin existe pero el login falla

El hash de la contraseña puede estar mal. Recréalo:

```bash
mysql -u root -p logitrack_db << 'EOF'
-- Eliminar el admin actual
DELETE FROM usuario WHERE username = 'admin';

-- Insertar empresa si no existe
INSERT IGNORE INTO empresa (id, nombre) VALUES (1, 'Mi Empresa');

-- Crear admin con la contraseña correcta
INSERT INTO usuario (
  username,
  password,
  rol,
  nombre_completo,
  email,
  cedula,
  empresa_id
) VALUES (
  'admin',
  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
  'ADMIN',
  'Administrador Principal',
  'admin@logitrack.com',
  '1234567890',
  1
);

-- Verificar
SELECT * FROM usuario WHERE username = 'admin';
EOF
```

---

## ✅ Paso 3: Probar el Login

Una vez creado el usuario admin:

### Opción A: Desde el Navegador

1. Ve a: http://localhost:8080/logitrack/
2. Ingresa:
   - Usuario: `admin`
   - Contraseña: `Admin123!`

### Opción B: Desde curl

```bash
curl -X POST http://localhost:8080/logitrack/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "Admin123!"
  }'
```

**Respuesta esperada (ÉXITO):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "type": "Bearer",
  "username": "admin",
  "rol": "ADMIN"
}
```

**Si sale error:**
```json
{
  "error": "Bad credentials"
}
```
Significa que el usuario NO existe o la contraseña es incorrecta.

---

## 🔐 Una Vez que Hagas Login Exitoso

Después de hacer login recibirás un **token JWT**. Con ese token SÍ podrás:

1. **Registrar nuevos admins:**
   ```bash
   curl -X POST http://localhost:8080/logitrack/api/auth/register-admin \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer TU_TOKEN_AQUI" \
     -d '{
       "username": "nuevo_admin",
       "password": "Password123!",
       "nombreCompleto": "Nuevo Admin",
       "email": "nuevo@ejemplo.com",
       "cedula": "9876543210",
       "empresaId": 1
     }'
   ```

2. **Acceder a todos los endpoints protegidos**

---

## 📝 Resumen de Comandos Rápidos

```bash
# 1. Diagnosticar
./diagnosticar-bd.sh

# 2. Crear admin
./crear-admin-manual.sh

# 3. Probar login
curl -X POST http://localhost:8080/logitrack/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin123!"}'
```

---

## ❓ Preguntas Frecuentes

**P: ¿Por qué da 403 en register-admin?**
R: Es correcto. Ese endpoint está protegido y requiere autenticación. Primero debes hacer login.

**P: ¿Cuál es la contraseña del admin?**
R: `Admin123!` (con mayúscula en A y signo de exclamación al final)

**P: ¿Cómo cambio la contraseña del admin?**
R: Una vez que hagas login, usa el endpoint `/api/usuarios/{id}` para cambiarla.

**P: ¿Por qué no se crearon las tablas automáticamente?**
R: Verifica en `application.properties` que esté:
```properties
spring.sql.init.mode=always
spring.sql.init.schema-locations=classpath:schema.sql
```

---

## 🆘 Si Nada Funciona

Crea todo desde cero:

```bash
# 1. Conectar a MySQL
mysql -u root -p

# 2. Borrar y recrear todo
DROP DATABASE IF EXISTS logitrack_db;
CREATE DATABASE logitrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# 3. Recrear estructura
mysql -u root -p logitrack_db < src/main/resources/schema.sql
mysql -u root -p logitrack_db < src/main/resources/data.sql

# 4. Crear admin
./crear-admin-manual.sh

# 5. Probar login
```

---

**Ejecuta el diagnóstico primero y compárteme qué sale!**

```bash
./diagnosticar-bd.sh
```
