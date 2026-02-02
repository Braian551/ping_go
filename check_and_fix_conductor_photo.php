<?php
require_once 'backend-deploy/config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $userId = 4; // From logs
    
    echo "Checking profile photo for user $userId...\n";
    
    // Check DB first
    $stmt = $db->prepare("SELECT url_imagen_perfil FROM usuarios WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo "Current DB value: " . ($user['url_imagen_perfil'] ?? 'NULL') . "\n";
    
    // Check file system
    $dir = __DIR__ . "/backend-deploy/uploads/usuarios/$userId/";
    echo "Checking directory: $dir\n";
    
    if (is_dir($dir)) {
        $files = scandir($dir);
        $found = null;
        foreach ($files as $file) {
            if ($file == '.' || $file == '..') continue;
            if (strpos($file, 'profile_') === 0) {
                $found = $file;
                break;
            }
        }
        
        if ($found) {
            $relativePath = "uploads/usuarios/$userId/$found";
            echo "Found file: $found\n";
            echo "Relative path: $relativePath\n";
            
            if (empty($user['url_imagen_perfil'])) {
                echo "DB is empty. Updating...\n";
                $upd = $db->prepare("UPDATE usuarios SET url_imagen_perfil = ? WHERE id = ?");
                $upd->execute([$relativePath, $userId]);
                echo "Updated DB successfully.\n";
            } else {
                echo "DB already has a value (mismatch?).\n";
            }
        } else {
            echo "No profile photo found in directory.\n";
        }
    } else {
        echo "Directory not found.\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
