-- =============================================
-- PROCEDIMIENTOS ALMACENADOS PARA SISTEMA DE MATRÍCULAS
-- =============================================

USE SistemaMatriculas;
GO

-- =============================================
-- PROCEDIMIENTO PARA MATRICULAR ESTUDIANTES
-- =============================================

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

-- =============================================
-- PROCEDIMIENTO PARA OBTENER MATERIAS DE UN ESTUDIANTE
-- =============================================

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

-- =============================================
-- PROCEDIMIENTO PARA OBTENER TODAS LAS MATERIAS DISPONIBLES
-- =============================================

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

-- =============================================
-- MENSAJE DE CONFIRMACIÓN
-- =============================================

PRINT '=============================================';
PRINT 'PROCEDIMIENTOS ALMACENADOS CREADOS EXITOSAMENTE';
PRINT '=============================================';
PRINT 'Procedimientos creados:';
PRINT '  - sp_matricula_estudiantes';
PRINT '  - sp_obtener_materias_estudiante';
PRINT '  - sp_obtener_materias_disponibles';
PRINT '============================================='; 