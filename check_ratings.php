<?php
require_once __DIR__ . '/backend-deploy/config/database.php';
$db = (new Database())->getConnection();

// First get the user_id for the plate h234
$placa = 'h234';
$stmt = $db->prepare("SELECT usuario_id FROM detalles_conductor WHERE placa_vehiculo = ?");
$stmt->execute([$placa]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

if ($row) {
    $conductorId = $row['usuario_id'];
    echo "Conductor User ID: $conductorId\n";
    
    // Check ratings
    $stmt = $db->prepare("SELECT * FROM calificaciones WHERE usuario_calificado_id = ?");
    $stmt->execute([$conductorId]);
    $ratings = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Total ratings in 'calificaciones' table: " . count($ratings) . "\n";
    foreach ($ratings as $r) {
        echo " - Solicitud: " . $r['solicitud_id'] . ", Calificación: " . $r['calificacion'] . "\n";
    }
} else {
    echo "Conductor con placa $placa no encontrado.\n";
}
?>
