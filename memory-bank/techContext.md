# Technical Context: Depths of the Bastard God

## Technology Stack (Epic Mobile Campaign)

### Core Engine
- **Godot 4.4.1**: Primary game engine for epic 50+ hour mobile experience
  - Location: `Godot_v4.4.1-stable_linux.x86_64`
  - Platform: Linux (Ubuntu-based)
  - Architecture: x86_64
  - Mobile Export: Android APK generation for epic campaigns

### Development Environment
- **OS**: Linux 6.8.0-60-generic
- **Shell**: /usr/bin/zsh
- **Workspace**: `/home/island/Documentos/Depths%20of%20the%20Bastard%20God`
- **Project Directory**: `dotbg/` (Godot project root)

### Target Platform (Epic Mobile Focus)
- **Primary**: Android (API level 21+) for 50-70 hour campaigns
- **Orientation**: **Landscape (1920x1080)** for epic mobile gaming
- **Input**: Touch controls ONLY (virtual joystick, touch buttons)
- **Session Length**: Optimized for 60+ minute continuous mobile sessions
- **Future**: Desktop support planned for later phases (NOT until requested)

### Programming Languages (Epic Scale)
- **GDScript**: Primary scripting language for all epic systems
- **C#**: Potential for performance-critical epic systems
- **GLSL**: Custom shaders for three-act visual effects and UI corruption
- **JSON**: Configuration for three acts, sanity system, save corruption

### Project Management (Epic Scope)
- **TaskMaster AI**: Task tracking for 40-50 epic system tasks
- **Memory Bank**: Documentation for 50+ hour development context
- **Git**: Version control for epic codebase management

## Epic Mobile Architecture

### Three-Act Technical Structure
```gdscript
# Act-specific technical requirements
ActManager
├── Act1_TechnicalSpecs (city generation, urban rendering)
├── Act2_TechnicalSpecs (water physics, organic rendering)
└── Act3_TechnicalSpecs (impossible geometry, reality distortion)

# Each act requires distinct:
- Rendering pipelines
- Physics rules
- Generation algorithms
- Performance profiles
```

### UI Corruption System Architecture
```gdscript
# Technical implementation for interface lies
UICorruption (Autoload)
├── HealthBarCorruption (false health display)
├── InventoryCorruption (item description lies)
├── MapCorruption (false room layouts)
├── MenuCorruption (fake options, broken navigation)
├── TextCorruption (randomized descriptions)
└── SaveUICorruption (fake save confirmations)

# Corruption levels affect rendering:
enum CorruptionLevel {
    NONE,        # 75-100% sanity - normal rendering
    SUBTLE,      # 50-74% sanity - minor visual lies
    OBVIOUS,     # 25-49% sanity - major interface distortion
    COMPLETE     # 0-24% sanity - complete UI unreliability
}
```

### Save System Corruption Architecture
```gdscript
# Dual save system: real data + fake corruption
SaveCorruption (Autoload)
├── RealSaveManager (actual data persistence)
├── FakeSaveManager (corruption simulation)
├── ProgressLies (false completion states)
├── RollbackSimulation (fake progress loss)
└── SaveFileRenaming (cosmetic file name changes)

# Technical requirements:
- Real saves NEVER corrupted (data integrity)
- Fake corruption affects UI only
- Mobile storage optimization for 50+ hour saves
- Android app lifecycle handling
```

## Mobile Development Configuration (Epic Scale)

### Android Target Settings (Epic Campaign)
- **Minimum SDK**: API level 21 (Android 5.0)
- **Target SDK**: Latest stable Android API
- **Architecture**: ARM64-v8a (primary), ARMv7 (compatibility)
- **Permissions**: Storage (epic save files), vibration, network (future)
- **Storage Requirements**: Optimized for 50+ hour save data

### Mobile Rendering (Three-Act Optimization)
- **Renderer**: Mobile (optimized for three distinct visual styles)
- **Compression**: ETC2/ASTC for textures across all acts
- **MSAA**: 2x for performance balance across epic content
- **VSync**: Enabled for smooth frame pacing during extended sessions
- **Act-Specific Shaders**: Optimized rendering per act theme

### Performance Targets (Epic Mobile Campaign)
- **Frame Rate**: 60 FPS on mid-range Android devices across all three acts
- **Memory**: Under 1.5GB RAM usage for 50+ hour save files
- **Generation Time**: Under 2 seconds per room across three distinct acts
- **Touch Latency**: Under 50ms response time despite UI corruption
- **Battery**: Optimized for 2+ hour continuous play sessions
- **Campaign Length**: 50-70 hours total gameplay time
- **Save File Size**: Optimized mobile storage for epic campaigns

## Input System Architecture (Epic Complexity)

### Touch Controls (Sanity-Aware)
- **Virtual Joystick**: Left side movement control (may lie at low sanity)
- **Touch Buttons**: Right side action controls (corruption-capable)
- **Gesture Recognition**: Swipe patterns for special abilities
- **Haptic Feedback**: Tactile response (may be false at low sanity)
- **Context-Sensitive**: Interact buttons (may appear when nothing there)

