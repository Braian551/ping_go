<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "<h2>Database Connection Test</h2>";

require_once __DIR__ . '/config/database.php';

try {
    $database = new Database();
    
    echo "<p>Checking Env Variables:</p>";
    echo "DB_HOST: " . getenv('DB_HOST') . "<br>";
    echo "DB_USER: " . getenv('DB_USER') . "<br>";
    echo "DB_NAME: " . getenv('DB_NAME') . "<br>";
    
    $db = $database->getConnection();
    echo "<h3 style='color:green'>Success! Connected to database.</h3>";
    
} catch (Exception $e) {
    echo "<h3 style='color:red'>Connection Failed!</h3>";
    echo "Error: " . $e->getMessage();
}
?>
