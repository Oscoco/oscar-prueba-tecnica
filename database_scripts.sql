CREATE DATABASE SistemaMatriculas;
GO

-- Usar la base de datos
USE SistemaMatriculas;
GO

-- Tabla de Estudiantes
CREATE TABLE estudiantes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_completo NVARCHAR(100) NOT NULL,
    carnet NVARCHAR(20) NOT NULL UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Tabla de Materias
CREATE TABLE materias (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    codigo NVARCHAR(20) NOT NULL UNIQUE,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Tabla de Matrículas
CREATE TABLE matriculas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_materia INT NOT NULL,
    fecha DATETIME2 DEFAULT GETDATE(),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id),
    FOREIGN KEY (id_materia) REFERENCES materias(id),
    -- Evitar matrículas duplicadas
    CONSTRAINT UK_matricula_estudiante_materia UNIQUE (id_estudiante, id_materia)
);

-- pb datos


INSERT INTO estudiantes (nombre_completo, carnet, fecha_nacimiento) VALUES
('Juan Carlos Pérez García', '2024001', '2000-05-15'),
('María Elena Rodríguez López', '2024002', '1999-08-22'),
('Carlos Alberto Martínez Silva', '2024003', '2001-03-10'),
('Ana Sofía González Herrera', '2024004', '2000-11-28'),
('Luis Fernando Torres Vega', '2024005', '1998-12-05');


INSERT INTO materias (nombre, codigo) VALUES
('Matemáticas I', 'MAT101'),
('Física I', 'FIS101'),
('Química I', 'QUI101'),
('Programación I', 'PRO101'),
('Inglés I', 'ING101'),
('Historia', 'HIS101'),
('Literatura', 'LIT101'),
('Biología I', 'BIO101'),
('Cálculo I', 'CAL101'),
('Estadística', 'EST101');

INSERT INTO matriculas (id_estudiante, id_materia) VALUES
(1, 1), -- Juan Carlos - Matemáticas I
(1, 2), -- Juan Carlos - Física I
(1, 4), -- Juan Carlos - Programación I
(2, 3), -- María Elena - Química I
(2, 5), -- María Elena - Inglés I
(3, 1), -- Carlos Alberto - Matemáticas I
(3, 8), -- Carlos Alberto - Biología I
(3, 6); -- Carlos Alberto - Historia


-- Procedimientos


CREATE PROCEDURE sp_matricula_estudiantes
    @carnet NVARCHAR(20),
    @codigo_materia NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @id_estudiante INT;
    DECLARE @id_materia INT;
    DECLARE @mensaje NVARCHAR(500);
    DECLARE @exito BIT = 0;
    
    BEGIN TRY
        -- Validar que el carnet existe
        SELECT @id_estudiante = id 
        FROM estudiantes 
        WHERE carnet = @carnet;
        
        IF @id_estudiante IS NULL
        BEGIN
            SET @mensaje = 'Error: El carnet ' + @carnet + ' no existe en la base de datos.';
            RAISERROR(@mensaje, 16, 1);
            RETURN;
        END
        
        -- Validar que la materia existe
        SELECT @id_materia = id 
        FROM materias 
        WHERE codigo = @codigo_materia;
        
        IF @id_materia IS NULL
        BEGIN
            SET @mensaje = 'Error: El código de materia ' + @codigo_materia + ' no existe en la base de datos.';
            RAISERROR(@mensaje, 16, 1);
            RETURN;
        END
        
        -- Verificar si ya está matriculado
        IF EXISTS (SELECT 1 FROM matriculas WHERE id_estudiante = @id_estudiante AND id_materia = @id_materia)
        BEGIN
            SET @mensaje = 'Error: El estudiante ya está matriculado en la materia ' + @codigo_materia + '.';
            RAISERROR(@mensaje, 16, 1);
            RETURN;
        END
        
        -- Realizar la matrícula
        INSERT INTO matriculas (id_estudiante, id_materia, fecha)
        VALUES (@id_estudiante, @id_materia, GETDATE());
        
        SET @mensaje = 'Matrícula exitosa: El estudiante con carnet ' + @carnet + ' ha sido matriculado en ' + @codigo_materia + '.';
        SET @exito = 1;
        
        -- Retornar resultado
        SELECT 
            @exito AS exito,
            @mensaje AS mensaje,
            @id_estudiante AS id_estudiante,
            @id_materia AS id_materia;
            
    END TRY
    BEGIN CATCH
        SET @mensaje = ERROR_MESSAGE();
        SET @exito = 0;
        
        SELECT 
            @exito AS exito,
            @mensaje AS mensaje,
            NULL AS id_estudiante,
            NULL AS id_materia;
    END CATCH
END;
GO

-- Procedimientos

CREATE PROCEDURE sp_obtener_materias_estudiante
    @carnet NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        m.codigo,
        m.nombre,
        'Prof. ' + 
        CASE 
            WHEN m.codigo = 'MAT101' THEN 'García'
            WHEN m.codigo = 'FIS101' THEN 'López'
            WHEN m.codigo = 'QUI101' THEN 'Rodríguez'
            WHEN m.codigo = 'PRO101' THEN 'Martínez'
            WHEN m.codigo = 'ING101' THEN 'Smith'
            WHEN m.codigo = 'HIS101' THEN 'González'
            WHEN m.codigo = 'LIT101' THEN 'Pérez'
            WHEN m.codigo = 'BIO101' THEN 'Torres'
            WHEN m.codigo = 'CAL101' THEN 'Herrera'
            WHEN m.codigo = 'EST101' THEN 'Vega'
            ELSE 'Docente'
        END AS profesor,
        mat.fecha
    FROM estudiantes e
    INNER JOIN matriculas mat ON e.id = mat.id_estudiante
    INNER JOIN materias m ON mat.id_materia = m.id
    WHERE e.carnet = @carnet
    ORDER BY mat.fecha DESC;
END;
GO

-- Procedimientos

CREATE PROCEDURE sp_obtener_materias_disponibles
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        codigo,
        nombre
    FROM materias
    ORDER BY nombre;
END;
GO

-- Vistas

-- Vista para ver todas las matrículas con información completa
CREATE VIEW v_matriculas_completas AS
SELECT 
    e.carnet,
    e.nombre_completo,
    m.codigo AS codigo_materia,
    m.nombre AS nombre_materia,
    mat.fecha AS fecha_matricula
FROM matriculas mat
INNER JOIN estudiantes e ON mat.id_estudiante = e.id
INNER JOIN materias m ON mat.id_materia = m.id;

-- Índices

-- Índices para mejorar el rendimiento
CREATE INDEX IX_estudiantes_carnet ON estudiantes(carnet);
CREATE INDEX IX_materias_codigo ON materias(codigo);
CREATE INDEX IX_matriculas_estudiante ON matriculas(id_estudiante);
CREATE INDEX IX_matriculas_materia ON matriculas(id_materia);
CREATE INDEX IX_matriculas_fecha ON matriculas(fecha);
-- Mensajes

PRINT '=============================================';
PRINT 'BASE DE DATOS SISTEMA DE MATRÍCULAS CREADA';
PRINT '=============================================';
PRINT 'Base de datos: SistemaMatriculas';
PRINT 'Tablas creadas: estudiantes, materias, matriculas';
PRINT 'Procedimientos almacenados:';
PRINT '  - sp_matricula_estudiantes';
PRINT '  - sp_obtener_materias_estudiante';
PRINT '  - sp_obtener_materias_disponibles';
PRINT 'Datos de prueba insertados';
PRINT '============================================='; 