import os
import urllib.request
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def download_model():
    model_url = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
    model_dir = "models"
    model_path = os.path.join(model_dir, "tinyllama.gguf")

    if not os.path.exists(model_dir):
        os.makedirs(model_dir)

    if not os.path.exists(model_path):
        logger.info(f"Downloading TinyLlama GGUF model to {model_path}...")
        try:
            urllib.request.urlretrieve(model_url, model_path)
            logger.info("Download completed successfully.")
        except Exception as e:
            logger.error(f"Error downloading model: {e}")
    else:
        logger.info("Model already exists. Skipping download.")

if __name__ == "__main__":
    download_model()
