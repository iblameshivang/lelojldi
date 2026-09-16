import subprocess, sys, os

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

tests = [
    ("test_images/PLPATH-FRU-23-scab-apple-figure-1.png",                                    "apple",  "Apple___Apple_scab"),
    ("test_images/Botryosphaeria obtusa.jpg",                                                  "apple",  "Apple___Black_rot"),
    ("test_images/f6b9c5972311aeba037a7d13e629683c_t.jpg",                                    "apple",  "Apple___Cedar_apple_rust"),
    ("test_images/P1020083-W1200.jpg",                                                         "apple",  "Apple___healthy"),
    ("test_images/1355.50commonrust.jpg",                                                      "maize",  "Corn_(maize)___Common_rust_"),
    ("test_images/leafblightcorn.jpg",                                                         "maize",  "Corn_(maize)___Northern_Leaf_Blight"),
    ("test_images/Figure 3b Pasche_0.jpg.webp",                                               "maize",  "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot"),
    ("test_images/Example-of-healthya-and-infectedb-corn-leaves-for-classification-and-disease_Q320.webp", "maize", "Corn_(maize)___healthy"),
    ("test_images/images.jpg",                                                                 "potato", "Potato___Early_blight"),
    ("test_images/Late Blight potato.png",                                                     "potato", "Potato___Late_blight"),
    ("test_images/image1-33-e1627071656840.jpg",                                              "potato", "Potato___healthy"),
]

print()
print("=" * 95)
print(f"  {'#':<3} {'FILE':<45} {'EXPECTED':<38} {'PREDICTED':<38} {'CONF':>6}  {'OK?'}")
print("=" * 95)

for i, (img, plant, expected) in enumerate(tests, 1):
    if not os.path.isfile(img):
        print(f"  {i:<3} {os.path.basename(img):<45} {expected:<38} {'FILE NOT FOUND':<38} {'':>6}  SKIP")
        continue

    result = subprocess.run(
        [sys.executable, "predict.py", img, "--plant", plant],
        capture_output=True, text=True
    )
    out = result.stdout

    predicted = "PARSE_ERR"
    confidence = "?"
    for line in out.splitlines():
        if "Predicted" in line and ":" in line:
            predicted = line.split(":", 1)[1].strip()
        if "Confidence" in line and ":" in line:
            confidence = line.split(":", 1)[1].strip()

    correct = "YES" if predicted == expected else "NO "
    print(f"  {i:<3} {os.path.basename(img):<45} {expected:<38} {predicted:<38} {confidence:>6}  {correct}")

print("=" * 95)
print()
