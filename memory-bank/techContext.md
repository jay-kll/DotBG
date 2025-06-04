# Technical Context: Depths of the Bastard God

## Technology Stack

### Core Engine
- **Godot 4.4.1**: Primary game engine
  - Location: `Godot_v4.4.1-stable_linux.x86_64`
  - Platform: Linux (Ubuntu-based)
  - Architecture: x86_64
  - Mobile Export: Android APK generation

### Development Environment
- **OS**: Linux 6.8.0-60-generic
- **Shell**: /usr/bin/zsh
- **Workspace**: `/home/island/Documentos/Depths%20of%20the%20Bastard%20God`
- **Project Directory**: `dotbg/` (Godot project root)

### Target Platform
- **Primary**: Android (API level 21+)
- **Orientation**: Portrait (1080x1920)
- **Input**: Touch controls (virtual joystick, touch buttons)
- **Future**: Desktop support planned for later phases

### Programming Languages
- **GDScript**: Primary scripting language for Godot
- **C#**: Potential for performance-critical systems
- **GLSL**: Custom shaders for visual effects

### Project Management
- **TaskMaster AI**: Task tracking and project management
- **Memory Bank**: Documentation and context preservation
- **Git**: Version control (implied)

## Mobile Development Configuration

### Android Target Settings
- **Minimum SDK**: API level 21 (Android 5.0)
- **Target SDK**: Latest stable Android API
- **Architecture**: ARM64-v8a (primary), ARMv7 (compatibility)
- **Permissions**: Storage, vibration, network (for future features)

### Mobile Rendering
- **Renderer**: Mobile (optimized for mobile GPUs)
- **Compression**: ETC2/ASTC for textures
- **MSAA**: 2x for performance balance
- **VSync**: Enabled for smooth frame pacing

### Performance Targets
- **Frame Rate**: 60 FPS on mid-range Android devices
- **Memory**: Under 1.5GB RAM usage
- **Generation Time**: Under 1 second per room
- **Touch Latency**: Under 50ms response time
- **Battery**: Optimized for 2+ hour sessions

## Input System Architecture

### Touch Controls
- **Virtual Joystick**: Left side movement control
- **Touch Buttons**: Right side action controls
- **Gesture Recognition**: Swipe patterns for special abilities
- **Haptic Feedback**: Tactile response for important actions

### Input Mapping
```gdscript
# Mobile touch input actions (no keyboard/mouse)
move_up, move_down, move_left, move_right  # Virtual joystick
attack                                      # Touch button
dodge                                       # Touch button  
interact                                    # Context-sensitive
inventory                                   # Touch button
pause                                       # Touch button
```

### Touch Responsiveness
- **Input Polling**: High frequency for smooth response
- **Touch Areas**: Generous hit boxes for finger accuracy
- **Visual Feedback**: Immediate response to touch events
- **Dead Zones**: Prevent accidental inputs

## Mobile Optimization Strategy

### Memory Management
- **Object Pooling**: Reuse frequently created objects
- **Asset Streaming**: Load/unload content as needed
- **Texture Compression**: Mobile-optimized formats
- **Audio Compression**: Efficient sound file formats

### CPU Optimization
- **Efficient Algorithms**: Mobile-optimized procedural generation
- **Background Processing**: Minimize work during active gameplay
- **State Machines**: Efficient AI and game logic
- **Batch Operations**: Group similar operations together

### GPU Optimization
- **LOD System**: Level-of-detail for distant objects
- **Culling**: Frustum and occlusion culling
- **Particle Limits**: Reasonable particle counts
- **Shader Efficiency**: Mobile-optimized shaders

### Battery Optimization
- **Frame Rate Scaling**: Adaptive performance based on battery
- **Background Behavior**: Minimal processing when app inactive
- **Efficient Rendering**: Avoid unnecessary draw calls
- **Sleep States**: Proper handling of device sleep

