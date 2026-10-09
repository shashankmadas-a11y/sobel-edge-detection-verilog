import os
from PIL import Image

def convert_hex_to_image(hex_filename="output.hex", output_image_filename="result.png", 
                         sim_width=256, sim_height=256, original_image_path="sample_1.jpg"):
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        hex_path = os.path.join(script_dir, hex_filename)
        output_path = os.path.join(script_dir, output_image_filename)
        orig_path = os.path.join(script_dir, original_image_path)

        if not os.path.exists(hex_path):
            print(f"Error: Could not find '{hex_filename}' in:\n{script_dir}")
            return

        with open(hex_path, 'r') as f:
            hex_lines = f.readlines()

        pixel_data = [int(line.strip(), 16) for line in hex_lines if line.strip()]
        expected_pixels = sim_width * sim_height
        
        if len(pixel_data) < expected_pixels:
            pixel_data.extend([0] * (expected_pixels - len(pixel_data)))

        # Reconstruct 256x256 hardware image
        img = Image.new('L', (sim_width, sim_height))
        img.putdata(pixel_data[:expected_pixels])
        
        # Resize to match original input image dimensions if original image exists
        if os.path.exists(orig_path):
            with Image.open(orig_path) as orig_img:
                orig_width, orig_height = orig_img.size
            
            try:
                resample_method = Image.Resampling.LANCZOS
            except AttributeError:
                resample_method = Image.LANCZOS

            img = img.resize((orig_width, orig_height), resample_method)
            print(f"Success! Resized output image to original input dimensions ({orig_width}x{orig_height}).")
        else:
            print(f"Original image not found. Saved at hardware resolution ({sim_width}x{sim_height}).")

        img.save(output_path)
        print(f"Saved at: {output_path}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == '__main__':
    convert_hex_to_image('output.hex', 'result.png', 256, 256, 'sample_1.jpg')