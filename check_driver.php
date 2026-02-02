<?php
require_once __DIR__ . '/backend-deploy/config/database.php';
$db = (new Database())->getConnection();

$placa = 'h234';
$stmt = $db->prepare("SELECT u.nombre, u.apellido, dc.* FROM detalles_conductor dc JOIN usuarios u ON dc.usuario_id = u.id WHERE dc.placa_vehiculo = ?");
$stmt->execute([$placa]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

if ($row) {
    echo "Conductor: " . $row['nombre'] . " " . $row['apellido'] . "\n";
    echo "Calificación Promedio: " . $row['calificacion_promedio'] . "\n";
    echo "Total Calificaciones: " . $row['total_calificaciones'] . "\n";
} else {
    echo "Conductor con placa $placa no encontrado.\n";
}
?>
