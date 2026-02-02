<?php
require_once __DIR__ . '/backend-deploy/config/database.php';
$db = (new Database())->getConnection();

$stmt = $db->query("SELECT u.id, u.nombre, u.apellido, dc.placa_vehiculo, dc.calificacion_promedio, dc.total_calificaciones FROM usuarios u JOIN detalles_conductor dc ON u.id = dc.usuario_id");
$conductors = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($conductors as $c) {
    echo "ID: " . $c['id'] . " | Name: " . $c['nombre'] . " " . $c['apellido'] . " | Placa: " . $c['placa_vehiculo'] . " | Rating: " . $c['calificacion_promedio'] . " | Total Ratings: " . $c['total_calificaciones'] . "\n";
}
?>
