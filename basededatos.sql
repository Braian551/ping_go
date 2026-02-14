-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 08, 2026 at 07:56 PM
-- Server version: 8.0.30
-- PHP Version: 8.3.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pingo`
--

-- --------------------------------------------------------

--
-- Table structure for table `asignaciones_conductor`
--

CREATE TABLE `asignaciones_conductor` (
  `id` bigint UNSIGNED NOT NULL,
  `solicitud_id` bigint UNSIGNED NOT NULL,
  `conductor_id` bigint UNSIGNED NOT NULL,
  `asignado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `llegado_en` timestamp NULL DEFAULT NULL,
  `estado` enum('pendiente','asignado','rechazado','expirado','completado','cancelado') DEFAULT 'pendiente',
  `fecha_asignacion` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `asignaciones_conductor`
--

INSERT INTO `asignaciones_conductor` (`id`, `solicitud_id`, `conductor_id`, `asignado_en`, `llegado_en`, `estado`, `fecha_asignacion`) VALUES
(1, 1, 2, '2026-02-03 17:26:26', NULL, 'completado', '2026-02-03 12:26:21'),
(2, 2, 2, '2026-02-03 18:35:18', NULL, 'cancelado', '2026-02-03 13:34:26'),
(3, 4, 2, '2026-02-04 20:48:54', NULL, 'completado', '2026-02-04 15:48:45'),
(4, 5, 2, '2026-02-08 00:36:17', NULL, 'completado', '2026-02-07 19:36:13'),
(5, 6, 2, '2026-02-08 01:36:06', NULL, 'cancelado', '2026-02-07 20:32:12'),
(6, 7, 2, '2026-02-08 01:42:14', NULL, 'cancelado', '2026-02-07 20:42:04'),
(7, 8, 2, '2026-02-08 01:50:29', NULL, 'cancelado', '2026-02-07 20:50:17'),
(8, 9, 2, '2026-02-08 02:11:36', NULL, 'completado', '2026-02-07 21:11:24'),
(9, 10, 2, '2026-02-08 02:28:17', NULL, 'cancelado', '2026-02-07 21:26:41'),
(10, 11, 2, '2026-02-08 02:32:33', NULL, 'completado', '2026-02-07 21:31:48'),
(11, 12, 2, '2026-02-08 02:46:05', NULL, 'completado', '2026-02-07 21:45:42'),
(12, 13, 2, '2026-02-08 03:08:50', NULL, 'completado', '2026-02-07 22:08:40'),
(13, 14, 2, '2026-02-08 03:21:42', NULL, 'completado', '2026-02-07 22:21:31'),
(14, 15, 2, '2026-02-08 03:31:15', NULL, 'completado', '2026-02-07 22:30:47'),
(15, 16, 2, '2026-02-08 16:38:46', NULL, 'completado', '2026-02-08 11:38:37'),
(16, 17, 2, '2026-02-08 16:39:09', NULL, 'cancelado', '2026-02-08 11:39:04'),
(17, 18, 2, '2026-02-08 18:36:25', NULL, 'completado', '2026-02-08 13:36:12'),
(18, 19, 2, '2026-02-08 18:42:30', NULL, 'cancelado', '2026-02-08 13:42:22'),
(19, 20, 2, '2026-02-08 19:06:40', NULL, 'completado', '2026-02-08 14:06:35'),
(20, 21, 2, '2026-02-08 19:40:35', NULL, 'completado', '2026-02-08 14:40:26');

-- --------------------------------------------------------

--
-- Table structure for table `cache_direcciones`
--

