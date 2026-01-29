-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 29, 2026 at 07:12 PM
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
  `estado` enum('asignado','llegado','cancelado') DEFAULT 'asignado'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
  `comentarios` text,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ;

-- --------------------------------------------------------

--
-- Table structure for table `detalles_conductor`
--

CREATE TABLE `detalles_conductor` (
  `id` bigint UNSIGNED NOT NULL,
  `usuario_id` bigint UNSIGNED NOT NULL,
  `numero_licencia` varchar(50) NOT NULL,
  `vencimiento_licencia` date NOT NULL,
  `tipo_vehiculo` enum('motocicleta','carro','furgoneta','camion') NOT NULL,
  `marca_vehiculo` varchar(50) DEFAULT NULL,
  `modelo_vehiculo` varchar(50) DEFAULT NULL,
  `ano_vehiculo` int DEFAULT NULL,
  `color_vehiculo` varchar(30) DEFAULT NULL,
  `placa_vehiculo` varchar(20) NOT NULL,
  `aseguradora` varchar(100) DEFAULT NULL,
  `numero_poliza_seguro` varchar(100) DEFAULT NULL,
  `vencimiento_seguro` date DEFAULT NULL,
  `aprobado` tinyint(1) DEFAULT '0',
  `estado_aprobacion` enum('pendiente','aprobado','rechazado') DEFAULT 'pendiente',
  `calificacion_promedio` decimal(3,2) DEFAULT '0.00',
  `total_calificaciones` int DEFAULT '0',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
  `estado` enum('pendiente','aceptada','conductor_asignado','recogido','en_transito','entregado','completada','cancelada') DEFAULT 'pendiente',
  `solicitado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `aceptado_en` timestamp NULL DEFAULT NULL,
  `recogido_en` timestamp NULL DEFAULT NULL,
  `entregado_en` timestamp NULL DEFAULT NULL,
  `completado_en` timestamp NULL DEFAULT NULL,
  `cancelado_en` timestamp NULL DEFAULT NULL,
  `motivo_cancelacion` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
  `metodo_pago` enum('efectivo','tarjeta_credito','tarjeta_debito','billetera_digital') NOT NULL,
  `estado_pago` enum('pendiente','procesando','completado','fallido','reembolsado') DEFAULT 'pendiente',
  `fecha_transaccion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `completado_en` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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

--
-- Dumping data for table `ubicaciones_usuario`
--

INSERT INTO `ubicaciones_usuario` (`id`, `usuario_id`, `latitud`, `longitud`, `direccion`, `ciudad`, `departamento`, `pais`, `codigo_postal`, `es_principal`, `creado_en`, `actualizado_en`) VALUES
(1, 1, '6.25461830', '-75.53955670', 'Carrera 18B, Llanaditas, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Antioquia, Colombia', 'Perímetro Urbano Medellín', 'Antioquia', 'Colombia', NULL, 1, '2025-09-29 21:11:52', NULL),
(2, 2, '6.24546848', '-75.54230341', 'Carrera 24BB, Cra 44BB#56EE 13, El Pinal, Comuna 8 - Villa Hermosa, Perímetro Urbano Medellín, Antioquia, Colombia', 'Perímetro Urbano Medellín', 'Antioquia', 'Colombia', NULL, 1, '2025-10-06 22:47:34', NULL),
(3, 3, '6.25504918', '-75.53958122', 'Carrera 18B, Llanaditas, Comuna 8 - Villa Hermosa, Medellín, Antioquia, Colombia', 'Medellín', 'Antioquia', 'Colombia', NULL, 1, '2025-10-06 23:13:22', NULL);

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
  `telefono` varchar(20) NOT NULL,
  `hash_contrasena` varchar(255) NOT NULL,
  `tipo_usuario` enum('cliente','conductor','administrador') DEFAULT 'cliente',
  `url_imagen_perfil` varchar(500) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `verificado` tinyint(1) DEFAULT '0',
  `activo` tinyint(1) DEFAULT '1',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_en` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `ultimo_acceso_en` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id`, `uuid`, `nombre`, `apellido`, `email`, `telefono`, `hash_contrasena`, `tipo_usuario`, `url_imagen_perfil`, `fecha_nacimiento`, `verificado`, `activo`, `creado_en`, `actualizado_en`, `ultimo_acceso_en`) VALUES