### Input Mapping (Epic Systems)
```gdscript
# Mobile touch input actions (no keyboard/mouse until desktop requested)
move_up, move_down, move_left, move_right  # Virtual joystick (sanity-aware)
attack                                      # Touch button (may hallucinate)
dodge                                       # Touch button (i-frames may lie)
interact                                    # Context-sensitive (may be false)
inventory                                   # Touch button (items may lie)
pause                                       # Touch button (may not work)
sanity_check                               # Debug: reveal reality vs. corruption
```

### Touch Responsiveness (Reality-Aware)
- **Input Polling**: High frequency for smooth response
- **Touch Areas**: Generous hit boxes for finger accuracy
- **Visual Feedback**: Immediate response (may be false at low sanity)
- **Dead Zones**: Prevent accidental inputs
- **Corruption Handling**: Touch events may be filtered by sanity state

## Mobile Optimization Strategy (Epic Scale)

### Memory Management (50+ Hour Campaigns)
- **Object Pooling**: Reuse objects across epic campaign length
- **Asset Streaming**: Load/unload content across three acts
- **Texture Compression**: Mobile-optimized formats for three visual styles
- **Audio Compression**: Efficient sound files for massive soundtrack
- **Save Data Optimization**: Efficient storage for 50+ hour progress
- **Act Transition**: Memory cleanup between major act changes

### CPU Optimization (Epic Performance)
- **Efficient Algorithms**: Mobile-optimized procedural generation per act
- **Background Processing**: Minimize work during active epic gameplay
- **State Machines**: Efficient AI and game logic across three acts
- **Batch Operations**: Group similar operations for mobile efficiency
- **Sanity Processing**: Efficient reality distortion calculations
- **UI Corruption**: Lightweight interface manipulation

### GPU Optimization (Three-Act Rendering)
- **LOD System**: Level-of-detail for distant objects per act
- **Culling**: Frustum and occlusion culling across three visual styles
- **Particle Limits**: Reasonable particle counts for extended sessions
- **Shader Efficiency**: Mobile-optimized shaders per act theme
- **Corruption Effects**: Efficient UI distortion rendering
- **Act-Specific Optimization**: Tailored rendering per act requirements

### Battery Optimization (Epic Sessions)
- **Frame Rate Scaling**: Adaptive performance for 60+ minute sessions
- **Background Behavior**: Minimal processing when app inactive
- **Efficient Rendering**: Avoid unnecessary draw calls across epic content
- **Sleep States**: Proper handling of device sleep during long sessions
- **Thermal Management**: Reduce performance if device overheating
- **Session Length Optimization**: Battery-conscious epic gaming

## Development Tools (Epic Scale)

### Mobile Testing (Epic Campaign)
- **Android Debug Bridge (ADB)**: Device debugging for epic systems
- **Godot Remote Debug**: Real-time debugging for complex systems
- **Performance Profiler**: Mobile-specific monitoring for 50+ hour campaigns
- **Device Testing**: Multiple Android devices for epic compatibility
- **Save Corruption Testing**: Validate fake corruption doesn't break real saves
- **Extended Session Testing**: 60+ minute mobile session validation

### Build Pipeline (Epic Scope)
- **Export Templates**: Android export templates for epic content
- **Signing**: Android APK signing for epic game distribution
- **Optimization**: Build-time optimizations for three-act mobile game
- **Testing**: Automated testing for epic campaign systems
- **Act-Specific Builds**: Optimized builds per development phase

## File Structure (Epic Organization)

### Mobile-Optimized Organization (Three-Act Structure)
```
dotbg/
├── project.godot              # Epic mobile-configured project
├── scenes/
│   ├── mobile_ui/            # Touch-optimized UI scenes (corruption-capable)
│   ├── player/               # Mobile player controller (sanity-aware)
│   ├── world/                # Mobile-optimized world scenes
│   │   ├── act1_city/        # The Descending City scenes
│   │   ├── act2_depths/      # The Drowning Depths scenes
│   │   └── act3_dream/       # The Dream Realm scenes
│   ├── corruption/           # UI corruption and reality distortion
│   └── bosses/               # Act-specific boss encounters
├── scripts/
│   ├── autoload/             # Global mobile systems (epic-aware)
│   │   ├── sanity_manager.gd     # Reality distortion controller
│   │   ├── ui_corruption.gd      # Interface manipulation
│   │   └── save_corruption.gd    # Fake save operations
│   ├── mobile/               # Mobile-specific scripts
│   ├── touch/                # Touch control systems (sanity-aware)
│   ├── optimization/         # Mobile performance scripts (epic scale)
│   ├── acts/                 # Act-specific systems
│   │   ├── act1_systems/     # City generation and mechanics
│   │   ├── act2_systems/     # Depths generation and water physics
│   │   └── act3_systems/     # Dream realm and reality distortion
│   └── corruption/           # Reality distortion implementations
├── assets/
│   ├── mobile_ui/            # Mobile UI assets (corruption variants)
│   ├── compressed/           # Mobile-compressed assets per act
│   ├── audio/                # Mobile-optimized audio (massive soundtrack)
│   ├── act1_assets/          # City-themed assets
│   ├── act2_assets/          # Depths-themed assets
│   ├── act3_assets/          # Dream-themed assets
│   └── corruption_assets/    # UI corruption and distortion assets
└── resources/
    ├── mobile_themes/        # Mobile UI themes (corruption-aware)
    ├── touch_controls/       # Touch control configurations
    ├── act_configs/          # Act-specific configuration files
    ├── sanity_configs/       # Sanity system configuration
    ├── corruption_configs/   # UI corruption settings
    └── save_configs/         # Save system configuration (real + fake)
```