## Development Tools

### Mobile Testing
- **Android Debug Bridge (ADB)**: Device debugging
- **Godot Remote Debug**: Real-time debugging on device
- **Performance Profiler**: Mobile-specific performance monitoring
- **Device Testing**: Multiple Android devices for compatibility

### Build Pipeline
- **Export Templates**: Android export templates for Godot
- **Signing**: Android APK signing for distribution
- **Optimization**: Build-time optimizations for mobile
- **Testing**: Automated testing on target devices

## File Structure

### Mobile-Optimized Organization
```
dotbg/
├── project.godot              # Mobile-configured project
├── scenes/
│   ├── mobile_ui/            # Touch-optimized UI scenes
│   ├── player/               # Mobile player controller
│   └── world/                # Mobile-optimized world scenes
├── scripts/
│   ├── autoload/             # Global mobile systems
│   ├── mobile/               # Mobile-specific scripts
│   ├── touch/                # Touch control systems
│   └── optimization/         # Mobile performance scripts
├── assets/
│   ├── mobile_ui/            # Mobile UI assets
│   ├── compressed/           # Mobile-compressed assets
│   └── audio/                # Mobile-optimized audio
└── resources/
    ├── mobile_themes/        # Mobile UI themes
    └── touch_controls/       # Touch control configurations
```

## Dependencies

### Engine Dependencies
- **Godot 4.4.1**: Core engine with mobile export support
- **Android SDK**: For Android development and export
- **Java JDK**: Required for Android builds

### External Libraries
- **None currently**: Keeping dependencies minimal for mobile
- **Future considerations**: Native Android plugins if needed

### Asset Pipeline
- **Texture Tools**: For mobile texture compression
- **Audio Tools**: For mobile audio optimization
- **Build Tools**: For automated mobile builds

## Platform-Specific Considerations

### Android Lifecycle
- **App Pause/Resume**: Proper handling of app interruptions
- **Memory Warnings**: Response to low memory conditions
- **Background Processing**: Minimal activity when backgrounded
- **Notification Handling**: Integration with Android notifications

### Touch Interface Design
- **Finger-Friendly**: Minimum 44dp touch targets
- **Accessibility**: Support for various hand sizes
- **Orientation**: Portrait-optimized layout
- **Visual Feedback**: Clear indication of touch interactions

### Performance Scaling
- **Device Detection**: Automatic quality adjustment based on device
- **Graceful Degradation**: Reduced features on lower-end devices
- **User Settings**: Manual performance adjustment options
- **Thermal Management**: Reduce performance if device overheating

## Security Considerations

### Mobile Security
- **Save Data Protection**: Secure local storage
- **Input Validation**: Prevent malicious input
- **Asset Protection**: Basic asset security
- **Privacy**: Minimal data collection

### Android Permissions
- **Storage**: For save files and generated content
- **Vibration**: For haptic feedback
- **Network**: For future online features (optional)
- **Minimal Permissions**: Request only what's necessary

## Future Platform Support

### Desktop Expansion
- **Input Adaptation**: Keyboard/mouse support addition
- **UI Scaling**: Desktop-appropriate interface scaling
- **Performance Scaling**: Desktop hardware utilization
- **Feature Parity**: Maintain feature consistency across platforms

### Cross-Platform Considerations
- **Shared Codebase**: Platform-agnostic core systems
- **Platform Abstraction**: Input and UI abstraction layers
- **Asset Compatibility**: Cross-platform asset formats
- **Save Compatibility**: Cross-platform save file format

## Development Workflow

### Mobile-First Approach
1. **Design for Touch**: Touch controls as primary input
2. **Mobile Performance**: Optimize for mobile constraints first
3. **Test on Device**: Regular testing on actual Android devices
4. **Iterate Quickly**: Fast iteration cycle for touch control refinement

