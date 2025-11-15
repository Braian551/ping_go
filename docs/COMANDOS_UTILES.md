# Comandos Útiles - PingGo App

## 🚀 Comandos de Desarrollo Flutter

### Configuración Inicial
```bash
# Verificar instalación de Flutter
flutter doctor

# Verificar versión de Flutter
flutter --version

# Actualizar Flutter
flutter upgrade

# Instalar dependencias del proyecto
flutter pub get

# Actualizar dependencias
flutter pub upgrade
```

### Desarrollo y Testing
```bash
# Ejecutar aplicación en modo debug
flutter run

# Ejecutar en dispositivo específico
flutter run -d <device_id>

# Ejecutar tests unitarios
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ejecutar tests de un archivo específico
flutter test test/unit/auth/login_test.dart

# Ejecutar tests de integración
flutter test integration_test/

# Ejecutar aplicación con perfil de performance
flutter run --profile

# Ejecutar aplicación en modo release
flutter run --release
```

### Build y Compilación
```bash
# Limpiar build cache
flutter clean

# Build APK para Android (debug)
flutter build apk

# Build APK para Android (release)
flutter build apk --release

# Build App Bundle para Android (Google Play)
flutter build appbundle

# Build IPA para iOS
flutter build ios

# Build web
flutter build web

# Build para todas las plataformas
flutter build linux
flutter build windows
flutter build macos
```

### Análisis y Calidad de Código
```bash
# Analizar código estáticamente
flutter analyze

# Formatear código
flutter format .

# Generar archivos (mocks, etc.)
flutter pub run build_runner build

# Observar cambios y regenerar automáticamente
flutter pub run build_runner watch

# Ver dependencias desactualizadas
flutter pub outdated

# Ver dependencias como árbol
flutter pub deps
```

## 📱 Comandos de Dispositivos

### Gestión de Dispositivos
```bash
# Listar dispositivos conectados
flutter devices

# Listar emuladores disponibles
flutter emulators

# Iniciar emulador específico
flutter emulators --launch <emulator_id>

# Ejecutar en Chrome (web)
flutter run -d chrome

# Ejecutar en Edge (web)
flutter run -d edge
```

### Logs y Debugging
```bash
# Ver logs en tiempo real
flutter logs

# Ver logs de dispositivo específico
flutter logs -d <device_id>

# Ver logs de Android
adb logcat

# Limpiar logs de dispositivo
adb logcat -c
```

## 🗄️ Comandos de Base de Datos

### MySQL (Backend)
```bash
# Conectar a MySQL
mysql -h localhost -P 3306 -u root -p

# Crear base de datos
CREATE DATABASE pinggo_db;

# Ver bases de datos
SHOW DATABASES;

# Usar base de datos específica
USE pinggo_db;

# Ver tablas
SHOW TABLES;

# Ver estructura de tabla
DESCRIBE users;

# Backup de base de datos
mysqldump -u root -p pinggo_db > backup.sql

# Restaurar base de datos
mysql -u root -p pinggo_db < backup.sql
```

### SQLite (Local)
```bash
# Abrir base de datos SQLite
sqlite3 pinggo.db

# Ver tablas
.tables

# Ver esquema de tabla
.schema users

# Ejecutar query
SELECT * FROM users;

# Salir
.exit
```

## 🌐 Comandos de Backend

### PHP y Composer
```bash
# Instalar dependencias PHP
composer install

# Actualizar dependencias
composer update

# Ejecutar servidor PHP local
php -S localhost:8000

# Ejecutar tests PHP
./vendor/bin/phpunit

# Verificar sintaxis PHP
php -l index.php
```

### Node.js (si aplica)
```bash
# Instalar dependencias
npm install

# Ejecutar servidor
npm start

# Ejecutar en modo desarrollo
npm run dev

# Ejecutar tests
npm test
```

## 🚀 Comandos de Despliegue

### Railway
```bash
# Login en Railway
railway login

# Conectar proyecto
railway link

# Desplegar
railway up

# Ver logs
railway logs

# Ver variables de entorno
railway variables
```

### Render
```bash
# El despliegue en Render es automático vía Git
# Ver logs en dashboard de Render
```

### Docker (si aplica)
```bash
# Construir imagen
docker build -t pinggo .

# Ejecutar contenedor
docker run -p 3000:3000 pinggo

# Ver contenedores corriendo
docker ps

# Ver logs de contenedor
docker logs <container_id>

# Detener contenedor
docker stop <container_id>
```

## 🛠️ Comandos de Git

### Operaciones Básicas
```bash
# Ver estado del repositorio
git status

# Agregar archivos
git add .

# Agregar archivo específico
git add lib/main.dart

# Crear commit
git commit -m "feat: add user authentication"

# Push a rama principal
git push origin main

# Pull de cambios
git pull origin main
```

### Ramas
```bash
# Ver ramas
git branch -a

# Crear nueva rama
git checkout -b feature/user-profile

# Cambiar a rama existente
git checkout main

# Merge de rama
git merge feature/user-profile

# Eliminar rama local
git branch -d feature/user-profile

# Eliminar rama remota
git push origin --delete feature/user-profile
```

### Historial y Debugging
```bash
# Ver historial de commits
git log --oneline

# Ver cambios en archivo
git diff lib/main.dart

# Ver quien modificó cada línea
git blame lib/main.dart

# Revertir commit
git revert <commit_hash>

# Reset a commit anterior
git reset --hard <commit_hash>
```

## 🔧 Comandos de Sistema

