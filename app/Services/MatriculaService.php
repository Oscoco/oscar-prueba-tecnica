<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

class MatriculaService
{
    public function matricularEstudiante($carnet, $codigoMateria)
    {
        try {
            $result = DB::select('EXEC sp_matricula_estudiantes ?, ?', [$carnet, $codigoMateria]);
            return $result[0];
        } catch (\Exception $e) {
            return (object) [
                'exito' => false,
                'mensaje' => $e->getMessage(),
                'id_estudiante' => null,
                'id_materia' => null
            ];
        }
    }
    
    public function obtenerMateriasEstudiante($carnet)
    {
        try {
            return DB::select('EXEC sp_obtener_materias_estudiante ?', [$carnet]);
        } catch (\Exception $e) {
            return [];
        }
    }
    
    public function obtenerMateriasDisponibles()
    {
        try {
            return DB::select('EXEC sp_obtener_materias_disponibles');
        } catch (\Exception $e) {
            return [];
        }
    }
} 