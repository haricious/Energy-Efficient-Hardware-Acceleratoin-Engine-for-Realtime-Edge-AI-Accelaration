import os

def to_hex_8bit(val):
    """Converts a signed 8-bit integer to a 2-character hex string."""
    if val < 0:
        val = (1 << 8) + val
    return f"{val:02X}"

def main():
    print("--- Edge AI Hex Data Generator (Zero-Dependency Version) ---")
    ARRAY_SIZE = 4 
    
    # We get the exact folder where this Python script is located
    output_dir = os.path.dirname(os.path.abspath(__file__))
    weights_out_path = os.path.join(output_dir, "real_weights.hex")
    image_out_path = os.path.join(output_dir, "real_image.hex")

    # 1. THE IMAGE DATA (Hardcoded Shape of an '8')
    # 100 = Bright White Pixel, 0 = Black Background
    img_array = [
        [  0, 100, 100,   0],  # Top loop
        [100, 100, 100, 100],  # Middle cross
        [100,   0,   0, 100],  # Bottom hole
        [  0, 100, 100,   0]   # Bottom edge
    ]
    
    print("\nPixel Matrix for the '8' (Feeding this into hardware):")
    for row in img_array:
        print(row)

    # 2. THE WEIGHTS (Edge Detection Filter)
    weights = [
        [ 1,  0, -1,  0],
        [ 1,  0, -1,  0],
        [ 1,  0, -1,  0],
        [ 1,  0, -1,  0]
    ]

    # 3. GENERATE WEIGHT HEX FILE
    print(f"\nSaving weights to: {weights_out_path}")
    with open(weights_out_path, "w") as f:
        for row in range(ARRAY_SIZE):
            hex_line = "".join([to_hex_8bit(weights[row][col]) for col in reversed(range(ARRAY_SIZE))])
            f.write(hex_line + "\n")

    # 4. GENERATE SKEWED IMAGE HEX FILE
    print(f"Saving image data to: {image_out_path}")
    skewed_cycles = (2 * ARRAY_SIZE) - 1
    
    with open(image_out_path, "w") as f:
        for cycle in range(skewed_cycles):
            cycle_data = []
            for row in reversed(range(ARRAY_SIZE)):
                col = cycle - row
                if 0 <= col < ARRAY_SIZE:
                    pixel_val = img_array[row][col]
                else:
                    pixel_val = 0 
                cycle_data.append(to_hex_8bit(pixel_val))
            
            hex_line = "".join(cycle_data)
            f.write(hex_line + "\n")

    print("\n[SUCCESS] Files generated successfully right next to this script!")

if __name__ == "__main__":
    main()
    input("\nPress Enter to close this window...")