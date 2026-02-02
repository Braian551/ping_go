<?php
require_once 'backend-deploy/config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $stmt = $db->query("SHOW COLUMNS FROM detalles_conductor");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Columns in detalles_conductor:\n";
    foreach ($columns as $col) {
        echo $col['Field'] . "\n";
    }

    echo "\nColumns in usuarios:\n";
    $stmt2 = $db->query("SHOW COLUMNS FROM usuarios");
    $columns2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns2 as $col) {
        echo $col['Field'] . "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