### Windows
```cmd
# Ver variables de entorno
set

# Agregar Flutter al PATH
setx PATH "%PATH%;C:\flutter\bin"

# Ver procesos corriendo
tasklist

# Matar proceso
taskkill /PID <pid> /F

# Ver puertos en uso
netstat -ano | findstr :3000
```

### macOS/Linux
```bash
# Ver variables de entorno
echo $PATH

# Agregar Flutter al PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Ver procesos corriendo
ps aux

# Matar proceso
kill -9 <pid>

# Ver puertos en uso
lsof -i :3000

# Ver espacio en disco
df -h

# Ver uso de memoria
top
```

## 📊 Comandos de Monitoreo

### Performance
```bash
# Ver uso de CPU y memoria
top

# Ver procesos de Flutter
ps aux | grep flutter

# Ver uso de red
iftop

# Ver logs del sistema
tail -f /var/log/syslog
```

### Base de Datos
```bash
# Ver conexiones activas MySQL
mysql -e "SHOW PROCESSLIST;"

# Ver tamaño de base de datos
mysql -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.TABLES GROUP BY table_schema;"

# Ver queries lentas
mysql -e "SHOW VARIABLES LIKE 'slow_query_log%';"
```

## 🧪 Comandos de Testing Avanzado

### Tests con Filtros
```bash
# Ejecutar tests que contengan "login"
flutter test --plain-name "login"

# Ejecutar tests de grupo específico
flutter test --tags "auth"

# Ejecutar tests excluyendo grupo
flutter test --exclude-tags "slow"

# Ejecutar tests en paralelo
flutter test --concurrency=4
```

### Cobertura
```bash
# Generar reporte HTML de cobertura
genhtml coverage/lcov.info -o coverage/html

# Abrir reporte en navegador
open coverage/html/index.html

# Ver líneas no cubiertas
lcov --list coverage/lcov.info | grep -E "(^TN:|^SF:|^DA:)"
```

## 🔄 Comandos de CI/CD

### GitHub Actions
```bash
# Ver status de workflows
gh workflow list

# Ver logs de workflow específico
gh run list
gh run view <run_id>

# Trigger manual de workflow
gh workflow run <workflow_name>
```

### Automatización Local
```bash
# Script de pre-commit (crear .git/hooks/pre-commit)
#!/bin/bash
flutter analyze
flutter test
flutter format --set-exit-if-changed .

# Hacer ejecutable
chmod +x .git/hooks/pre-commit
```

## 📱 Comandos de Dispositivos Móviles

### Android
```bash
# Instalar APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Desinstalar app
adb uninstall com.example.pinggo

# Reiniciar dispositivo
adb reboot

# Capturar screenshot
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png

# Grabar pantalla
adb shell screenrecord /sdcard/demo.mp4
adb pull /sdcard/demo.mp4
```

### iOS
```bash
# Listar dispositivos conectados
xcrun xctrace list devices

# Instalar app en dispositivo
xcrun xctrace install --device <device_id> build/ios/iphoneos/Runner.app

# Ver logs de dispositivo
idevicesyslog

# Capturar screenshot
xcrun simctl io booted screenshot screenshot.png
```

## 🌐 Comandos de Red

### Debugging de APIs
```bash
# Test de conectividad
ping api.pinggo.com

# Ver headers de respuesta
curl -I https://api.pinggo.com/health

# Ver respuesta completa
curl -X GET https://api.pinggo.com/users

# Test con autenticación
curl -X GET https://api.pinggo.com/profile \
  -H "Authorization: Bearer <token>"

# Verificar certificado SSL
openssl s_client -connect api.pinggo.com:443
```

### Proxy y VPN
```bash
# Configurar proxy HTTP
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# Verificar configuración de proxy
env | grep -i proxy
```

## 💾 Comandos de Backup y Recovery

### Proyecto Completo
```bash
# Backup de código
git bundle create backup.bundle --all

# Backup de base de datos
mysqldump -u root -p pinggo_db > backup_$(date +%Y%m%d).sql

# Backup de archivos subidos
tar -czf uploads_backup.tar.gz backend-deploy/uploads/

# Backup completo
tar -czf full_backup.tar.gz . --exclude=node_modules --exclude=.git
```

### Recovery
```bash
# Restaurar bundle de Git
git clone backup.bundle recovery

# Restaurar base de datos
mysql -u root -p pinggo_db < backup.sql

# Restaurar archivos
tar -xzf uploads_backup.tar.gz
```

## 🎯 Comandos Específicos de PingGo

### Configuración de Entornos
```bash
# Configurar entorno local
cp .env.example .env.local
# Editar .env.local con valores locales

# Configurar entorno de desarrollo
cp .env.example .env.development

# Configurar entorno de producción
cp .env.example .env.production
```

### Base de Datos de PingGo
```bash
# Crear estructura inicial
mysql -u root -p < backend-deploy/database/schema.sql

# Ejecutar migraciones
php backend-deploy/database/migrate.php

# Poblar datos de prueba
mysql -u root -p pinggo_db < backend-deploy/database/seeds.sql
```

### Testing de PingGo
```bash
# Test completo de autenticación
flutter test test/features/auth/

# Test de integración de mapas
flutter test test/features/map/

# Test de UI de registro
flutter test test/widget/auth/register/

# Test de performance
flutter test --profile test/performance/
```

---

*Referencia rápida para desarrolladores de PingGo. Mantén este documento actualizado con nuevos comandos útiles.*

*Última actualización: $(date '+%Y-%m-%d')*