CREATE TABLE `cache_direcciones` (
  `id` bigint UNSIGNED NOT NULL,
  `latitud_origen` decimal(10,8) NOT NULL,
  `longitud_origen` decimal(11,8) NOT NULL,
  `latitud_destino` decimal(10,8) NOT NULL,
  `longitud_destino` decimal(11,8) NOT NULL,
  `distancia` decimal(8,2) NOT NULL,
  `duracion` int NOT NULL,
  `polilinea` text NOT NULL,
  `datos_respuesta` json NOT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expira_en` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_geocodificacion`
--

CREATE TABLE `cache_geocodificacion` (
  `id` bigint UNSIGNED NOT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `direccion_formateada` varchar(500) NOT NULL,
  `id_lugar` varchar(255) DEFAULT NULL,
  `datos_respuesta` json NOT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expira_en` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `calificaciones`
--

CREATE TABLE `calificaciones` (
  `id` bigint UNSIGNED NOT NULL,
  `solicitud_id` bigint UNSIGNED NOT NULL,
  `usuario_calificador_id` bigint UNSIGNED NOT NULL,
  `usuario_calificado_id` bigint UNSIGNED NOT NULL,
  `calificacion` tinyint NOT NULL,
  `tipo_calificacion` enum('estrellas','bandera') DEFAULT 'estrellas',
  `motivo_bandera` text,
  `revisado_admin` tinyint(1) DEFAULT '0',
  `revisado_en` timestamp NULL DEFAULT NULL,
  `comentario` text,
  `comentarios` text,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ;

--
-- Dumping data for table `calificaciones`
--

INSERT INTO `calificaciones` (`id`, `solicitud_id`, `usuario_calificador_id`, `usuario_calificado_id`, `calificacion`, `tipo_calificacion`, `motivo_bandera`, `revisado_admin`, `revisado_en`, `comentario`, `comentarios`, `creado_en`) VALUES
(1, 1, 3, 2, 4, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-03 17:26:57'),
(2, 4, 3, 2, 5, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-04 20:51:10'),
(3, 5, 2, 3, 5, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-08 00:37:04'),
(4, 5, 3, 2, 2, 'bandera', 'malo', 1, '2026-02-08 01:00:21', '', NULL, '2026-02-08 00:37:10'),
(5, 14, 2, 3, 4, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-08 03:22:05'),
(6, 14, 3, 2, 4, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-08 03:22:11'),
(7, 18, 4, 2, 5, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-08 18:40:22'),
(8, 18, 2, 4, 5, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-08 18:40:37'),
(9, 21, 4, 2, 5, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-08 19:42:40'),
(10, 21, 2, 4, 5, 'estrellas', NULL, 0, NULL, '', NULL, '2026-02-08 19:42:44');

-- --------------------------------------------------------

--
-- Table structure for table `detalles_conductor`
--

CREATE TABLE `detalles_conductor` (
  `id` bigint UNSIGNED NOT NULL,
  `usuario_id` bigint UNSIGNED NOT NULL,
  `numero_licencia` varchar(50) NOT NULL,
  `vencimiento_licencia` date NOT NULL,
  `tipo_vehiculo` enum('motocicleta','carro') NOT NULL,
  `marca_vehiculo` varchar(50) DEFAULT NULL,
  `modelo_vehiculo` varchar(50) DEFAULT NULL,
  `ano_vehiculo` int DEFAULT NULL,
  `color_vehiculo` varchar(30) DEFAULT NULL,
  `placa_vehiculo` varchar(20) NOT NULL,
  `aseguradora` varchar(100) DEFAULT NULL,
  `numero_poliza_seguro` varchar(100) DEFAULT NULL,
  `vencimiento_seguro` date DEFAULT NULL,
  `foto_licencia_reverso` varchar(500) DEFAULT NULL,
  `foto_licencia_frente` varchar(500) DEFAULT NULL,
  `aprobado` tinyint(1) DEFAULT '0',
  `estado_aprobacion` enum('pendiente','aprobado','rechazado') DEFAULT 'pendiente',
  `disponible` tinyint(1) DEFAULT '1',
  `motivo_rechazo` varchar(500) DEFAULT NULL,
  `calificacion_promedio` decimal(3,2) DEFAULT '0.00',
  `total_calificaciones` int DEFAULT '0',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `latitud_actual` decimal(10,8) DEFAULT NULL,
  `longitud_actual` decimal(11,8) DEFAULT NULL,
  `ultima_actualizacion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `detalles_conductor`
--

INSERT INTO `detalles_conductor` (`id`, `usuario_id`, `numero_licencia`, `vencimiento_licencia`, `tipo_vehiculo`, `marca_vehiculo`, `modelo_vehiculo`, `ano_vehiculo`, `color_vehiculo`, `placa_vehiculo`, `aseguradora`, `numero_poliza_seguro`, `vencimiento_seguro`, `foto_licencia_reverso`, `foto_licencia_frente`, `aprobado`, `estado_aprobacion`, `disponible`, `motivo_rechazo`, `calificacion_promedio`, `total_calificaciones`, `creado_en`, `actualizado_en`, `latitud_actual`, `longitud_actual`, `ultima_actualizacion`) VALUES
(1, 2, '43535353', '2027-02-28', 'motocicleta', 'susuki', 'gsxr', 2025, 'Negro', 'gs232', '32323', '4242442', '2027-02-28', 'uploads/conductores/2/licencia_reverso_1770135788.jpg', 'uploads/conductores/2/licencia_frente_1770135787.jpg', 1, 'aprobado', 1, NULL, '4.60', 5, '2026-02-03 16:23:07', '2026-02-08 19:42:49', '6.25278830', '-75.53851830', '2026-02-08 14:42:49');

-- --------------------------------------------------------

--
-- Table structure for table `detalles_paquete`
--

CREATE TABLE `detalles_paquete` (
  `id` bigint UNSIGNED NOT NULL,
  `solicitud_id` bigint UNSIGNED NOT NULL,
  `tipo_paquete` enum('documento','pequeno','mediano','grande','fragil','perecedero') NOT NULL,
  `descripcion_paquete` varchar(500) DEFAULT NULL,
  `valor_estimado` decimal(10,2) DEFAULT NULL,
  `peso` decimal(5,2) NOT NULL,
  `largo` decimal(5,2) DEFAULT NULL,
  `ancho` decimal(5,2) DEFAULT NULL,
  `alto` decimal(5,2) DEFAULT NULL,
  `requiere_firma` tinyint(1) DEFAULT '0',
  `seguro_solicitado` tinyint(1) DEFAULT '0',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `detalles_viaje`
--

CREATE TABLE `detalles_viaje` (
  `id` bigint UNSIGNED NOT NULL,
  `solicitud_id` bigint UNSIGNED NOT NULL,
  `numero_pasajeros` int DEFAULT '1',
  `opciones_viaje` json DEFAULT NULL,
  `tarifa_estimada` decimal(8,2) DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `historial_seguimiento`
--

CREATE TABLE `historial_seguimiento` (
  `id` bigint UNSIGNED NOT NULL,
  `solicitud_id` bigint UNSIGNED NOT NULL,
  `conductor_id` bigint UNSIGNED NOT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `precision_gps` decimal(5,2) DEFAULT NULL,
  `velocidad` decimal(5,2) DEFAULT NULL,
  `direccion` smallint DEFAULT NULL,
  `timestamp_seguimiento` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `logs_auditoria`
--

CREATE TABLE `logs_auditoria` (
  `id` bigint UNSIGNED NOT NULL,
  `usuario_id` bigint UNSIGNED DEFAULT NULL,
  `accion` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entidad` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entidad_id` bigint UNSIGNED DEFAULT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `logs_auditoria`
--

INSERT INTO `logs_auditoria` (`id`, `usuario_id`, `accion`, `entidad`, `entidad_id`, `descripcion`, `ip_address`, `user_agent`, `fecha_creacion`) VALUES
(1, 1, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 15:49:44'),
(2, 1, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 16:24:39'),
(3, 1, 'aprobacion_conductor', 'detalles_conductor', 1, 'Aprobó al conductor: Braian (braianoquendurango@gmail.com)', '127.0.0.1', NULL, '2026-02-03 16:24:58'),
(4, 2, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 16:39:39'),
(5, 2, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 17:25:11'),
(6, 1, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 17:29:51'),
(7, 2, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 17:30:32'),
(8, 2, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 18:17:02'),
(9, 3, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 18:30:05'),
(10, 2, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 18:35:07'),
(11, 1, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-04 20:55:16'),
(12, 2, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 00:25:28'),
(13, 1, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 00:42:55'),
(14, 3, 'login', NULL, NULL, 'Usuario inició sesión exitosamente', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 01:13:32'),
(15, 2, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:11:17'),
(16, 2, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:11:33'),
(17, 2, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:16:27'),
(18, 2, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:16:46'),
(19, 1, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:25:11'),
(20, 1, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:27:19'),
(21, 1, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:27:31'),
(22, 1, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:29:54'),
(23, 4, 'registro_google', NULL, NULL, 'Usuario se registró con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:30:08'),
(24, 4, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:30:20'),
(25, 4, 'login_google', NULL, NULL, 'Usuario inició sesión con Google', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-08 18:34:34');

-- --------------------------------------------------------

--
-- Table structure for table `metodos_pago_usuario`
--

CREATE TABLE `metodos_pago_usuario` (
  `id` bigint UNSIGNED NOT NULL,
  `usuario_id` bigint UNSIGNED NOT NULL,
  `tipo_pago` enum('tarjeta_credito','tarjeta_debito','billetera_digital') NOT NULL,
  `ultimos_cuatro_digitos` varchar(4) DEFAULT NULL,
  `marca_tarjeta` varchar(50) DEFAULT NULL,
  `tipo_billetera` varchar(50) DEFAULT NULL,
  `es_principal` tinyint(1) DEFAULT '0',
  `activo` tinyint(1) DEFAULT '1',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proveedores_mapa`
--

CREATE TABLE `proveedores_mapa` (
  `id` bigint UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `api_key` varchar(255) NOT NULL,
  `activo` tinyint(1) DEFAULT '1',
  `contador_solicitudes` int DEFAULT '0',
  `ultimo_uso` timestamp NULL DEFAULT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reglas_precios`
--

CREATE TABLE `reglas_precios` (
  `id` bigint UNSIGNED NOT NULL,
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
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `solicitudes_servicio`
--

CREATE TABLE `solicitudes_servicio` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid_solicitud` varchar(255) NOT NULL,
  `cliente_id` bigint UNSIGNED NOT NULL,
  `tipo_servicio` enum('transporte','envio_paquete') NOT NULL,
  `ubicacion_recogida_id` bigint UNSIGNED DEFAULT NULL,
  `ubicacion_destino_id` bigint UNSIGNED DEFAULT NULL,
  `latitud_recogida` decimal(10,8) NOT NULL,
  `longitud_recogida` decimal(11,8) NOT NULL,
  `direccion_recogida` varchar(500) NOT NULL,
  `latitud_destino` decimal(10,8) NOT NULL,
  `longitud_destino` decimal(11,8) NOT NULL,
  `direccion_destino` varchar(500) NOT NULL,
  `distancia_estimada` decimal(8,2) NOT NULL,
  `tiempo_estimado` int NOT NULL,
  `estado` enum('pendiente','aceptada','conductor_asignado','en_sitio','recogido','en_transito','entregado','completada','cancelada') DEFAULT 'pendiente',
  `solicitado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `aceptado_en` timestamp NULL DEFAULT NULL,
  `recogido_en` timestamp NULL DEFAULT NULL,
  `entregado_en` timestamp NULL DEFAULT NULL,
  `completado_en` timestamp NULL DEFAULT NULL,
  `cancelado_en` timestamp NULL DEFAULT NULL,
  `motivo_cancelacion` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `solicitudes_servicio`
--

INSERT INTO `solicitudes_servicio` (`id`, `uuid_solicitud`, `cliente_id`, `tipo_servicio`, `ubicacion_recogida_id`, `ubicacion_destino_id`, `latitud_recogida`, `longitud_recogida`, `direccion_recogida`, `latitud_destino`, `longitud_destino`, `direccion_destino`, `distancia_estimada`, `tiempo_estimado`, `estado`, `solicitado_en`, `aceptado_en`, `recogido_en`, `entregado_en`, `completado_en`, `cancelado_en`, `motivo_cancelacion`) VALUES
(1, 'd74613a5-5a7e-4849-a423-83175df383d0', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'completada', '2026-02-03 17:26:21', NULL, '2026-02-03 17:26:40', NULL, '2026-02-03 17:26:48', NULL, NULL),
(2, 'd0670745-1a37-4440-ba58-c0901508564a', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-03 18:34:26', NULL, NULL, NULL, NULL, '2026-02-03 19:03:22', 'Cancelado por el cliente'),
(3, 'a7b51bd0-446d-42e5-94ca-432e1d3eb787', 3, 'transporte', NULL, NULL, '6.15866137', '-75.64432780', 'Carrera 62, La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '6.33499700', '-75.55826650', 'Bello, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 051053, Colombia', '28.20', 44, 'cancelada', '2026-02-04 20:47:45', NULL, NULL, NULL, NULL, '2026-02-04 20:48:22', 'Cancelado por el cliente'),
(4, '1f86c001-8bd7-4559-aac6-8b56be951394', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'completada', '2026-02-04 20:48:45', NULL, '2026-02-04 20:49:23', NULL, '2026-02-04 20:50:55', NULL, NULL),
(5, '6ed5d0cb-6425-4ed5-9bad-4e235456e04d', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'completada', '2026-02-08 00:36:12', NULL, '2026-02-08 00:36:31', NULL, '2026-02-08 00:36:35', NULL, NULL),
(6, '40c41acf-aa79-49e4-847b-cc00d55da30f', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 01:32:12', NULL, NULL, NULL, NULL, '2026-02-08 01:36:51', 'Cancelado por el cliente'),
(7, 'a53f43ab-2b76-4af7-84be-88b3a6eeab1a', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 01:42:04', NULL, NULL, NULL, NULL, '2026-02-08 01:50:10', 'Cancelado por el cliente'),
(8, '7daac1c3-b659-4276-9c56-f4340329a1c7', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 01:50:17', NULL, NULL, NULL, NULL, '2026-02-08 02:00:59', 'Cancelado por el cliente'),
(9, '90b64dec-7f21-4497-b5e4-f36c76f69381', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 34, 'cancelada', '2026-02-08 02:11:24', NULL, NULL, NULL, NULL, NULL, NULL),
(10, '3ec62c82-8d29-4c4e-a122-312ce8e6020d', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 02:26:41', NULL, NULL, NULL, NULL, '2026-02-08 02:29:35', 'Cancelado por el cliente'),
(11, 'f48879d9-38e7-40ec-bca9-676036011f88', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 02:31:48', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 'e1290122-b0ad-4ff4-917b-4026a7cb7b6e', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'completada', '2026-02-08 02:45:42', NULL, '2026-02-08 03:04:43', NULL, '2026-02-08 03:04:45', NULL, NULL),
(13, '168d659a-e2a8-4c0b-8ca8-b1fa31a313ca', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 03:08:39', NULL, NULL, NULL, NULL, NULL, NULL),
(14, '493d0168-2fc3-4f76-bb6c-88e2620d542d', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'completada', '2026-02-08 03:21:31', NULL, '2026-02-08 03:21:56', NULL, '2026-02-08 03:22:00', NULL, NULL),
(15, '44cb0ad0-234c-4577-b6cb-f00b7a5c2158', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 03:30:47', NULL, NULL, NULL, NULL, NULL, NULL),
(16, '6a6684e9-4b90-4b24-b42d-9a0250379a7f', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 16:38:37', NULL, NULL, NULL, NULL, NULL, NULL),
(17, '6528ca7b-e19b-4556-aef0-a5778640da3e', 3, 'transporte', NULL, NULL, '6.25278830', '-75.53851830', 'Terminal el faro, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '21.04', 35, 'cancelada', '2026-02-08 16:39:04', NULL, NULL, NULL, NULL, '2026-02-08 16:39:18', 'Cancelado por el cliente'),
(18, '1718a4cf-6bf8-4b53-9ef9-3ae459725bd0', 4, 'transporte', NULL, NULL, '6.25461830', '-75.53955670', '62 - 191, Carrera 18B, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '20.82', 34, 'completada', '2026-02-08 18:36:12', NULL, '2026-02-08 18:36:43', NULL, '2026-02-08 18:36:46', NULL, NULL),
(19, 'f206da88-817f-4d2c-9223-e25018812a99', 4, 'transporte', NULL, NULL, '6.25461830', '-75.53955670', '62 - 191, Carrera 18B, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '20.82', 34, 'cancelada', '2026-02-08 18:42:22', NULL, NULL, NULL, NULL, '2026-02-08 18:49:16', 'Cancelado por el cliente'),
(20, '575b5572-7d50-45e2-9165-aee65619f383', 4, 'transporte', NULL, NULL, '6.25461830', '-75.53955670', '62 - 191, Carrera 18B, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '20.82', 34, 'completada', '2026-02-08 19:06:35', NULL, '2026-02-08 19:14:42', NULL, '2026-02-08 19:21:48', NULL, NULL),
(21, '992c3041-cfbc-4828-a764-856ee0b72ecf', 4, 'transporte', NULL, NULL, '6.25461830', '-75.53955670', '62 - 191, Carrera 18B, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Medellín, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 050011, Colombia', '6.15767810', '-75.64338780', 'La Estrella, Valle de Aburrá, Antioquia, RAP del Agua y la Montaña, 055460, Colombia', '20.82', 34, 'completada', '2026-02-08 19:40:26', NULL, '2026-02-08 19:40:52', NULL, '2026-02-08 19:41:37', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tarifas`
--

CREATE TABLE `tarifas` (
  `id` int NOT NULL,
  `tipo_vehiculo` varchar(50) NOT NULL,
  `tarifa_base` decimal(10,2) DEFAULT '0.00',
  `tarifa_km` decimal(10,2) DEFAULT '0.00',
  `tarifa_min` decimal(10,2) DEFAULT '0.00',
  `comision` decimal(5,2) DEFAULT '0.00',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `tarifas`
--

INSERT INTO `tarifas` (`id`, `tipo_vehiculo`, `tarifa_base`, `tarifa_km`, `tarifa_min`, `comision`, `creado_en`, `actualizado_en`) VALUES
(1, 'motocicleta', '2500.00', '800.00', '100.00', '15.00', '2026-02-03 15:49:50', '2026-02-03 15:49:50'),
(2, 'carro', '3500.00', '1200.00', '200.00', '20.00', '2026-02-03 15:49:50', '2026-02-03 15:49:50');

-- --------------------------------------------------------

--
-- Table structure for table `transacciones`
--

CREATE TABLE `transacciones` (
  `id` bigint UNSIGNED NOT NULL,
  `solicitud_id` bigint UNSIGNED NOT NULL,
  `cliente_id` bigint UNSIGNED NOT NULL,
  `conductor_id` bigint UNSIGNED NOT NULL,
  `monto_tarifa` decimal(10,2) NOT NULL,
  `tarifa_distancia` decimal(10,2) NOT NULL,
  `tarifa_tiempo` decimal(10,2) NOT NULL,
  `multiplicador_demanda` decimal(3,2) DEFAULT '1.00',
  `tarifa_servicio` decimal(10,2) NOT NULL,
  `monto_total` decimal(10,2) NOT NULL,
  `comision` decimal(10,2) DEFAULT '0.00',
  `metodo_pago` enum('efectivo','tarjeta_credito','tarjeta_debito','billetera_digital') NOT NULL,
  `estado_pago` enum('pendiente','procesando','completado','fallido','reembolsado') DEFAULT 'pendiente',
  `estado_comision` enum('pendiente','pagado') DEFAULT 'pendiente',
  `fecha_pago_comision` datetime DEFAULT NULL,
  `fecha_transaccion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `completado_en` timestamp NULL DEFAULT NULL,
  `duracion_real` int DEFAULT '0' COMMENT 'Duración real del viaje en segundos',
  `distancia_real` decimal(10,2) DEFAULT '0.00' COMMENT 'Distancia real del viaje en km'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `transacciones`
--

INSERT INTO `transacciones` (`id`, `solicitud_id`, `cliente_id`, `conductor_id`, `monto_tarifa`, `tarifa_distancia`, `tarifa_tiempo`, `multiplicador_demanda`, `tarifa_servicio`, `monto_total`, `comision`, `metodo_pago`, `estado_pago`, `estado_comision`, `fecha_pago_comision`, `fecha_transaccion`, `completado_en`, `duracion_real`, `distancia_real`) VALUES
(1, 1, 3, 2, '2500.00', '0.00', '13.33', '1.00', '400.00', '2500.00', '400.00', 'efectivo', 'pendiente', 'pagado', '2026-02-03 12:31:39', '2026-02-03 17:26:48', NULL, 8, '0.00'),
(2, 4, 3, 2, '2500.00', '0.00', '153.33', '1.00', '400.00', '2700.00', '400.00', 'efectivo', 'pendiente', 'pendiente', NULL, '2026-02-04 20:50:55', NULL, 92, '0.00'),
(3, 5, 3, 2, '2500.00', '0.00', '5.00', '1.00', '400.00', '2500.00', '400.00', 'efectivo', 'pendiente', 'pendiente', NULL, '2026-02-08 00:36:35', NULL, 3, '0.00'),
(4, 12, 3, 2, '2500.00', '0.00', '1.67', '1.00', '400.00', '2500.00', '400.00', 'efectivo', 'pendiente', 'pendiente', NULL, '2026-02-08 03:04:45', NULL, 1, '0.00'),
(5, 14, 3, 2, '2500.00', '0.00', '5.00', '1.00', '400.00', '2500.00', '400.00', 'efectivo', 'pendiente', 'pendiente', NULL, '2026-02-08 03:22:00', NULL, 3, '0.00'),
(6, 18, 4, 2, '2500.00', '0.00', '3.33', '1.00', '400.00', '2500.00', '400.00', 'efectivo', 'pendiente', 'pendiente', NULL, '2026-02-08 18:36:46', NULL, 2, '0.00'),
(7, 20, 4, 2, '2500.00', '0.00', '30720.00', '1.00', '5000.00', '33200.00', '5000.00', 'efectivo', 'pendiente', 'pendiente', NULL, '2026-02-08 19:21:48', NULL, 18432, '0.00'),
(8, 21, 4, 2, '2500.00', '0.00', '75.00', '1.00', '400.00', '2600.00', '400.00', 'efectivo', 'pendiente', 'pendiente', NULL, '2026-02-08 19:41:37', NULL, 45, '0.00');

-- --------------------------------------------------------

--
-- Table structure for table `ubicaciones_usuario`
--

CREATE TABLE `ubicaciones_usuario` (
  `id` bigint UNSIGNED NOT NULL,
  `usuario_id` bigint UNSIGNED NOT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `direccion` varchar(500) NOT NULL,
  `ciudad` varchar(100) NOT NULL,
  `departamento` varchar(100) DEFAULT NULL,
  `pais` varchar(100) DEFAULT 'Colombia',
  `codigo_postal` varchar(20) DEFAULT NULL,
  `es_principal` tinyint(1) DEFAULT '0',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `google_id` varchar(255) DEFAULT NULL,
  `telefono` varchar(20) NOT NULL,
  `hash_contrasena` varchar(255) NOT NULL,
  `tipo_usuario` enum('cliente','conductor','administrador') DEFAULT 'cliente',
  `url_imagen_perfil` varchar(500) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `verificado` tinyint(1) DEFAULT '0',
  `activo` tinyint(1) DEFAULT '1',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ultimo_acceso_en` timestamp NULL DEFAULT NULL,
  `calificacion_promedio` decimal(3,2) DEFAULT '0.00',
  `total_calificaciones` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id`, `uuid`, `nombre`, `apellido`, `email`, `google_id`, `telefono`, `hash_contrasena`, `tipo_usuario`, `url_imagen_perfil`, `fecha_nacimiento`, `verificado`, `activo`, `creado_en`, `actualizado_en`, `ultimo_acceso_en`, `calificacion_promedio`, `total_calificaciones`) VALUES
(1, 'user_6981750c8a3397.01726705', 'braianoquen', 'oquendo', 'braianoquen@gmail.com', 'gLJXqL2zDmfKPEXLOZ63lzAoafq2', '43423432', '$2y$10$KQB2bh5mw8Q2gar5J1buHu238f3H6rc3XS30.wZEbJje0UK2a6TYm', 'administrador', NULL, NULL, 0, 1, '2026-02-03 04:09:48', '2026-02-08 18:25:11', NULL, '0.00', 0),
(2, 'user_698220a949cca7.85716943', 'Braian', 'Oquendo', 'braianoquendurango@gmail.com', 'l47F2ngUXbg3rG78u3oGUljR1Fx1', '2434243432', '$2y$10$s3Hyqm5JNXDE9HOwvKgu8OkXw/pDnA2HIlaUZ9vTnE8jshNW.I5ai', 'conductor', 'uploads/usuarios/2/profile_1770139707.jpg', NULL, 0, 1, '2026-02-03 16:22:01', '2026-02-08 18:11:17', NULL, '0.00', 0),
(3, 'user_698224a0a69d47.06680005', 'Luis', 'Dominguez', 'braianoquen2@gmail.com', NULL, '23424225', '$2y$10$JIWUqmk8L7PsI2a02b23b.9Q8tUisBSf98GyxmmEV3TZUgmpH1Nn.', 'cliente', NULL, NULL, 0, 1, '2026-02-03 16:38:56', '2026-02-08 03:22:05', NULL, '4.50', 2),
(4, 'user_6988d6301a8fd4.81092756', 'Braian', 'Andrés Oquendo Durango', 'secretoestoico8052@gmail.com', 'sRdlAO4WIQfTkuaqejOvdBRmSeY2', '0000000000', '$2y$10$7kUWIvCWXL6.sGWodY7Bz.P62XTGxsXm/o/FvQfgsXlP8HL0S915e', 'cliente', 'https://lh3.googleusercontent.com/a/ACg8ocKrSsyN6lq-gOoqsHTzRMsi5aFdjM4yd1az8I9CZwF4ztJNnQ=s96-c', NULL, 1, 1, '2026-02-08 18:30:08', '2026-02-08 19:42:44', NULL, '5.00', 2);

-- --------------------------------------------------------

--
-- Table structure for table `verification_codes`
--

CREATE TABLE `verification_codes` (
  `id` int NOT NULL,
  `email` varchar(255) NOT NULL,
  `code` varchar(6) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  `used` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `asignaciones_conductor`
--
ALTER TABLE `asignaciones_conductor`
  ADD PRIMARY KEY (`id`),
  ADD KEY `solicitud_id` (`solicitud_id`),
  ADD KEY `conductor_id` (`conductor_id`);

--
-- Indexes for table `cache_direcciones`
--
ALTER TABLE `cache_direcciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cache_dir_ruta` (`latitud_origen`,`longitud_origen`,`latitud_destino`,`longitud_destino`);

--
-- Indexes for table `cache_geocodificacion`
--
ALTER TABLE `cache_geocodificacion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cache_geo_coordenadas` (`latitud`,`longitud`);

--
-- Indexes for table `calificaciones`
--
ALTER TABLE `calificaciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `solicitud_id` (`solicitud_id`),
  ADD KEY `usuario_calificador_id` (`usuario_calificador_id`),
  ADD KEY `usuario_calificado_id` (`usuario_calificado_id`),
  ADD KEY `idx_calificaciones_banderas` (`tipo_calificacion`,`revisado_admin`),
  ADD KEY `idx_calificaciones_calificado` (`usuario_calificado_id`);

--
-- Indexes for table `detalles_conductor`
--
ALTER TABLE `detalles_conductor`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero_licencia` (`numero_licencia`),
  ADD UNIQUE KEY `placa_vehiculo` (`placa_vehiculo`),
  ADD UNIQUE KEY `idx_detalles_conductor_usuario` (`usuario_id`);

--
-- Indexes for table `detalles_paquete`
--
ALTER TABLE `detalles_paquete`
  ADD PRIMARY KEY (`id`),
  ADD KEY `solicitud_id` (`solicitud_id`);

--
-- Indexes for table `detalles_viaje`
--
ALTER TABLE `detalles_viaje`
  ADD PRIMARY KEY (`id`),
  ADD KEY `solicitud_id` (`solicitud_id`);

--
-- Indexes for table `historial_seguimiento`
--
ALTER TABLE `historial_seguimiento`
  ADD PRIMARY KEY (`id`),
  ADD KEY `conductor_id` (`conductor_id`),
  ADD KEY `idx_seguimiento_solicitud` (`solicitud_id`),
  ADD KEY `idx_seguimiento_timestamp` (`timestamp_seguimiento`);

--
-- Indexes for table `logs_auditoria`
--
ALTER TABLE `logs_auditoria`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `accion` (`accion`),
  ADD KEY `fecha_creacion` (`fecha_creacion`);

--
-- Indexes for table `metodos_pago_usuario`
--
ALTER TABLE `metodos_pago_usuario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indexes for table `proveedores_mapa`
--
ALTER TABLE `proveedores_mapa`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indexes for table `reglas_precios`
--
ALTER TABLE `reglas_precios`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `solicitudes_servicio`
--
ALTER TABLE `solicitudes_servicio`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uuid_solicitud` (`uuid_solicitud`),
  ADD KEY `ubicacion_recogida_id` (`ubicacion_recogida_id`),
  ADD KEY `ubicacion_destino_id` (`ubicacion_destino_id`),
  ADD KEY `idx_solicitudes_cliente` (`cliente_id`),
  ADD KEY `idx_solicitudes_estado` (`estado`),
  ADD KEY `idx_solicitudes_fecha` (`solicitado_en`);

--
-- Indexes for table `tarifas`
--
ALTER TABLE `tarifas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tipo_vehiculo` (`tipo_vehiculo`);

--
-- Indexes for table `transacciones`
--
ALTER TABLE `transacciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_transacciones_solicitud` (`solicitud_id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `conductor_id` (`conductor_id`),
  ADD KEY `idx_transacciones_estado_pago` (`estado_pago`);

--
-- Indexes for table `ubicaciones_usuario`
--
ALTER TABLE `ubicaciones_usuario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uuid` (`uuid`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `telefono` (`telefono`),
  ADD UNIQUE KEY `idx_google_id` (`google_id`),
  ADD KEY `idx_usuarios_email` (`email`),
  ADD KEY `idx_usuarios_telefono` (`telefono`),
  ADD KEY `idx_usuarios_tipo` (`tipo_usuario`);

--
-- Indexes for table `verification_codes`
--
ALTER TABLE `verification_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_code` (`code`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `asignaciones_conductor`
--
ALTER TABLE `asignaciones_conductor`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `cache_direcciones`
--
ALTER TABLE `cache_direcciones`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cache_geocodificacion`
--
ALTER TABLE `cache_geocodificacion`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `calificaciones`
--
ALTER TABLE `calificaciones`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `detalles_conductor`
--
ALTER TABLE `detalles_conductor`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `detalles_paquete`
--
ALTER TABLE `detalles_paquete`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `detalles_viaje`
--
ALTER TABLE `detalles_viaje`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `historial_seguimiento`
--
ALTER TABLE `historial_seguimiento`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logs_auditoria`
--
ALTER TABLE `logs_auditoria`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `metodos_pago_usuario`
--
ALTER TABLE `metodos_pago_usuario`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `proveedores_mapa`
--
ALTER TABLE `proveedores_mapa`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reglas_precios`
--
ALTER TABLE `reglas_precios`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `solicitudes_servicio`
--
ALTER TABLE `solicitudes_servicio`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `tarifas`
--
ALTER TABLE `tarifas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `transacciones`
--
ALTER TABLE `transacciones`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `ubicaciones_usuario`
--
ALTER TABLE `ubicaciones_usuario`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `verification_codes`
--
ALTER TABLE `verification_codes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `asignaciones_conductor`
--
ALTER TABLE `asignaciones_conductor`
  ADD CONSTRAINT `asignaciones_conductor_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `asignaciones_conductor_ibfk_2` FOREIGN KEY (`conductor_id`) REFERENCES `usuarios` (`id`);

--
-- Constraints for table `calificaciones`
--
ALTER TABLE `calificaciones`
  ADD CONSTRAINT `calificaciones_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`),
  ADD CONSTRAINT `calificaciones_ibfk_2` FOREIGN KEY (`usuario_calificador_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `calificaciones_ibfk_3` FOREIGN KEY (`usuario_calificado_id`) REFERENCES `usuarios` (`id`);

--
-- Constraints for table `detalles_conductor`
--
ALTER TABLE `detalles_conductor`
  ADD CONSTRAINT `detalles_conductor_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `detalles_paquete`
--
ALTER TABLE `detalles_paquete`
  ADD CONSTRAINT `detalles_paquete_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `detalles_viaje`
--
ALTER TABLE `detalles_viaje`
  ADD CONSTRAINT `detalles_viaje_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `historial_seguimiento`
--
ALTER TABLE `historial_seguimiento`
  ADD CONSTRAINT `historial_seguimiento_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `historial_seguimiento_ibfk_2` FOREIGN KEY (`conductor_id`) REFERENCES `usuarios` (`id`);

--
-- Constraints for table `logs_auditoria`
--
ALTER TABLE `logs_auditoria`
  ADD CONSTRAINT `logs_auditoria_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `metodos_pago_usuario`
--
ALTER TABLE `metodos_pago_usuario`
  ADD CONSTRAINT `metodos_pago_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `solicitudes_servicio`
--
ALTER TABLE `solicitudes_servicio`
  ADD CONSTRAINT `solicitudes_servicio_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `solicitudes_servicio_ibfk_2` FOREIGN KEY (`ubicacion_recogida_id`) REFERENCES `ubicaciones_usuario` (`id`),
  ADD CONSTRAINT `solicitudes_servicio_ibfk_3` FOREIGN KEY (`ubicacion_destino_id`) REFERENCES `ubicaciones_usuario` (`id`);

--
-- Constraints for table `transacciones`
--
ALTER TABLE `transacciones`
  ADD CONSTRAINT `transacciones_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_servicio` (`id`),
  ADD CONSTRAINT `transacciones_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `transacciones_ibfk_3` FOREIGN KEY (`conductor_id`) REFERENCES `usuarios` (`id`);

--
-- Constraints for table `ubicaciones_usuario`
--
ALTER TABLE `ubicaciones_usuario`
  ADD CONSTRAINT `ubicaciones_usuario_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
