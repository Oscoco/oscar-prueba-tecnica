<?php

namespace App\Livewire;

use Livewire\Component;
use App\Services\MatriculaService;

class MatriculaComponent extends Component
{
    public $carnet = '';
    public $codigo_materia = '';
    public $mensajeExito = '';
    public $mensajeError = '';
    public $materiasMatriculadas = [];
    public $materiasDisponibles = [];
    
    protected $matriculaService;
    
    public function boot(MatriculaService $matriculaService)
    {
        $this->matriculaService = $matriculaService;
    }
    
    public function mount()
    {
        $this->cargarMateriasDisponibles();
    }
    
    public function cargarMateriasDisponibles()
    {
        $materias = $this->matriculaService->obtenerMateriasDisponibles();
        $this->materiasDisponibles = collect($materias)->pluck('nombre', 'codigo')->toArray();
    }

    protected $rules = [
        'carnet' => 'required|min:7|max:10',
        'codigo_materia' => 'required'
    ];

    protected $messages = [
        'carnet.required' => 'El carnet es obligatorio',
        'carnet.min' => 'El carnet debe tener al menos 7 caracteres',
        'carnet.max' => 'El carnet no puede tener más de 10 caracteres',
        'codigo_materia.required' => 'Debe seleccionar una materia'
    ];

    public function updated($propertyName)
    {
        $this->validateOnly($propertyName);
    }

    public function buscarMaterias()
    {
        $this->validate([
            'carnet' => 'required|min:7|max:10'
        ]);

        try {
            $materias = $this->matriculaService->obtenerMateriasEstudiante($this->carnet);
            
            if (!empty($materias)) {
                $this->materiasMatriculadas = $materias;
                $this->mensajeExito = 'Materias encontradas para el carnet: ' . $this->carnet;
                $this->mensajeError = '';
            } else {
                $this->materiasMatriculadas = [];
                $this->mensajeError = 'No se encontraron materias para el carnet: ' . $this->carnet;
                $this->mensajeExito = '';
            }
            
        } catch (\Exception $e) {
            $this->mensajeError = 'Error al buscar las materias. Por favor, inténtalo de nuevo.';
            $this->mensajeExito = '';
        }
    }

    public function matricularMateria()
    {
        $this->validate([
            'carnet' => 'required|min:7|max:10',
            'codigo_materia' => 'required'
        ]);

        try {
            $resultado = $this->matriculaService->matricularEstudiante($this->carnet, $this->codigo_materia);
            
            if ($resultado->exito) {
                $this->mensajeExito = $resultado->mensaje;
                $this->mensajeError = '';
                $this->codigo_materia = '';
                $this->buscarMaterias();
            } else {
                $this->mensajeError = $resultado->mensaje;
                $this->mensajeExito = '';
            }
            
        } catch (\Exception $e) {
            $this->mensajeError = 'Error al matricular la materia. Por favor, inténtalo de nuevo.';
            $this->mensajeExito = '';
        }
    }

    public function render()
    {
        return view('livewire.matricula-component');
    }
}
