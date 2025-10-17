<?php
// conexion.php

// ------------------------------------------------------------------
// --- CONFIGURACIÓN DE ENCABEZADOS Y CORS ---
// ------------------------------------------------------------------
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// ------------------------------------------------------------------
// --- CONFIGURACIÓN DE LA BASE DE DATOS ---
// ------------------------------------------------------------------
$host = 'localhost';
$dbname = 'biblioteca_flutter'; // Tu base de datos
$username = 'root';
$password = ''; // Si usas XAMPP en Windows, suele ser vacío

// ------------------------------------------------------------------
// --- FUNCIÓN AUXILIAR DE RESPUESTA JSON ---
// ------------------------------------------------------------------
function response($success, $message, $data = null) {
    echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
    exit;
}

// ------------------------------------------------------------------
// --- MANEJO DE CONEXIÓN Y CORS OPTIONS ---
// ------------------------------------------------------------------

// Manejo del preflight de CORS (petición OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    // Establecer la conexión PDO
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    // Para asegurar que la conexión esté definida globalmente para api.php
} catch(PDOException $e) {
    // Detener la ejecución si hay un error de conexión
    http_response_code(500);
    response(false, 'Error de conexión a la base de datos: ' . $e->getMessage());
}
?>