(1, 'user_68daf618780e50.65802566', 'braian', 'oquendo', 'braianoquen@gmail.com', '3013636902', '$2y$10$H2Un4DmxCsM6XOGA1fiX8.5VB42Z9v8uwqERrGBms83dk2CQVQKnO', 'cliente', NULL, NULL, 0, 1, '2025-09-29 21:11:52', NULL, NULL),
(2, 'user_68e44706c14db4.53994811', 'braian890', 'oquendo', 'braian890@gmail.com', '32323232', '$2y$10$NB9S4hWQLrK7HhTjc9yneu9RTb6otip3dtZ1muEgukWWLKcSpxRF6', 'cliente', NULL, NULL, 0, 1, '2025-10-06 22:47:34', NULL, NULL),
(3, 'user_68e44d12079086.97442308', 'braianoquen79', 'oquendo', 'braianoquen79@gmail.com', '34343434', '$2y$10$6LhMx5vHi.3LrrM/EjFjw.ZztZWhhGQgqf1sD76h2RtJ4B7nN/sjC', 'cliente', NULL, NULL, 0, 1, '2025-10-06 23:13:22', NULL, NULL),
(4, 'user_697baef85a9e91.65860958', 'braianoquendurango', 'oquendo', 'braianoquendurango@gmail.com', '435534', '$2y$10$g5wGaB2WHR1f7HmjFrpdluz.UGCBpjNpxxxAKTjLTkvetk/gASKd2', 'cliente', NULL, NULL, 0, 1, '2026-01-29 19:03:20', NULL, NULL);

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
-- Dumping data for table `verification_codes`
--

