# Core Systems Documentation

## RTS Camera Controller (`RTSCamera`)
Path: `scenes/camera/rts_camera.tscn`

A fully decoupled, modular RTS Camera node designed for a deterministic game environment.

### Features
- Keyboard Panning (WASD default mapped to `camera_forward`, `camera_backward`, `camera_left`, `camera_right`)
- Edge Panning via mouse with configurable margins and speed
- Zooming via Mouse Wheel (mapped to `camera_zoom_in` and `camera_zoom_out`)
- Built-in `Elevation` Node to safely change camera pitch/angles without breaking translational panning logic.

### Future Work (TODOs)
- Terrain Adaptation (Height adjustment based on ground raycasts)
- Target Follow Logic (Track a specific unit or point of interest)

### Input Actions
Configure the following in your `project.godot`:
- `camera_forward`
- `camera_backward`
- `camera_left`
- `camera_right`
- `camera_zoom_in`
- `camera_zoom_out`
