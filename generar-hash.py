#!/usr/bin/env python3

import subprocess
import sys

# Verificar si bcrypt está instalado
try:
    import bcrypt
except ImportError:
    print("Instalando bcrypt...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "bcrypt", "--user", "--quiet"])
    import bcrypt

# Generar hash para la contraseña "admin123"
password = "admin123"
password_bytes = password.encode('utf-8')

# Generar hash BCrypt (compatible con Spring Security)
salt = bcrypt.gensalt(rounds=10)
hash_bytes = bcrypt.hashpw(password_bytes, salt)
hash_str = hash_bytes.decode('utf-8')

print("=========================================")
print("HASH BCRYPT GENERADO")
print("=========================================")
print(f"Contraseña: {password}")
print(f"Hash: {hash_str}")
print("")
print("Verificando que el hash es correcto...")
if bcrypt.checkpw(password_bytes, hash_bytes):
    print("✅ Hash verificado correctamente!")
else:
    print("❌ Error en la verificación")
print("")
print("SQL para actualizar:")
print(f"UPDATE usuario SET password = '{hash_str}' WHERE username = 'admin';")
print("")
