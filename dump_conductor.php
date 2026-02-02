<?php
require_once __DIR__ . '/backend-deploy/config/database.php';
$db = (new Database())->getConnection();
$res = $db->query('SELECT * FROM detalles_conductor WHERE usuario_id = 4');
print_r($res->fetch(PDO::FETCH_ASSOC));
?>
