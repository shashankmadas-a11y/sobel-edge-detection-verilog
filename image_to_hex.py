import os
from PIL import Image

def convert_any_image_to_hex(image_filename, output_hex_filename="input.hex", width=64, height=64):
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        input_image_path = os.path.join(script_dir, image_filename)
        output_hex_path = os.path.join(script_dir, output_hex_filename)

        if not os.path.exists(input_image_path):
            print(f"Error: Could not find '{image_filename}' inside:\n{script_dir}")
            return

        img = Image.open(input_image_path).convert('L')
        img = img.resize((width, height))
        
        try:
            pixel_data = list(img.get_flattened_data())
        except AttributeError:
            pixel_data = list(img.getdata())
        
        with open(output_hex_path, 'w') as f:
            for pixel in pixel_data:
                f.write(f"{pixel:02x}\n")
                
        print(f"Success! Hex file saved to:\n{output_hex_path}")
        
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == '__main__':
    convert_any_image_to_hex('sample_1.jpg', 'input.hex', 256, 256)