### Quality Assurance
- **Device Testing**: Multiple Android devices and versions
- **Performance Testing**: Frame rate and memory monitoring
- **Touch Testing**: Accuracy and responsiveness validation
- **Battery Testing**: Extended play session monitoring

### Deployment Pipeline
- **Development Builds**: Quick iteration builds for testing
- **Release Builds**: Optimized builds for distribution
- **Beta Testing**: External testing on various devices
- **Store Deployment**: Google Play Store preparation

## Project Structure

### Root Directory
```
/home/island/Documentos/Depths of the Bastard God/
├── dotbg/                    # Godot project root
├── design.md                 # Game design document
├── roadmap.md               # Development roadmap
├── story_design.md          # Narrative design
├── memory-bank/             # Documentation system
├── .taskmaster/             # TaskMaster configuration
└── Godot_v4.4.1-stable_linux.x86_64  # Engine executable
```

### Godot Project Structure (`dotbg/`)
```
dotbg/
├── project.godot           # Project configuration
├── main.tscn              # Main scene
├── icon.png               # Project icon
├── .editorconfig          # Editor settings
├── .godot/                # Engine cache (ignored)
├── scripts/               # GDScript files
│   └── autoload/          # Global scripts
├── scenes/                # Scene files
├── assets/                # Art and audio assets
└── resources/             # Game data resources
```

## Engine Configuration

### Project Settings (project.godot)
- **Application Name**: "Depths of the Bastard God"
- **Main Scene**: main.tscn
- **Target FPS**: 60
- **Physics**: 2D physics enabled
- **Rendering**: Forward+ renderer

### Input Mappings
- Movement: WASD keys
- Attack: Mouse buttons
- Dodge: Spacebar
- Interact: E key
- Menu: Escape key

### Physics Layers
- Player: Layer 1
- Enemies: Layer 2
- Environment: Layer 3
- Projectiles: Layer 4
- Triggers: Layer 5

### Autoload Scripts
1. **GameManager**: `scripts/autoload/game_manager.gd`
2. **PlayerStats**: `scripts/autoload/player_stats.gd`
3. **EventBus**: `scripts/autoload/event_bus.gd`

## Development Tools

### TaskMaster Configuration
- **Version**: 0.16.1
- **Config**: `.taskmaster/config.json`
- **Templates**: `.taskmaster/templates/`
- **Documentation**: `.taskmaster/docs/`
- **Reports**: `.taskmaster/reports/`
- **Tasks**: `.taskmaster/tasks/`

### Memory Bank System
- **Location**: `memory-bank/`
- **Core Files**: 
  - projectbrief.md
  - productContext.md
  - activeContext.md
  - systemPatterns.md
  - techContext.md
  - progress.md

## Technical Constraints

### Performance Requirements
- **Target FPS**: 60 FPS minimum
- **Memory Usage**: Under 2GB RAM
- **Generation Time**: Under 2 seconds per room
- **Loading Time**: Under 5 seconds for level transitions

### Hardware Targets
- **Minimum**: 
  - CPU: Dual-core 2.5GHz
  - RAM: 4GB
  - GPU: Integrated graphics
  - Storage: 2GB available space

- **Recommended**:
  - CPU: Quad-core 3.0GHz
  - RAM: 8GB
  - GPU: Dedicated graphics card
  - Storage: 4GB available space (SSD preferred)

### Platform Considerations
- **Primary**: Linux (development platform)
- **Target Platforms**: Windows, macOS, Linux
- **Potential**: Steam Deck compatibility
- **Future**: Mobile platforms (Android/iOS)

## Procedural Generation Technology

### Core Libraries
- **Godot's FastNoiseLite**: Noise generation
- **Custom Algorithms**: Specialized generation systems
- **Shader-based Generation**: GPU-accelerated processing

### Generation Systems
1. **Texture Generation**
   - Noise-based algorithms
   - Color palette systems
   - Pattern synthesis
   - Real-time generation

