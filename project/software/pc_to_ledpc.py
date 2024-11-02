def extract_bits(hex_num):
    # Convert hex string to integer
    num = int(hex_num, 16)

    # Create mask for bits 8 to 2 (0b1111111 << 2)
    mask = 0x7F << 2

    # Extract bits using mask and shift right by 2
    result = (num & mask) >> 2

    # Format binary result to always show 7 bits
    # '07b' means 7-bit binary with leading zeros
    binary_result = format(result, '07b')

    return f"7'b{binary_result}", f"{hex(result).replace("0x", "7\'h")}"


# Example usage
hex_input = input(
    "Enter 32-bit hex number (with or without 0x prefix): ").replace("0x", "")

# Validate input length (32 bits = 8 hex digits)
if len(hex_input) > 8:
    print("Error: Input exceeds 32 bits")
else:
    binary_result, hex_result = extract_bits(hex_input)
    print(f"Bits 8:2 in binary: {binary_result}")
    print(f"Bits 8:2 in hex: {hex_result}")
