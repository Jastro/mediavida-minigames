# MediaVida Minigames

Colección de minijuegos en Godot 4.5 - Open Source y extensible por la comunidad.

## Características Principales

- **Sistema de minijuegos modular** - Añade fácilmente nuevos juegos
- **Tres niveles de dificultad** - Fácil, Normal, Difícil
- **Sistema de estadísticas** - Records personales y tasas de victoria
- **Interfaz intuitiva** - Menú principal con navegación sencilla
- **Detección automática** - Los minijuegos se cargan automáticamente
- **Experiencia completa** - Juega todos los minijuegos en una sesión

## Estructura del Proyecto

```
mediavida-minigames/
├── GameManager.gd              # Sistema principal (Singleton)
├── minigames/                  # Carpeta de minijuegos
│   ├── ClickTheTarget.tscn     # Minijuego de ejemplo
│   └── MinigameTemplate.gd     # Plantilla base para desarrolladores
├── scenes/                     # Escenas principales
│   ├── MainMenu.tscn           # Menú principal
│   ├── MinigamesList.tscn      # Lista de minijuegos disponibles
│   └── GameComplete.tscn       # Pantalla de completado
├── scenes/ui/                  # Componentes de interfaz
│   └── ScorePopup.tscn         # Popup animado de puntuación
└── audio/sfx/                  # Efectos de sonido
```

## Minijuego Incluido: "Click the Target"

**Objetivo**: Conseguir 100+ puntos en 10 segundos

### Mecánicas:
- **Targets pequeños** (50x50px) aparecen aleatoriamente
- **Duración**: 1.5 segundos en pantalla (ajustado por dificultad)
- **Puntuación**: 10 puntos base + bonus por rapidez
- **Penalización**: -5 puntos por target perdido
- **Múltiples targets**: Hasta 3 simultáneos para mayor desafío
- **Victoria**: 100+ puntos al final del tiempo

### Dificultades:
- **Fácil**: Targets duran más tiempo, menos aparecen
- **Normal**: Velocidad balanceada
- **Difícil**: Targets muy rápidos, aparecen más frecuentemente

## Para Desarrolladores: Cómo Añadir tu Minijuego

### 1. Plantilla Base

```gdscript
extends Node2D

var score: int = 0
var is_game_active: bool = false
var time_left: float = 10.0  # Duración estándar

func _ready():
    # Instrucciones iniciales (2 segundos)
    show_instructions()
    await get_tree().create_timer(2.0).timeout
    start_minigame()

func start_minigame():
    is_game_active = true
    hide_instructions()

    # Timer principal del juego
    var timer = GameManager.start_countdown_timer(10.0, end_minigame)

func end_minigame():
    is_game_active = false

    # Definir condición de victoria (ej: score >= 100)
    var won = score >= 100

    # Mostrar resultado por 2-3 segundos
    show_result(won)
    await get_tree().create_timer(2.0).timeout

    # IMPORTANTE: Llamar al GameManager para finalizar
    GameManager.complete_minigame(won, score)
```

### 2. Funciones Esenciales del GameManager

```gdscript
# Sistema de puntuación
GameManager.complete_minigame(won: bool, score: int)  # OBLIGATORIO al terminar

# Herramientas de dificultad
GameManager.get_difficulty() -> Difficulty
GameManager.get_reaction_time() -> float  # Tiempo de reacción (1.2-2.5s)
GameManager.get_spawn_rate() -> float     # Multiplicador de aparición (0.7-1.4)
GameManager.get_difficulty_multiplier() -> float  # Bonus puntos (0.8-1.5)

# Feedback visual
GameManager.show_score_popup(points: int, position: Vector2)
GameManager.screen_shake(intensity: float, duration: float)

# Audio
GameManager.play_success_sound()
GameManager.play_fail_sound()
GameManager.play_sound(path: String)

# Utilidades
GameManager.start_countdown_timer(duration: float, callback: Callable)
```

### 3. Requisitos Obligatorios

1. **Duración**: 10 segundos por minijuego
2. **Condición de victoria clara** (ej: puntuación mínima, objetivos completados)
3. **Adaptación a dificultad** usando las funciones del GameManager
4. **Llamada final**: `GameManager.complete_minigame(won, score)`
5. **UI no intrusiva**: Usa `mouse_filter = IGNORE` en elementos decorativos

### 4. Ejemplo Práctico: Sistema de Puntos

```gdscript
func hit_target(target_position: Vector2):
    var base_points = 10
    var time_bonus = calculate_time_bonus()  # 0-10 puntos extra
    var difficulty_bonus = GameManager.get_difficulty_multiplier()

    var total_points = int((base_points + time_bonus) * difficulty_bonus)
    score += total_points

    # Mostrar popup visual
    var popup = preload("res://scenes/ui/ScorePopup.tscn").instantiate()
    add_child(popup)
    popup.setup(total_points, target_position)
```

## Sistema de Sesiones

### Flujo del Juego:
1. **Menú Principal** → Seleccionar dificultad → Clic "JUGAR"
2. **Sesión Iniciada** → Jugar todos los minijuegos una vez (orden aleatorio)
3. **Pantalla de Completado** → Ver estadísticas → "Jugar de Nuevo" o "Menú"

### Estadísticas Persistentes:
- **Record Personal**: Mejor puntuación individual en cualquier minijuego
- **Tasa de Victoria**: % de minijuegos ganados de todos los tiempos
- **Partidas Totales**: Contador de minijuegos jugados

## Instalación y Configuración

1. **Abrir en Godot 4.5+**
2. **Ejecutar**: La escena principal es `MainMenu.tscn`
3. **Añadir minijuegos**: Coloca archivos `.tscn` en `minigames/`
4. **Audio**: Añade `success.ogg` y `fail.ogg` en `audio/sfx/`

## Diseño de UI

### Menú Principal:
- **Diseño vertical centralizado**
- **Botón JUGAR destacado** (naranja #fc8f22)
- **Navegación clara**: Minijuegos, Reset, Salir
- **Estadísticas visibles**: Record y % victorias
- **Selector de dificultad** en la parte inferior

### Consejos de Diseño:
- **Targets pequeños**: 50x50px máximo para mayor desafío
- **Márgenes amplios**: 150px mínimo para forzar movimiento del mouse
- **Feedback inmediato**: Popups de puntos, efectos visuales
- **Colores contrastantes**: Rojo/blanco para targets, verde/rojo para feedback

## Balanceo de Dificultad

| Dificultad | Tiempo Reacción | Velocidad Spawn | Bonus Puntos |
|------------|----------------|-----------------|--------------|
| **Fácil**  | 2.5 segundos   | 0.7x           | 0.8x         |
| **Normal** | 2.0 segundos   | 1.0x           | 1.0x         |
| **Difícil**| 1.2 segundos   | 1.4x           | 1.5x         |

## Contribuir

1. **Fork** el repositorio
2. **Desarrolla** tu minijuego siguiendo las pautas
3. **Testa** en las tres dificultades
4. **Pull Request** con descripción del juego
5. **Comparte** con la comunidad MediaVida

### Ideas para Minijuegos:
- **Reflejos**: Simon Says, Whack-a-Mole
- **Precisión**: Puntería, Dibujar líneas
- **Memoria**: Secuencias, Patrones
- **Velocidad**: Typing, Clicking
- **Lógica**: Puzzles rápidos, Math

## Licencia

**Open Source** - Contribuye libremente. Hecho para y por la comunidad MediaVida.