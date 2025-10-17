<?php
// api.php
require_once 'conexion.php'; // Incluye la conexión PDO y las funciones auxiliares

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

// ------------------------------------------------------------------
// --- LÓGICA DE RUTEO ---
// ------------------------------------------------------------------

switch($action) {
    // READ
    case 'productos':
        if($method === 'GET') obtenerProductos();
        break;

    // CREATE, UPDATE, DELETE usan POST y requieren datos JSON
    case 'crear':
    case 'update':
    case 'delete':
        if($method === 'POST') {
            $data = json_decode(file_get_contents('php://input'), true);
            if(!$data) response(false, 'Datos JSON inválidos o faltantes.');

            if($action === 'crear') crearProducto($data);
            if($action === 'update') actualizarProducto($data);
            if($action === 'delete') eliminarProducto($data);
        }
        break;
        
    default:
        // Manejar acciones no válidas o métodos no soportados
        response(false, 'Acción no encontrada o método no soportado para la acción.');
}

// ------------------------------------------------------------------
// --- FUNCIONES CRUD ---
// ------------------------------------------------------------------

// READ: Obtener todos los productos
function obtenerProductos() {
    global $pdo;
    try {
        $sql = "SELECT id, nombre, descripcion, codigo_barras, categoria, precio, stock, proveedor, fecha_ingreso, activo 
                FROM productos 
                ORDER BY id DESC";
        $stmt = $pdo->query($sql);
        $productos = $stmt->fetchAll(PDO::FETCH_ASSOC);
        response(true, 'Productos listados correctamente', $productos);
    } catch(PDOException $e) {
        response(false, 'Error al obtener productos: ' . $e->getMessage());
    }
}

// CREATE: Crear un nuevo producto
function crearProducto($data) {
    global $pdo;
    
    // Validaciones
    if (empty($data['nombre']) || empty($data['codigo_barras']) || !is_numeric($data['precio'])) {
        response(false, 'Campos obligatorios (nombre, codigo_barras, precio) inválidos.');
    }
    
    try {
        // 1. Validar unicidad del código de barras
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM productos WHERE codigo_barras = ?");
        $stmt->execute([$data['codigo_barras']]);
        if ($stmt->fetchColumn() > 0) {
            response(false, 'El código de barras ya existe.', ['codigo_barras' => $data['codigo_barras']]);
        }

        // 2. Inserción (8 columnas, 8 marcadores)
        $sql = "INSERT INTO productos (nombre, descripcion, codigo_barras, categoria, precio, stock, proveedor, activo) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $data['nombre'],
            $data['descripcion'] ?? '',
            $data['codigo_barras'],
            $data['categoria'] ?? 'Sin Categoría',
            $data['precio'],
            $data['stock'] ?? 0,
            $data['proveedor'] ?? 'Desconocido',
            $data['activo'] ?? 1 
        ]);
        
        response(true, 'Producto creado correctamente', ['id' => $pdo->lastInsertId()]);
    } catch(PDOException $e) {
        response(false, 'Error de DB al crear: ' . $e->getMessage());
    }
}

// UPDATE: Actualizar un producto existente
function actualizarProducto($data) {
    global $pdo;
    
    // Validaciones
    if (empty($data['id']) || empty($data['nombre']) || !is_numeric($data['precio'])) {
        response(false, 'ID o campos obligatorios (nombre, precio) faltantes para la actualización.');
    }

    try {
        // La actualización requiere 8 valores + 1 ID = 9 marcadores en total.
        $sql = "UPDATE productos SET 
                nombre = ?, descripcion = ?, codigo_barras = ?, categoria = ?, 
                precio = ?, stock = ?, proveedor = ?, activo = ? 
                WHERE id = ?";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $data['nombre'],
            $data['descripcion'] ?? '',
            $data['codigo_barras'] ?? '', // Permitir que sea NULL si no se envía, aunque en DB es NOT NULL
            $data['categoria'] ?? 'Sin Categoría',
            $data['precio'],
            $data['stock'] ?? 0,
            $data['proveedor'] ?? 'Desconocido',
            $data['activo'] ?? 1,
            $data['id'] // ID es el último parámetro para el WHERE
        ]);
        
        if ($stmt->rowCount() > 0) {
            response(true, 'Producto actualizado correctamente');
        } else {
            response(false, 'Producto no encontrado o no hubo cambios.');
        }
    } catch(PDOException $e) {
        response(false, 'Error de DB al actualizar: ' . $e->getMessage());
    }
}

// DELETE: Eliminar un producto
function eliminarProducto($data) {
    global $pdo;
    if (empty($data['id'])) {
        response(false, 'ID del producto es requerido para eliminar.');
    }
    
    try {
        $stmt = $pdo->prepare("DELETE FROM productos WHERE id = ?");
        $stmt->execute([$data['id']]);
        
        if ($stmt->rowCount() > 0) {
            response(true, 'Producto eliminado correctamente');
        } else {
            response(false, 'Producto no encontrado o ya eliminado.');
        }
    } catch(PDOException $e) {
        response(false, 'Error de DB al eliminar: ' . $e->getMessage());
    }
}
?>