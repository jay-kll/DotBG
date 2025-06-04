extends Node

class_name AssetGenerator

# Texture generation
const TEXTURE_SIZE := 16  # Base size for our pixel art
const NOISE_OCTAVES := 4
const NOISE_PERIOD := 20.0
const NOISE_PERSISTENCE := 0.8

var noise := FastNoiseLite.new()
var rng := RandomNumberGenerator.new()

func _init():
    noise.noise_type = FastNoiseLite.TYPE_PERLIN
    noise.seed = randi()
    noise.fractal_octaves = NOISE_OCTAVES
    noise.frequency = 1.0 / NOISE_PERIOD
    
# TEXTURE GENERATION
func generate_wall_texture() -> ImageTexture:
    var img := Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
    var dark_color := Globals.get_random_color("dark")
    var accent_color := Globals.get_random_color("accent")
    
    for y in TEXTURE_SIZE:
        for x in TEXTURE_SIZE:
            var nx := float(x) / TEXTURE_SIZE
            var ny := float(y) / TEXTURE_SIZE
            var noise_val := (noise.get_noise_2d(x * 2, y * 2) + 1) * 0.5
            
            # Mix colors based on noise
            var color := dark_color.lerp(accent_color, noise_val * 0.3)
            # Add some variation
            color = color.darkened(randf() * 0.2)
            img.set_pixel(x, y, color)
    
    return ImageTexture.create_from_image(img)

func generate_creature_sprite() -> ImageTexture:
    var img := Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
    var main_color := Globals.get_random_color("dark")
    var detail_color := Globals.get_random_color("accent")
    
    # Generate basic shape
    var center := Vector2(TEXTURE_SIZE/2, TEXTURE_SIZE/2)
    var radius := TEXTURE_SIZE/3
    
    for y in TEXTURE_SIZE:
        for x in TEXTURE_SIZE:
            var pos := Vector2(x, y)
            var dist := pos.distance_to(center)
            
            if dist < radius:
                # Basic creature body
                var noise_val := noise.get_noise_2d(x * 3, y * 3)
                var color := main_color
                if noise_val > 0.3:
                    color = detail_color
                img.set_pixel(x, y, color)
            else:
                # Transparent background
                img.set_pixel(x, y, Color(0, 0, 0, 0))
    
    # Add random details (eyes, spikes, etc.)
    add_creature_details(img, detail_color)
    
    return ImageTexture.create_from_image(img)

func add_creature_details(img: Image, detail_color: Color) -> void:
    # Add eyes
    var eye_positions := []
    var num_eyes := rng.randi_range(1, 4)
    
    for _i in num_eyes:
        var eye_x := rng.randi_range(TEXTURE_SIZE/3, 2*TEXTURE_SIZE/3)
        var eye_y := rng.randi_range(TEXTURE_SIZE/3, TEXTURE_SIZE/2)
        eye_positions.append(Vector2(eye_x, eye_y))
    
    for pos in eye_positions:
        img.set_pixel(pos.x, pos.y, detail_color)
        # Add glow around eyes
        for y in range(-1, 2):
            for x in range(-1, 2):
                var px := int(pos.x + x)
                var py := int(pos.y + y)
                if px >= 0 and px < TEXTURE_SIZE and py >= 0 and py < TEXTURE_SIZE:
                    var current_color := img.get_pixel(px, py)
                    if current_color.a > 0:  # If not transparent
                        img.set_pixel(px, py, current_color.lerp(detail_color, 0.3))

# SOUND GENERATION
func generate_sound_effect(type: String) -> AudioStreamWAV:
    var sample_rate := 44100
    var duration := 0.5  # seconds
    var samples := PackedFloat32Array()
    samples.resize(int(sample_rate * duration))
    
    match type:
        "hit":
            generate_hit_sound(samples, sample_rate)
        "pickup":
            generate_pickup_sound(samples, sample_rate)
        "door":
            generate_door_sound(samples, sample_rate)
        _:
            generate_generic_sound(samples, sample_rate)
    
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.stereo = false
    stream.data = samples
    
    return stream

func generate_hit_sound(samples: PackedFloat32Array, sample_rate: int) -> void:
    var frequency := 440.0  # Base frequency
    var decay := 10.0  # How quickly the sound fades
    
    for i in samples.size():
        var t := float(i) / sample_rate
        var amplitude := exp(-decay * t)
        samples[i] = amplitude * sin(TAU * frequency * t)
        # Add some noise for impact
        samples[i] += amplitude * 0.3 * randf()

func generate_pickup_sound(samples: PackedFloat32Array, sample_rate: int) -> void:
    var base_freq := 880.0
    var mod_freq := 20.0
    
    for i in samples.size():
        var t := float(i) / sample_rate
        var amplitude := exp(-5.0 * t)
        var freq := base_freq + 100.0 * sin(TAU * mod_freq * t)
        samples[i] = amplitude * sin(TAU * freq * t)

func generate_door_sound(samples: PackedFloat32Array, sample_rate: int) -> void:
    var frequency := 110.0
    var decay := 8.0
    
    for i in samples.size():
        var t := float(i) / sample_rate
        var amplitude := exp(-decay * t)
        samples[i] = amplitude * (
            0.5 * sin(TAU * frequency * t) +
            0.3 * sin(TAU * frequency * 2 * t) +
            0.2 * sin(TAU * frequency * 4 * t)
        )

func generate_generic_sound(samples: PackedFloat32Array, sample_rate: int) -> void:
    var frequency := rng.randf_range(220.0, 880.0)
    var decay := rng.randf_range(5.0, 15.0)
    
    for i in samples.size():
        var t := float(i) / sample_rate
        var amplitude := exp(-decay * t)
        samples[i] = amplitude * sin(TAU * frequency * t)

# MUSIC GENERATION
func generate_ambient_track(duration: float) -> AudioStreamWAV:
    var sample_rate := 44100
    var samples := PackedFloat32Array()
    samples.resize(int(sample_rate * duration))
    
    # Base drone frequency
    var base_freq := 55.0  # A1 note
    var harmonics := [1.0, 1.5, 2.0, 2.5, 3.0]  # Harmonic series
    
    for i in samples.size():
        var t := float(i) / sample_rate
        var sample := 0.0
        
        # Sum multiple harmonics
        for harmonic in harmonics:
            var freq := base_freq * harmonic
            var amplitude := 1.0 / harmonic  # Higher harmonics are quieter
            sample += amplitude * sin(TAU * freq * t)
        
        # Add slow modulation
        var mod := sin(TAU * 0.1 * t)
        sample *= 0.5 + 0.1 * mod
        
        # Add some noise for texture
        sample += 0.05 * randf()
        
        samples[i] = sample
    
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = sample_rate
    stream.stereo = false
    stream.data = samples
    
    return stream 