<?php
require_once __DIR__ . '/backend-deploy/config/database.php';
$db = (new Database())->getConnection();
$res = $db->query('SELECT COUNT(*) as total FROM calificaciones');
print_r($res->fetch(PDO::FETCH_ASSOC));
?>
