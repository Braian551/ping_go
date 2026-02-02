<?php
require_once __DIR__ . '/backend-deploy/config/database.php';
$db = (new Database())->getConnection();
$res = $db->query('SELECT * FROM detalles_conductor WHERE usuario_id = 4');
$row = $res->fetch(PDO::FETCH_ASSOC);

echo "Checking columns for conductor 4:\n";
foreach ($row as $col => $val) {
    if (is_numeric($val) && $val > 0 && (strpos($col, 'calif') !== false || strpos($col, 'rating') !== false || $val <= 5)) {
         echo "$col: $val\n";
    }
}
?>
