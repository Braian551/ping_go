<?php
require_once __DIR__ . '/backend-deploy/config/database.php';
$db = (new Database())->getConnection();

$stmt = $db->query("SELECT s.id as solicitud_id, s.estado, ac.conductor_id, ac.estado as estado_asignacion 
                    FROM solicitudes_servicio s 
                    LEFT JOIN asignaciones_conductor ac ON s.id = ac.solicitud_id 
                    ORDER BY s.id DESC LIMIT 5");
print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
?>
