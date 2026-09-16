import numpy as np

try:
    from ai_edge_litert.interpreter import Interpreter

    # Load model and allocate tensors
    interpreter = Interpreter(model_path="exported/model.tflite")
    interpreter.allocate_tensors()

    # Read input details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    # Read labels
    with open("exported/labels.txt", "r") as f:
        labels = [line.strip() for line in f.readlines()]

    print("\n SUCCESS: Model loaded properly!")
    print(f" Expected image input shape: {input_details[0]['shape']}")
    print(f" Total disease classes in label file: {len(labels)}")

except Exception as e:
    print(f"\n ERROR: {e}")