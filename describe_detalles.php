<?php
require_once __DIR__ . '/backend-deploy/config/database.php';
$db = (new Database())->getConnection();
$res = $db->query('DESCRIBE detalles_conductor');
print_r($res->fetchAll(PDO::FETCH_ASSOC));
?>
