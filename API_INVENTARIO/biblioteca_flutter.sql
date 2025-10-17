<?php
// conexion.php

// Configuración de encabezados para CORS y JSON
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // Permite el acceso desde Flutter
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Configuración de la base de datos (basado en tu config anterior)
$host = 'localhost';
$dbname = 'biblioteca_flutter'; 
$username = 'root';
$password = '';

// Función auxiliar para respuestas JSON estandarizadas
function response($success, $message, $data = null) {
    echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
    exit;
}

// Manejo del preflight de CORS (petición OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    // Establecer la conexión PDO
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    // Detener la ejecución si hay un error de conexión
    http_response_code(500);
    response(false, 'Error de conexión a la base de datos: ' . $e->getMessage());
}
?>