-- ============================================
-- J&P TECH SUPPORT - DATABASE SCHEMA
-- ============================================
CREATE DATABASE IF NOT EXISTS jp_tech_support CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE jp_tech_support;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('cliente','tecnico') NOT NULL DEFAULT 'cliente',
    avatar_url VARCHAR(255),
    verificado BOOLEAN DEFAULT FALSE,
    codigo_verificacion VARCHAR(10),
    codigo_expira DATETIME,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tecnicos_perfil (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    especialidad VARCHAR(100),
    anios_experiencia INT DEFAULT 0,
    certificacion_url VARCHAR(255),
    descripcion TEXT,
    disponible BOOLEAN DEFAULT TRUE,
    calificacion_promedio DECIMAL(3,2) DEFAULT 0.00,
    total_resenas INT DEFAULT 0,
    total_servicios INT DEFAULT 0,
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),
    ultima_ubicacion TIMESTAMP NULL,
    precio_por_hora DECIMAL(10,2) DEFAULT 50.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    icono VARCHAR(50),
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

INSERT INTO categorias (nombre, icono, descripcion) VALUES
('Soporte PC','computer','Reparación y mantenimiento de PCs'),
('Laptops','laptop','Servicio técnico para laptops'),
('Impresoras','print','Mantenimiento de impresoras'),
('Redes','wifi','Configuración de redes'),
('Servidores','dns','Soporte de servidores'),
('Software','code','Instalación de software'),
('Virus/Malware','security','Limpieza de virus');

CREATE TABLE IF NOT EXISTS solicitudes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folio VARCHAR(20) NOT NULL UNIQUE,
    cliente_id INT NOT NULL,
    tecnico_id INT,
    categoria_id INT NOT NULL,
    descripcion TEXT NOT NULL,
    urgencia ENUM('baja','media','alta') DEFAULT 'media',
    estado ENUM('pendiente','buscando','ofertando','confirmado','en_camino','en_progreso','finalizado','cancelado') DEFAULT 'pendiente',
    fecha_servicio DATE,
    horario_inicio TIME,
    horario_fin TIME,
    direccion TEXT NOT NULL,
    latitud_cliente DECIMAL(10,8),
    longitud_cliente DECIMAL(11,8),
    precio_oferta DECIMAL(10,2),
    precio_final DECIMAL(10,2),
    imagen_problema_url VARCHAR(255),
    imagen_trabajo_url VARCHAR(255),
    resumen_trabajo TEXT,
    materiales_usados TEXT,
    notas_tecnico TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES users(id),
    FOREIGN KEY (tecnico_id) REFERENCES users(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE IF NOT EXISTS ofertas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    solicitud_id INT NOT NULL,
    tecnico_id INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    mensaje TEXT,
    estado ENUM('pendiente','aceptada','rechazada') DEFAULT 'pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE,
    FOREIGN KEY (tecnico_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS mensajes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    solicitud_id INT NOT NULL,
    emisor_id INT NOT NULL,
    receptor_id INT NOT NULL,
    contenido TEXT,
    tipo ENUM('texto','imagen','ubicacion','sistema') DEFAULT 'texto',
    imagen_url VARCHAR(255),
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),
    leido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE,
    FOREIGN KEY (emisor_id) REFERENCES users(id),
    FOREIGN KEY (receptor_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS resenas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    solicitud_id INT NOT NULL UNIQUE,
    cliente_id INT NOT NULL,
    tecnico_id INT NOT NULL,
    calificacion TINYINT NOT NULL,
    comentario TEXT,
    tags JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id),
    FOREIGN KEY (cliente_id) REFERENCES users(id),
    FOREIGN KEY (tecnico_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS marketplace_leads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    solicitud_id INT NOT NULL,
    precio_lead DECIMAL(10,2) NOT NULL,
    desbloqueado_por INT,
    desbloqueado_at TIMESTAMP NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id),
    FOREIGN KEY (desbloqueado_por) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS ubicaciones_tecnico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tecnico_id INT NOT NULL,
    solicitud_id INT,
    latitud DECIMAL(10,8) NOT NULL,
    longitud DECIMAL(11,8) NOT NULL,
    precision_metros FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tecnico_id) REFERENCES users(id),
    FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id)
);

CREATE TABLE IF NOT EXISTS notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(50),
    leida BOOLEAN DEFAULT FALSE,
    data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_solicitudes_cliente ON solicitudes(cliente_id);
CREATE INDEX idx_solicitudes_tecnico ON solicitudes(tecnico_id);
CREATE INDEX idx_solicitudes_estado ON solicitudes(estado);
CREATE INDEX idx_mensajes_solicitud ON mensajes(solicitud_id);
CREATE INDEX idx_ofertas_solicitud ON ofertas(solicitud_id);
CREATE INDEX idx_tecnicos_disponible ON tecnicos_perfil(disponible);