INSERT INTO `verification_codes` (`id`, `email`, `code`, `created_at`, `expires_at`, `used`) VALUES
(1, 'braianoquen@gmail.com', '184773', '2025-09-22 00:02:19', '2025-09-22 05:12:19', 0),
(2, 'braianoquen@gmail.com', '740721', '2025-09-22 00:40:36', '2025-09-22 05:50:36', 0),
(3, 'braianoquen@gmail.com', '470836', '2025-09-22 03:16:18', '2025-09-22 08:26:18', 0),
(4, 'braianoquen@gmail.com', '553736', '2025-09-22 03:32:16', '2025-09-22 08:42:16', 0),
(5, 'braianoquen@gmail.com', '558786', '2025-09-22 03:42:09', '2025-09-22 08:52:09', 0),
(6, 'braianoquen@gmail.com', '871431', '2025-09-22 03:44:25', '2025-09-22 08:54:25', 0),
(7, 'braianoquen@gmail.com', '109811', '2025-09-22 03:48:08', '2025-09-22 08:58:08', 0),
(8, 'braianoquen@gmail.com', '895561', '2025-09-22 04:05:48', '2025-09-22 09:15:48', 0),
(9, 'traconmaster@gmail.com', '517375', '2025-09-22 04:09:27', '2025-09-22 09:19:27', 0),
(10, 'tracongames2@gmail.com', '439802', '2025-09-22 04:29:37', '2025-09-22 09:39:37', 0),
(11, 'tracongames3@gmail.com', '928041', '2025-09-22 04:40:27', '2025-09-22 09:50:27', 0),
(12, 'braianoquen@gmail.com', '471108', '2025-09-22 04:50:52', '2025-09-22 10:00:52', 0),
(13, 'braianoquen@gmail.com', '289263', '2025-09-22 04:59:38', '2025-09-22 10:09:38', 0),
(14, 'tracon2@gmail.com', '972225', '2025-09-22 23:15:48', '2025-09-23 04:25:48', 0),
(15, 'braianoquen@gmail.com', '532386', '2025-09-22 23:17:22', '2025-09-23 04:27:22', 0),
(16, 'gellen@gmail.com', '836288', '2025-09-29 16:33:39', '2025-09-29 21:43:39', 0),
(17, 'gellen2@gmail.com', '618398', '2025-09-29 16:42:48', '2025-09-29 21:52:48', 0),
(18, 'gellen4@gmail.com', '503956', '2025-09-29 16:59:45', '2025-09-29 22:09:45', 0),
(19, 'gellen4@gmail.com', '215305', '2025-09-29 17:06:30', '2025-09-29 22:16:30', 0),
(20, 'gellen2@gmail.com', '309347', '2025-09-29 17:12:20', '2025-09-29 22:22:20', 0),
(21, 'gellen2@gmail.com', '430759', '2025-09-29 17:16:52', '2025-09-29 22:26:52', 0),
(22, 'gellen2@gmail.com', '571778', '2025-09-29 17:24:00', '2025-09-29 22:34:00', 0),
(23, 'gellen2@gmail.com', '641077', '2025-09-29 17:30:09', '2025-09-29 22:40:09', 0),
(24, 'gellen2@gmail.com', '129852', '2025-09-29 17:36:07', '2025-09-29 22:46:07', 0),
(25, 'gellen2@gmail.com', '644993', '2025-09-29 17:43:12', '2025-09-29 22:53:12', 0),
(26, 'gellen2@gmail.com', '931663', '2025-09-29 17:47:56', '2025-09-29 22:57:56', 0),
(27, 'gellen2@gmail.com', '661112', '2025-09-29 17:50:41', '2025-09-29 23:00:41', 0),
(28, 'gellen2@gmail.com', '580543', '2025-09-29 17:51:12', '2025-09-29 23:01:12', 0),
(29, 'gellen2@gmail.com', '105869', '2025-09-29 17:55:34', '2025-09-29 23:05:34', 0),
(30, 'gellen34@gmail.com', '345823', '2025-09-29 18:02:16', '2025-09-29 23:12:16', 0),
(31, 'gellen2@gmail.com', '749371', '2025-09-29 18:06:18', '2025-09-29 23:16:18', 0),
(32, 'gellen2@gmail.com', '108467', '2025-09-29 18:11:22', '2025-09-29 23:21:22', 0),
(33, 'gellen2@gmail.com', '828608', '2025-09-29 18:17:44', '2025-09-29 23:27:44', 0),
(34, 'andres80@gmail.com', '263140', '2025-09-29 19:18:28', '2025-09-30 00:28:28', 0),
(35, 'braianoquen@gmail.com', '891517', '2025-09-29 19:26:17', '2025-09-30 00:36:17', 0),
(36, 'braianoquen@gmail.com', '557643', '2025-09-29 19:37:35', '2025-09-30 00:47:35', 0),
(37, 'braianoquen@gmail.com', '898296', '2025-09-29 19:44:37', '2025-09-30 00:54:37', 0),
(38, 'braianoquen@gmail.com', '750790', '2025-09-29 20:11:50', '2025-09-30 01:21:50', 0),
(39, 'braianoquendurango@gmail.com', '636850', '2025-09-29 20:13:08', '2025-09-30 01:23:08', 0),
(40, 'braianoquendurango@gmail.com', '619818', '2025-09-29 20:23:00', '2025-09-30 01:33:00', 0),
(41, 'braianoquendurango@gmail.com', '906593', '2025-09-29 20:29:27', '2025-09-30 01:39:27', 0),
(42, 'braianoquen@gmail.com', '824558', '2025-09-29 20:31:55', '2025-09-30 01:41:55', 0),
(43, 'braianoquen@gmail.com', '819688', '2025-09-29 20:36:15', '2025-09-30 01:46:15', 0),
(44, 'braianoquen@gmail.com', '311995', '2025-09-29 20:37:09', '2025-09-30 01:47:09', 0),
(45, 'braianoquen@gmail.com', '187066', '2025-09-29 20:37:48', '2025-09-30 01:47:48', 0),
(46, 'braianoquen@gmail.com', '501886', '2025-09-29 20:55:37', '2025-09-30 02:05:37', 0),
(47, 'braianoquen@gmail.com', '274084', '2025-09-29 21:02:39', '2025-09-30 02:12:39', 0),
(48, 'braianoquen@gmail.com', '614962', '2025-09-29 21:08:06', '2025-09-30 02:18:06', 0),
(49, 'braianoquen@gmail.com', '377184', '2025-09-29 21:10:58', '2025-09-30 02:20:58', 0),
(50, 'braianoquendurango@gmail.com', '940771', '2025-10-05 12:31:26', '2025-10-05 17:41:26', 0),
(51, 'braianoquendurango@gmail.com', '156648', '2025-10-05 12:33:09', '2025-10-05 17:43:09', 0),
(52, 'braianoquendurango@gmail.com', '360795', '2025-10-05 13:14:57', '2025-10-05 18:24:57', 0),
(53, 'braianoquendurango@gmail.com', '270293', '2025-10-05 13:18:24', '2025-10-05 18:28:24', 0),
(54, 'braianoquendurango@gmail.com', '366137', '2025-10-05 13:22:20', '2025-10-05 18:32:20', 0),
(55, 'braianoquendurango@gmail.com', '219856', '2025-10-05 13:22:53', '2025-10-05 18:32:53', 0),
(56, 'braianoquendurango@gmail.com', '246651', '2025-10-05 13:43:15', '2025-10-05 18:53:15', 0),
(57, 'braianoquendurango@gmail.com', '170449', '2025-10-05 13:48:15', '2025-10-05 18:58:15', 0),
(58, 'braianoquendurango@gmail.com', '897340', '2025-10-05 13:53:37', '2025-10-05 19:03:37', 0),
(59, 'braianoquendurango@gmail.com', '816291', '2025-10-05 13:57:58', '2025-10-05 19:07:58', 0),
(60, 'braianoquendurango@gmail.com', '834542', '2025-10-05 14:02:31', '2025-10-05 19:12:31', 0),
(61, 'braianoquendurango@gmail.com', '220660', '2025-10-05 14:07:14', '2025-10-05 19:17:14', 0),
(62, 'braianoquendurango@gmail.com', '527698', '2025-10-05 16:34:49', '2025-10-05 21:44:49', 0),
(63, 'braianoquendurango@gmail.com', '947445', '2025-10-05 16:46:56', '2025-10-05 21:56:56', 0),
(64, 'braianoquendurango@gmail.com', '687214', '2025-10-05 17:05:14', '2025-10-05 22:15:14', 0),
(65, 'braianoquendurango@gmail.com', '586620', '2025-10-05 17:35:18', '2025-10-05 22:45:18', 0),
(66, 'braianoquendurango@gmail.com', '476004', '2025-10-05 17:42:10', '2025-10-05 22:52:10', 0),
(67, 'braianoquen@gmail.com', '822586', '2025-10-05 18:51:09', '2025-10-06 00:01:09', 0),
(68, 'braianoquen@gmail.com', '768999', '2025-10-05 20:15:24', '2025-10-06 01:25:24', 0),
(69, 'braianoquen@gmail.com', '635063', '2025-10-05 20:16:32', '2025-10-06 01:26:32', 0),
(70, 'braianoquen@gmail.com', '663502', '2025-10-05 20:31:20', '2025-10-06 01:41:20', 0),
(71, 'braianoquen@gmail.com', '656436', '2025-10-05 20:55:10', '2025-10-06 02:05:10', 0),
(72, 'braianoquen@gmail.com', '950733', '2025-10-06 22:42:36', '2025-10-07 03:52:36', 0),
(73, 'braianoquen@gmail.com', '972074', '2025-10-06 22:44:02', '2025-10-07 03:54:02', 0),
(74, 'braian890@gmail.com', '174360', '2025-10-06 22:45:51', '2025-10-07 03:55:51', 0),
(75, 'braianoquen@gmail.com', '701975', '2025-10-06 22:49:07', '2025-10-07 03:59:07', 0),
(76, 'braianoquen79@gmail.com', '185834', '2025-10-06 23:07:49', '2025-10-07 04:17:49', 0);

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
  ADD KEY `usuario_calificado_id` (`usuario_calificado_id`);

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
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

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
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

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
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transacciones`
--
ALTER TABLE `transacciones`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ubicaciones_usuario`
--
ALTER TABLE `ubicaciones_usuario`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `verification_codes`
--
ALTER TABLE `verification_codes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

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