2. **Audio Generation**
   - Procedural music composition
   - Dynamic sound effects
   - Spatial audio processing
   - Sanity-based distortion

3. **Geometry Generation**
   - Room layout algorithms
   - Mesh generation
   - Collision shape creation
   - LOD system integration

4. **Content Generation**
   - Enemy behavior trees
   - Item stat generation
   - Narrative element creation
   - Quest objective synthesis

## Data Management

### File Formats
- **Scenes**: .tscn (Godot scene format)
- **Scripts**: .gd (GDScript)
- **Resources**: .tres (Godot resource format)
- **Configuration**: .json (JSON data)
- **Assets**: .png, .ogg, .wav (standard formats)

### Save System
- **Format**: JSON-based save files
- **Location**: User data directory
- **Encryption**: Optional for sensitive data
- **Compression**: For large save files
- **Versioning**: Migration system for updates

### Resource Management
- **Caching**: Generated assets cached for reuse
- **Streaming**: Dynamic loading/unloading
- **Compression**: Asset compression for storage
- **Validation**: Content integrity checking

## Performance Optimization

### Rendering Optimization
- **Culling**: Frustum and occlusion culling
- **LOD**: Level-of-detail for distant objects
- **Batching**: Draw call optimization
- **Shaders**: Efficient GPU utilization

### Memory Management
- **Object Pooling**: Reuse expensive objects
- **Garbage Collection**: Minimize allocations
- **Asset Streaming**: Dynamic memory usage
- **Cache Management**: Intelligent caching strategies

### CPU Optimization
- **Multithreading**: Background generation
- **Profiling**: Performance monitoring
- **Algorithm Efficiency**: Optimized generation
- **Update Frequency**: Adaptive update rates

## Development Workflow

### Version Control
- **System**: Git (recommended)
- **Ignore Patterns**: .godot/, .import/, .tmp/
- **Branching**: Feature-based development
- **Commits**: Atomic, descriptive commits

### Testing Strategy
- **Unit Tests**: Individual system testing
- **Integration Tests**: Cross-system validation
- **Performance Tests**: Benchmark validation
- **Procedural Tests**: Generation validation

### Build Process
- **Export Templates**: Godot export system
- **Platform Builds**: Automated build pipeline
- **Asset Processing**: Optimization pipeline
- **Distribution**: Package management

## Security Considerations

### Save File Security
- **Validation**: Prevent save file tampering
- **Encryption**: Sensitive data protection
- **Backup**: Automatic save backups
- **Recovery**: Corrupted save handling

### Code Security
- **Input Validation**: Prevent injection attacks
- **Resource Limits**: Prevent resource exhaustion
- **Error Handling**: Graceful failure modes
- **Logging**: Security event tracking

## Accessibility Features

### Visual Accessibility
- **Colorblind Support**: Alternative color schemes
- **High Contrast**: Enhanced visibility options
- **Text Scaling**: Adjustable font sizes
- **Visual Indicators**: Audio cue alternatives

### Audio Accessibility
- **Subtitles**: Text alternatives for audio
- **Visual Cues**: Audio event visualization
- **Volume Controls**: Granular audio mixing
- **Frequency Adjustment**: Hearing aid compatibility

### Input Accessibility
- **Remappable Controls**: Custom key bindings
- **Hold/Toggle Options**: Accessibility alternatives
- **Timing Adjustments**: Reaction time accommodation
- **One-handed Play**: Alternative control schemes

## Future Technology Considerations

### Potential Upgrades
- **Godot 4.5+**: Engine updates and new features
- **Vulkan Renderer**: Advanced graphics capabilities
- **C# Integration**: Performance-critical systems
- **Plugin System**: Modding support

### Scalability Planning
- **Cloud Saves**: Cross-platform progression
- **Multiplayer**: Potential co-op features
- **Streaming**: Content delivery systems
- **Analytics**: Player behavior tracking 