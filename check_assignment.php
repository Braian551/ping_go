<?php
require_once 'backend-deploy/config/database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $conductorIdInLog = 4;
    
    echo "Checking latest assignment for conductor $conductorIdInLog...\n";
    
    // Get latest assignment
    $stmt = $db->prepare("SELECT * FROM asignaciones_conductor WHERE conductor_id = ? ORDER BY id DESC LIMIT 1");
    $stmt->execute([$conductorIdInLog]);
    $assign = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$assign) {
        echo "No assignment found for conductor 4.\n";
    } else {
        echo "Found assignment ID: " . $assign['id'] . "\n";
        echo "Solicitud ID: " . $assign['solicitud_id'] . "\n";
        echo "Conductor ID in Assignment: " . $assign['conductor_id'] . "\n";
        
        $solicitudId = $assign['solicitud_id'];
        
        // Now run the query from get_trip_status.php
        echo "\nRunning get_trip_status.php query logic...\n";
        
        $sql = " 
        SELECT 
            s.id,
            ac.conductor_id,
            u.nombre as conductor_nombre,
            u.url_imagen_perfil as conductor_foto
        FROM solicitudes_servicio s
        LEFT JOIN asignaciones_conductor ac ON s.id = ac.solicitud_id AND ac.estado = 'asignado'
        LEFT JOIN usuarios u ON ac.conductor_id = u.id
        WHERE s.id = ?
        ";
        
        $stmt2 = $db->prepare($sql);
        $stmt2->execute([$solicitudId]);
        $result = $stmt2->fetch(PDO::FETCH_ASSOC);
        
        if ($result) {
            echo "Result:\n";
            print_r($result);
        } else {
            echo "No result for query.\n";
        }
        
        // Also check if 'asignado' state is correct
        echo "\nChecking assignment state: " . $assign['estado'] . "\n";
        if ($assign['estado'] !== 'asignado') {
            echo "WARNING: Assignment state is NOT 'asignado', so the LEFT JOIN condition 'ac.estado = assigned' might fail?\n";
            // Check query again without state condition
             $sql3 = " 
                SELECT 
                    s.id,
                    ac.conductor_id,
                    ac.estado as assign_state,
                    u.url_imagen_perfil as conductor_foto
                FROM solicitudes_servicio s
                LEFT JOIN asignaciones_conductor ac ON s.id = ac.solicitud_id
                LEFT JOIN usuarios u ON ac.conductor_id = u.id
                WHERE s.id = ? AND ac.conductor_id = ?
            ";
            $stmt3 = $db->prepare($sql3);
            $stmt3->execute([$solicitudId, $conductorIdInLog]);
            $res3 = $stmt3->fetch(PDO::FETCH_ASSOC);
             echo "Result without state filter:\n";
             print_r($res3);
        }

    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
