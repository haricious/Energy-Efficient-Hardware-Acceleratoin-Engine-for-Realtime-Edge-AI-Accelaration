import os

def to_hex_8bit(val):
    if val < 0: val = (1 << 8) + val
    return f"{val:02X}"

def main():
    print("==================================================")
    print("   DATASET EXTRACTION: UCI HANDWRITTEN DIGITS     ")
    print("==================================================")
    
    # YOUR DIRECTORY
    output_dir = r"D:\Projects\SIXXIS\Energy Efficient Hardware Acceleratoin Engine for Realtime Edge AI Accelaration\project_1\py"
    if not os.path.exists(output_dir): os.makedirs(output_dir)

    # 1. REAL ACADEMIC DATASET (UCI ML Repository - Digit '0')
    uci_digit_0 = [
        [ 0,  0,  5, 13,  9,  1,  0,  0],
        [ 0,  0, 13, 15, 10, 15,  5,  0],
        [ 0,  3, 15,  2,  0, 11,  8,  0],
        [ 0,  4, 12,  0,  0,  8,  8,  0],
        [ 0,  5,  8,  0,  0,  9,  8,  0],
        [ 0,  4, 11,  0,  1, 12,  7,  0],
        [ 0,  2, 14,  5, 10, 12,  0,  0],
        [ 0,  0,  6, 13, 10,  0,  0,  0]
    ]

    # 2. CONVOLUTIONAL WINDOW EXTRACTION
    img_patch = [[0 for _ in range(4)] for _ in range(4)]
    for r in range(4):
        for c in range(4):
            # THE FIX: Scale to 127 MAX so Verilog Signed 8-bit doesn't overflow!
            img_patch[r][c] = int((uci_digit_0[r][c] / 15.0) * 127)

    print("Extracted 4x4 Patch (Scaled to Signed INT8 limits):")
    for row in img_patch: print(row)

    # 3. WEIGHTS: Sobel Vertical Edge Filter
    weights = [
        [ 1,  0, -1,  0],
        [ 1,  0, -1,  0],
        [ 1,  0, -1,  0],
        [ 1,  0, -1,  0]
    ]

    # 4. HARDWARE-ACCURATE SOFTWARE BASELINE
    expected_output = [0, 0, 0, 0]
    
    for col in range(4): # For each hardware column
        catcher_reg = 0
        for t in range(4): # As each column of the image flows through
            col_sum = 0
            for r in range(4):
                col_sum += img_patch[r][t] * weights[r][col]
            
            # Simulate Hardware ReLU
            if col_sum < 0: relu_out = 0
            elif col_sum > 255: relu_out = 255
            else: relu_out = col_sum
            
            # Simulate Testbench Catcher Logic
            if relu_out != 0:
                catcher_reg = relu_out
                
        expected_output[col] = catcher_reg

    print("\n[PYTHON] Expected Hardware Output (ReLU Activated):")
    for i, val in enumerate(expected_output):
        print(f" -> Col {i}: {val}")
    print("==================================================")

    # 5. GENERATE HEX FILES FOR VIVADO
    with open(os.path.join(output_dir, "real_weights.hex"), "w") as f:
        for r in range(4):
            f.write("".join([to_hex_8bit(weights[r][c]) for c in reversed(range(4))]) + "\n")

    with open(os.path.join(output_dir, "real_image.hex"), "w") as f:
        for cycle in range(7):
            cycle_data = []
            for r in reversed(range(4)):
                c = cycle - r
                val = img_patch[r][c] if 0 <= c < 4 else 0
                cycle_data.append(to_hex_8bit(val))
            f.write("".join(cycle_data) + "\n")

    print(f"\n[SUCCESS] Dataset files ready for Vivado simulation.")

if __name__ == "__main__":
    main()
    input("\nPress Enter to close...")