## Dependencies (Epic Scale)

### Engine Dependencies (Epic Campaign)
- **Godot 4.4.1**: Core engine with mobile export for epic content
- **Android SDK**: For Android development and epic game export
- **Java JDK**: Required for Android builds of epic scope

### External Libraries (Epic Scope)
- **None currently**: Keeping dependencies minimal for epic mobile game
- **Future considerations**: Native Android plugins for epic features if needed
- **Potential additions**: Advanced audio processing for massive soundtrack

### Asset Pipeline (Epic Content)
- **Texture Tools**: For mobile texture compression across three acts
- **Audio Tools**: For mobile audio optimization (massive soundtrack)
- **Build Tools**: For automated mobile builds of epic content
- **Compression Tools**: For epic save file optimization

## Platform-Specific Considerations (Epic Mobile)

### Android Lifecycle (Epic Sessions)
- **App Pause/Resume**: Proper handling during epic gaming sessions
- **Memory Warnings**: Response to low memory during 50+ hour campaigns
- **Background Processing**: Minimal activity when backgrounded
- **Notification Handling**: Integration during long gaming sessions
- **Save Protection**: Ensure epic progress isn't lost during interruptions

### Touch Interface Design (Epic Complexity)
- **Finger-Friendly**: Minimum 44dp touch targets for complex systems
- **Accessibility**: Support for various hand sizes during extended play
- **Orientation**: **Landscape-optimized layout** for epic mobile gaming
- **Visual Feedback**: Clear indication of touch interactions (may lie at low sanity)
- **Corruption-Aware**: Interface elements that can display false information

### Performance Scaling (Epic Campaign)
- **Device Detection**: Automatic quality adjustment for epic content
- **Graceful Degradation**: Reduced features on lower-end devices
- **User Settings**: Manual performance adjustment for epic sessions
- **Thermal Management**: Reduce performance if device overheating during long play
- **Act-Specific Scaling**: Different performance profiles per act

## Security Considerations (Epic Scale)

### Mobile Security (Epic Campaign)
- **Save Data Protection**: Secure local storage for 50+ hour progress
- **Input Validation**: Prevent malicious input across complex systems
- **Asset Protection**: Basic asset security for epic content
- **Privacy**: Minimal data collection during epic sessions
- **Save Integrity**: Protect real saves from corruption system

### Android Permissions (Epic Scope)
- **Storage**: For epic save files and generated content
- **Vibration**: For haptic feedback across epic systems
- **Network**: For future online features (optional)
- **Minimal Permissions**: Request only what's necessary for epic experience

## Future Platform Support (Epic Expansion)

### Desktop Expansion (ONLY WHEN REQUESTED)
- **Input Adaptation**: Keyboard/mouse support addition to epic systems
- **UI Scaling**: Desktop-appropriate interface scaling for epic content
- **Performance Scaling**: Desktop hardware utilization for epic campaigns
- **Feature Parity**: Maintain epic feature consistency across platforms
- **Cross-Platform Saves**: Epic campaign progress across devices

## Technical Challenges (Epic Scope)

### UI Corruption Engineering
- **Interface Lies**: Making false information feel supernatural
- **Mobile Touch**: Corruption that doesn't break touch interface
- **Performance**: Lightweight corruption effects for mobile
- **Believability**: Lies that feel real until revealed

### Save System Complexity
- **Dual Architecture**: Real saves + fake corruption simulation
- **Data Integrity**: Never corrupt actual player progress
- **Mobile Storage**: Efficient storage for epic campaign data
- **Android Lifecycle**: Proper save handling during app interruptions

### Three-Act Performance
- **Rendering Pipelines**: Optimized visuals per act theme
- **Memory Management**: Efficient transitions between acts
- **Asset Streaming**: Loading/unloading act-specific content
- **Mobile Constraints**: Epic scope within mobile hardware limits

### Epic Campaign Balancing
- **Engagement**: Maintaining interest across 50+ hours
- **Performance**: Stable experience throughout epic length
- **Progression**: Meaningful advancement across three acts
- **Mobile Sessions**: Optimized for 60+ minute mobile gaming 