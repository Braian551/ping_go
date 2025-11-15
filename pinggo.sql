CREATE DATABASE  IF NOT EXISTS `pingo` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `pingo`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: pingo
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `asignaciones_conductor`
--

DROP TABLE IF EXISTS `asignaciones_conductor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `asignaciones_conductor` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `solicitud_id` bigint unsigned NOT NULL,
  `conductor_id` bigint unsigned NOT NULL,
  `asignado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `llegado_en` timestamp NULL DEFAULT NULL,
  `estado` enum('asignado','llegado','cancelado') DEFAULT 'asignado',
  PRIMARY KEY (`id`),
  KEY `solicitud_id` (`solicitud_id`),
  KEY `conductor_id` (`conductor_id`),
  CONSTRAINT `asignaciones_conductor_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE CASCADE,
  CONSTRAINT `asignaciones_conductor_ibfk_2` FOREIGN KEY (`conductor_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignaciones_conductor`
--

LOCK TABLES `asignaciones_conductor` WRITE;
/*!40000 ALTER TABLE `asignaciones_conductor` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignaciones_conductor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_direcciones`
--

DROP TABLE IF EXISTS `cache_direcciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_direcciones` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `latitud_origen` decimal(10,8) NOT NULL,
  `longitud_origen` decimal(11,8) NOT NULL,
  `latitud_destino` decimal(10,8) NOT NULL,
  `longitud_destino` decimal(11,8) NOT NULL,
  `distancia` decimal(8,2) NOT NULL,
  `duracion` int NOT NULL,
  `polilinea` text NOT NULL,
  `datos_respuesta` json NOT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expira_en` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_cache_dir_ruta` (`latitud_origen`,`longitud_origen`,`latitud_destino`,`longitud_destino`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_direcciones`
--

LOCK TABLES `cache_direcciones` WRITE;
/*!40000 ALTER TABLE `cache_direcciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_direcciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_geocodificacion`
--

DROP TABLE IF EXISTS `cache_geocodificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_geocodificacion` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `direccion_formateada` varchar(500) NOT NULL,
  `id_lugar` varchar(255) DEFAULT NULL,
  `datos_respuesta` json NOT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expira_en` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_cache_geo_coordenadas` (`latitud`,`longitud`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_geocodificacion`
--

LOCK TABLES `cache_geocodificacion` WRITE;
/*!40000 ALTER TABLE `cache_geocodificacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_geocodificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificaciones`
--

DROP TABLE IF EXISTS `calificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `calificaciones` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `solicitud_id` bigint unsigned NOT NULL,
  `usuario_calificador_id` bigint unsigned NOT NULL,
  `usuario_calificado_id` bigint unsigned NOT NULL,
  `calificacion` tinyint NOT NULL,
  `comentarios` text,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `solicitud_id` (`solicitud_id`),
  KEY `usuario_calificador_id` (`usuario_calificador_id`),
  KEY `usuario_calificado_id` (`usuario_calificado_id`),
  CONSTRAINT `calificaciones_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`),
  CONSTRAINT `calificaciones_ibfk_2` FOREIGN KEY (`usuario_calificador_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `calificaciones_ibfk_3` FOREIGN KEY (`usuario_calificado_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `calificaciones_chk_1` CHECK (((`calificacion` >= 1) and (`calificacion` <= 5)))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificaciones`
--

LOCK TABLES `calificaciones` WRITE;
/*!40000 ALTER TABLE `calificaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `calificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalles_paquete`
--

DROP TABLE IF EXISTS `detalles_paquete`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalles_paquete` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `solicitud_id` bigint unsigned NOT NULL,
  `tipo_paquete` enum('documento','pequeno','mediano','grande','fragil','perecedero') NOT NULL,
  `descripcion_paquete` varchar(500) DEFAULT NULL,
  `valor_estimado` decimal(10,2) DEFAULT NULL,
  `peso` decimal(5,2) NOT NULL,
  `largo` decimal(5,2) DEFAULT NULL,
  `ancho` decimal(5,2) DEFAULT NULL,
  `alto` decimal(5,2) DEFAULT NULL,
  `requiere_firma` tinyint(1) DEFAULT '0',
  `seguro_solicitado` tinyint(1) DEFAULT '0',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `solicitud_id` (`solicitud_id`),
  CONSTRAINT `detalles_paquete_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalles_paquete`
--

LOCK TABLES `detalles_paquete` WRITE;
/*!40000 ALTER TABLE `detalles_paquete` DISABLE KEYS */;
/*!40000 ALTER TABLE `detalles_paquete` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalles_viaje`
--

DROP TABLE IF EXISTS `detalles_viaje`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalles_viaje` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `solicitud_id` bigint unsigned NOT NULL,
  `numero_pasajeros` int DEFAULT '1',
  `opciones_viaje` json DEFAULT NULL,
  `tarifa_estimada` decimal(8,2) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `solicitud_id` (`solicitud_id`),
  CONSTRAINT `detalles_viaje_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalles_viaje`
--

LOCK TABLES `detalles_viaje` WRITE;
/*!40000 ALTER TABLE `detalles_viaje` DISABLE KEYS */;
/*!40000 ALTER TABLE `detalles_viaje` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estadisticas_sistema`
--

DROP TABLE IF EXISTS `estadisticas_sistema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estadisticas_sistema` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `total_usuarios` int unsigned DEFAULT '0',
  `total_clientes` int unsigned DEFAULT '0',
  `total_conductores` int unsigned DEFAULT '0',
  `total_administradores` int unsigned DEFAULT '0',
  `usuarios_activos_dia` int unsigned DEFAULT '0',
  `nuevos_registros_dia` int unsigned DEFAULT '0',
  `total_solicitudes` int unsigned DEFAULT '0',
  `solicitudes_completadas` int unsigned DEFAULT '0',
  `solicitudes_canceladas` int unsigned DEFAULT '0',
  `ingresos_totales` decimal(10,2) DEFAULT '0.00',
  `ingresos_dia` decimal(10,2) DEFAULT '0.00',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_fecha` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Estadisticas diarias del sistema';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estadisticas_sistema`
--

LOCK TABLES `estadisticas_sistema` WRITE;
/*!40000 ALTER TABLE `estadisticas_sistema` DISABLE KEYS */;
/*!40000 ALTER TABLE `estadisticas_sistema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historial_seguimiento`
--

DROP TABLE IF EXISTS `historial_seguimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historial_seguimiento` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `solicitud_id` bigint unsigned NOT NULL,
  `conductor_id` bigint unsigned NOT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `precision_gps` decimal(5,2) DEFAULT NULL,
  `velocidad` decimal(5,2) DEFAULT NULL,
  `direccion` smallint DEFAULT NULL,
  `timestamp_seguimiento` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `conductor_id` (`conductor_id`),
  KEY `idx_seguimiento_solicitud` (`solicitud_id`),
  KEY `idx_seguimiento_timestamp` (`timestamp_seguimiento`),
  CONSTRAINT `historial_seguimiento_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE CASCADE,
  CONSTRAINT `historial_seguimiento_ibfk_2` FOREIGN KEY (`conductor_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historial_seguimiento`
--

LOCK TABLES `historial_seguimiento` WRITE;
/*!40000 ALTER TABLE `historial_seguimiento` DISABLE KEYS */;
/*!40000 ALTER TABLE `historial_seguimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs_auditoria`
--

DROP TABLE IF EXISTS `logs_auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs_auditoria` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint unsigned DEFAULT NULL,
  `accion` varchar(100) NOT NULL COMMENT 'Tipo de accion realizada',
  `entidad` varchar(100) DEFAULT NULL COMMENT 'Tabla o entidad afectada',
  `entidad_id` bigint unsigned DEFAULT NULL COMMENT 'ID del registro afectado',
  `descripcion` text COMMENT 'Descripcion detallada de la accion',
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'Direccion IP del usuario',
  `user_agent` varchar(255) DEFAULT NULL COMMENT 'Navegador/dispositivo usado',
  `datos_anteriores` json DEFAULT NULL COMMENT 'Datos antes del cambio',
  `datos_nuevos` json DEFAULT NULL COMMENT 'Datos despues del cambio',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_usuario_id` (`usuario_id`),
  KEY `idx_accion` (`accion`),
  KEY `idx_fecha` (`fecha_creacion`),
  CONSTRAINT `fk_logs_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Registro de todas las acciones importantes del sistema';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs_auditoria`
--

LOCK TABLES `logs_auditoria` WRITE;
/*!40000 ALTER TABLE `logs_auditoria` DISABLE KEYS */;
INSERT INTO `logs_auditoria` VALUES (45,3,'login',NULL,NULL,'Usuario inició sesión exitosamente','127.0.0.1','Dart/3.9 (dart:io)',NULL,NULL,'2025-11-07 02:42:26'),(46,3,'login',NULL,NULL,'Usuario inició sesión exitosamente','127.0.0.1','Dart/3.9 (dart:io)',NULL,NULL,'2025-11-07 03:07:48'),(47,2,'login',NULL,NULL,'Usuario inició sesión exitosamente','127.0.0.1','Dart/3.9 (dart:io)',NULL,NULL,'2025-11-07 03:08:27'),(48,1,'login',NULL,NULL,'Usuario inició sesión exitosamente','127.0.0.1','Dart/3.9 (dart:io)',NULL,NULL,'2025-11-07 03:09:02');
/*!40000 ALTER TABLE `logs_auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metodos_pago_usuario`
--

DROP TABLE IF EXISTS `metodos_pago_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metodos_pago_usuario` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint unsigned NOT NULL,
  `tipo_pago` enum('tarjeta_credito','tarjeta_debito','billetera_digital') NOT NULL,
  `ultimos_cuatro_digitos` varchar(4) DEFAULT NULL,
  `marca_tarjeta` varchar(50) DEFAULT NULL,
  `tipo_billetera` varchar(50) DEFAULT NULL,
  `es_principal` tinyint(1) DEFAULT '0',
  `activo` tinyint(1) DEFAULT '1',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `metodos_pago_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metodos_pago_usuario`
--

LOCK TABLES `metodos_pago_usuario` WRITE;
/*!40000 ALTER TABLE `metodos_pago_usuario` DISABLE KEYS */;
/*!40000 ALTER TABLE `metodos_pago_usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reglas_precios`
--

DROP TABLE IF EXISTS `reglas_precios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reglas_precios` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tipo_servicio` enum('transporte','envio_paquete') NOT NULL,
  `tipo_vehiculo` enum('motocicleta','carro','furgoneta','camion') NOT NULL,
  `tarifa_base` decimal(8,2) NOT NULL,
  `costo_por_km` decimal(8,2) NOT NULL,
  `costo_por_minuto` decimal(8,2) NOT NULL,
  `tarifa_minima` decimal(8,2) NOT NULL,
  `tarifa_cancelacion` decimal(8,2) DEFAULT '0.00',
  `multiplicador_demanda` decimal(3,2) DEFAULT '1.00',
  `activo` tinyint(1) DEFAULT '1',
  `valido_desde` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `valido_hasta` timestamp NULL DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reglas_precios`
--

LOCK TABLES `reglas_precios` WRITE;
/*!40000 ALTER TABLE `reglas_precios` DISABLE KEYS */;
/*!40000 ALTER TABLE `reglas_precios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reportes_usuarios`
--

DROP TABLE IF EXISTS `reportes_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reportes_usuarios` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_reportante_id` bigint unsigned NOT NULL,
  `usuario_reportado_id` bigint unsigned NOT NULL,
  `solicitud_id` bigint unsigned DEFAULT NULL,
  `tipo_reporte` enum('conducta_inapropiada','fraude','seguridad','otro') NOT NULL,
  `descripcion` text NOT NULL,
  `estado` enum('pendiente','en_revision','resuelto','rechazado') DEFAULT 'pendiente',
  `notas_admin` text,
  `admin_revisor_id` bigint unsigned DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_resolucion` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_reportante` (`usuario_reportante_id`),
  KEY `idx_reportado` (`usuario_reportado_id`),
  KEY `idx_estado` (`estado`),
  KEY `fk_reporte_solicitud` (`solicitud_id`),
  KEY `fk_reporte_admin` (`admin_revisor_id`),
  CONSTRAINT `fk_reporte_admin` FOREIGN KEY (`admin_revisor_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_reporte_reportado` FOREIGN KEY (`usuario_reportado_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reporte_reportante` FOREIGN KEY (`usuario_reportante_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reporte_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Reportes de usuarios sobre comportamiento inadecuado';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reportes_usuarios`
--

LOCK TABLES `reportes_usuarios` WRITE;
/*!40000 ALTER TABLE `reportes_usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `reportes_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `solicitudes_servicio`
--

DROP TABLE IF EXISTS `solicitudes_servicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitudes_servicio` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid_solicitud` varchar(255) NOT NULL,
  `cliente_id` bigint unsigned NOT NULL,
  `tipo_servicio` enum('transporte','envio_paquete') NOT NULL,
  `ubicacion_recogida_id` bigint unsigned DEFAULT NULL,
  `ubicacion_destino_id` bigint unsigned DEFAULT NULL,
  `latitud_recogida` decimal(10,8) NOT NULL,
  `longitud_recogida` decimal(11,8) NOT NULL,
  `direccion_recogida` varchar(500) NOT NULL,
  `latitud_destino` decimal(10,8) NOT NULL,
  `longitud_destino` decimal(11,8) NOT NULL,
  `direccion_destino` varchar(500) NOT NULL,
  `distancia_estimada` decimal(8,2) NOT NULL,
  `tiempo_estimado` int NOT NULL,
  `estado` enum('pendiente','aceptada','conductor_asignado','recogido','en_transito','entregado','completada','cancelada') DEFAULT 'pendiente',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `solicitado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `aceptado_en` timestamp NULL DEFAULT NULL,
  `recogido_en` timestamp NULL DEFAULT NULL,
  `entregado_en` timestamp NULL DEFAULT NULL,
  `completado_en` timestamp NULL DEFAULT NULL,
  `cancelado_en` timestamp NULL DEFAULT NULL,
  `motivo_cancelacion` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid_solicitud` (`uuid_solicitud`),
  KEY `ubicacion_recogida_id` (`ubicacion_recogida_id`),
  KEY `ubicacion_destino_id` (`ubicacion_destino_id`),
  KEY `idx_solicitudes_cliente` (`cliente_id`),
  KEY `idx_solicitudes_estado` (`estado`),
  KEY `idx_solicitudes_fecha` (`solicitado_en`),
  CONSTRAINT `solicitudes_servicio_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `solicitudes_servicio_ibfk_2` FOREIGN KEY (`ubicacion_recogida_id`) REFERENCES `ubicaciones_usuario` (`id`),
  CONSTRAINT `solicitudes_servicio_ibfk_3` FOREIGN KEY (`ubicacion_destino_id`) REFERENCES `ubicaciones_usuario` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solicitudes_servicio`
--

LOCK TABLES `solicitudes_servicio` WRITE;
/*!40000 ALTER TABLE `solicitudes_servicio` DISABLE KEYS */;
/*!40000 ALTER TABLE `solicitudes_servicio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transacciones`
--

DROP TABLE IF EXISTS `transacciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transacciones` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `solicitud_id` bigint unsigned NOT NULL,
  `cliente_id` bigint unsigned NOT NULL,
  `conductor_id` bigint unsigned NOT NULL,
  `monto_tarifa` decimal(10,2) NOT NULL,
  `tarifa_distancia` decimal(10,2) NOT NULL,
  `tarifa_tiempo` decimal(10,2) NOT NULL,
  `multiplicador_demanda` decimal(3,2) DEFAULT '1.00',
  `tarifa_servicio` decimal(10,2) NOT NULL,
  `monto_total` decimal(10,2) NOT NULL,
  `metodo_pago` enum('efectivo','tarjeta_credito','tarjeta_debito','billetera_digital') NOT NULL,
  `estado_pago` enum('pendiente','procesando','completado','fallido','reembolsado') DEFAULT 'pendiente',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_transaccion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `completado_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_transacciones_solicitud` (`solicitud_id`),
  KEY `cliente_id` (`cliente_id`),
  KEY `conductor_id` (`conductor_id`),
  KEY `idx_transacciones_estado_pago` (`estado_pago`),
  CONSTRAINT `transacciones_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`),
  CONSTRAINT `transacciones_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `transacciones_ibfk_3` FOREIGN KEY (`conductor_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transacciones`
--

LOCK TABLES `transacciones` WRITE;
/*!40000 ALTER TABLE `transacciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `transacciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ubicaciones_usuario`
--

DROP TABLE IF EXISTS `ubicaciones_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubicaciones_usuario` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint unsigned NOT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `direccion` varchar(500) NOT NULL,
  `ciudad` varchar(100) NOT NULL,
  `departamento` varchar(100) DEFAULT NULL,
  `pais` varchar(100) DEFAULT 'Colombia',
  `codigo_postal` varchar(20) DEFAULT NULL,
  `es_principal` tinyint(1) DEFAULT '0',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `ubicaciones_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubicaciones_usuario`
--

LOCK TABLES `ubicaciones_usuario` WRITE;
/*!40000 ALTER TABLE `ubicaciones_usuario` DISABLE KEYS */;
/*!40000 ALTER TABLE `ubicaciones_usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `hash_contrasena` varchar(255) NOT NULL,
  `tipo_usuario` enum('cliente','conductor','administrador') DEFAULT 'cliente',
  `foto_perfil` varchar(500) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `es_verificado` tinyint(1) DEFAULT '0',
  `es_activo` tinyint(1) DEFAULT '1',
  `fecha_registro` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ultimo_acceso_en` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `telefono` (`telefono`),
  KEY `idx_usuarios_email` (`email`),
  KEY `idx_usuarios_telefono` (`telefono`),
  KEY `idx_usuarios_tipo` (`tipo_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'admin_690d586cbdc8d','Administrador','Sistema','admin@pingo.test','+573001111111','$2y$12$2Y1C5glPu9Zy5.7lmNUqbONJQ3oDEdQpl.A4YBQZeKps83B158BOq','administrador',NULL,NULL,1,1,'2025-11-07 02:24:44',NULL,NULL),(2,'conductor_690d586cbdca7','Conductor','Prueba','conductor@pingo.test','+573002222222','$2y$12$2Y1C5glPu9Zy5.7lmNUqbONJQ3oDEdQpl.A4YBQZeKps83B158BOq','conductor',NULL,NULL,1,1,'2025-11-07 02:24:44',NULL,NULL),(3,'usuario_690d586cbdca8','Usuario','Prueba','usuario@pingo.test','+573003333333','$2y$12$2Y1C5glPu9Zy5.7lmNUqbONJQ3oDEdQpl.A4YBQZeKps83B158BOq','cliente',NULL,NULL,1,1,'2025-11-07 02:24:44',NULL,NULL);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verification_codes`
--

DROP TABLE IF EXISTS `verification_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verification_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `code` varchar(6) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  `used` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verification_codes`
--

LOCK TABLES `verification_codes` WRITE;
/*!40000 ALTER TABLE `verification_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `verification_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'pingo'
--

--
-- Dumping routines for database 'pingo'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-06 22:14:24
