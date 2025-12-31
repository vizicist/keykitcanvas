
# shadertest.k - Test the 2-pass shader mechanism
#
# Pass 1: Generate a pattern (concentric circles with time-based animation)
# Pass 2: Apply a blur/glow effect to the output of pass 1

function shadertest() {

	# First, make sure the WebGL window is open
	# (user should click "WebGL Test" button first)

	# Pass 1: Generate animated concentric circles
	# This shader creates a pattern based on distance from center
	pass1_shader = "
void main() {
    vec2 uv = vUv;
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);

    // Create concentric rings that pulse with time
    float ring = sin(dist * 30.0 - iTime * 3.0) * 0.5 + 0.5;

    // Add some color variation
    vec3 col = vec3(ring * uv.x, ring * uv.y, ring);

    gl_FragColor = vec4(col, 1.0);
}
"

	# Pass 2: Simple horizontal blur using the output of pass 1
	# Samples from iChannel0 (the texture from pass 1)
	pass2_shader = "
void main() {
    vec2 uv = vUv;
    vec2 texel = 1.0 / iResolution;

    // Sample the previous pass output with a simple blur
    vec4 col = vec4(0.0);
    float blurSize = 3.0;

    for (float i = -2.0; i <= 2.0; i += 1.0) {
        for (float j = -2.0; j <= 2.0; j += 1.0) {
            col += texture2D(iChannel0, uv + vec2(i, j) * texel * blurSize);
        }
    }
    col /= 25.0;

    // Boost the brightness a bit for glow effect
    col.rgb *= 1.2;

    gl_FragColor = col;
}
"

	# Create the shader passes
	p1 = webgl_create_pass(pass1_shader)
	print("Created pass 1: ", p1)

	p2 = webgl_create_pass(pass2_shader)
	print("Created pass 2: ", p2)

	if (p1 < 0 || p2 < 0) {
		print("Failed to create shader passes!")
		return
	}

	# Set the pass order: pass1 renders to texture, pass2 reads it and renders to screen
	order = [p1, p2]
	webgl_set_pass_order(order)
	print("Set pass order")

	# Start the animation loop
	webgl_start_animation()
	print("Animation started! Press any key in KeyKit console to stop.")
}

function shadertest_stop() {
	webgl_stop_animation()
	print("Animation stopped.")
}

# A simpler single-pass test for debugging
function shadertest_simple() {

	shader = "
void main() {
    vec2 uv = vUv;

    // Simple gradient with time-based color cycling
    float r = sin(iTime) * 0.5 + 0.5;
    float g = sin(iTime + 2.094) * 0.5 + 0.5;
    float b = sin(iTime + 4.188) * 0.5 + 0.5;

    gl_FragColor = vec4(uv.x * r, uv.y * g, b, 1.0);
}
"

	p = webgl_create_pass(shader)
	print("Created pass: ", p)

	if (p < 0) {
		print("Failed to create shader pass!")
		return
	}

	order = [p]
	webgl_set_pass_order(order)

	webgl_start_animation()
	print("Simple animation started!")
}
