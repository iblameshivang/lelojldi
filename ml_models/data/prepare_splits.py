"""
PlantVillage Dataset — Training Preparation Script
====================================================
- Verifies all 21 class folders
- Checks image readability (PIL open + verify)
- Creates stratified 80/10/10 train/val/test split
- Fixed random seed
- Writes CSV manifests to ml_models/data/dataset_splits/
- Does NOT touch or modify original images
"""

import os
import csv
import json
import random
import sys
from collections import defaultdict

# ── Pillow (PIL) ────────────────────────────────────────────────────────────
try:
    from PIL import Image
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("WARNING: Pillow not installed. Skipping per-image readability check.")
    print("         Install with: pip install Pillow")

# ── Configuration ────────────────────────────────────────────────────────────
RANDOM_SEED   = 42
TRAIN_RATIO   = 0.80
VAL_RATIO     = 0.10
TEST_RATIO    = 0.10
IMG_EXTS      = {'.jpg', '.jpeg', '.png', '.bmp', '.tiff'}

COLOR_DIR     = r'c:\Users\Shivang\Desktop\sih\ml_models\data\PlantVillage-Dataset-master\raw\color'
OUTPUT_DIR    = r'c:\Users\Shivang\Desktop\sih\ml_models\data\dataset_splits'

EXPECTED_CLASSES = [
    'Apple___Apple_scab',
    'Apple___Black_rot',
    'Apple___Cedar_apple_rust',
    'Apple___healthy',
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
    'Corn_(maize)___Common_rust_',
    'Corn_(maize)___healthy',
    'Corn_(maize)___Northern_Leaf_Blight',
    'Potato___Early_blight',
    'Potato___healthy',
    'Potato___Late_blight',
    'Tomato___Bacterial_spot',
    'Tomato___Early_blight',
    'Tomato___healthy',
    'Tomato___Late_blight',
    'Tomato___Leaf_Mold',
    'Tomato___Septoria_leaf_spot',
    'Tomato___Spider_mites Two-spotted_spider_mite',
    'Tomato___Target_Spot',
    'Tomato___Tomato_mosaic_virus',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
]

# ── Step 1: Verify class folders ─────────────────────────────────────────────
print("=" * 70)
print("STEP 1: Verifying 21 class folders")
print("=" * 70)

missing_classes = []
for cls in EXPECTED_CLASSES:
    path = os.path.join(COLOR_DIR, cls)
    if not os.path.isdir(path):
        missing_classes.append(cls)
        print(f"  [MISSING] {cls}")
    else:
        print(f"  [OK]      {cls}")

if missing_classes:
    print(f"\nERROR: {len(missing_classes)} class folder(s) missing. Aborting.")
    sys.exit(1)
else:
    print(f"\nAll 21 class folders present.\n")

# ── Step 2: Collect all images & check readability ───────────────────────────
print("=" * 70)
print("STEP 2: Collecting images & checking readability")
print("=" * 70)

all_images     = []   # list of (relative_path, class_name)
corrupted      = []   # list of (absolute_path, error_msg)
class_counts   = {}

for cls in EXPECTED_CLASSES:
    cls_dir = os.path.join(COLOR_DIR, cls)
    files = sorted([
        f for f in os.listdir(cls_dir)
        if os.path.splitext(f)[1].lower() in IMG_EXTS
    ])
    class_counts[cls] = 0
    bad = 0

    for fname in files:
        abs_path = os.path.join(cls_dir, fname)
        rel_path = os.path.join(cls, fname)  # relative to color_dir

        readable = True
        if PIL_AVAILABLE:
            try:
                with Image.open(abs_path) as img:
                    img.verify()   # check for corruption
                readable = True
            except Exception as e:
                corrupted.append((rel_path, str(e)))
                readable = False
                bad += 1

        if readable:
            all_images.append((rel_path, cls))
            class_counts[cls] += 1

    print(f"  {class_counts[cls]:5d} OK  |  {bad:3d} bad  |  {cls}")

total_ok  = len(all_images)
total_bad = len(corrupted)
print(f"\n  Total readable images : {total_ok:,}")
print(f"  Total corrupted       : {total_bad}")
print()

# ── Step 3: Stratified split ─────────────────────────────────────────────────
print("=" * 70)
print(f"STEP 3: Creating stratified split  (seed={RANDOM_SEED})")
print(f"        Train {TRAIN_RATIO*100:.0f}% / Val {VAL_RATIO*100:.0f}% / Test {TEST_RATIO*100:.0f}%")
print("=" * 70)

rng = random.Random(RANDOM_SEED)

# Group by class
by_class = defaultdict(list)
for rel_path, cls in all_images:
    by_class[cls].append(rel_path)

train_rows, val_rows, test_rows = [], [], []
split_counts = {}   # {cls: {train, val, test}}

for cls in EXPECTED_CLASSES:
    items = by_class[cls][:]
    rng.shuffle(items)

    n        = len(items)
    n_train  = int(n * TRAIN_RATIO)
    n_val    = int(n * VAL_RATIO)
    n_test   = n - n_train - n_val   # remainder → test (avoids rounding loss)

    t_items  = items[:n_train]
    v_items  = items[n_train : n_train + n_val]
    te_items = items[n_train + n_val:]

    for p in t_items:
        train_rows.append({'image_path': p, 'class': cls})
    for p in v_items:
        val_rows.append({'image_path': p, 'class': cls})
    for p in te_items:
        test_rows.append({'image_path': p, 'class': cls})

    split_counts[cls] = {'train': len(t_items), 'val': len(v_items), 'test': len(te_items), 'total': n}
    print(f"  {cls[:50]:<50s}  total={n:5d}  train={len(t_items):4d}  val={len(v_items):4d}  test={len(te_items):4d}")

# Shuffle the final lists so they're not class-blocked
rng.shuffle(train_rows)
rng.shuffle(val_rows)
rng.shuffle(test_rows)

print(f"\n  TOTAL  train={len(train_rows):,}  val={len(val_rows):,}  test={len(test_rows):,}  sum={len(train_rows)+len(val_rows)+len(test_rows):,}")
print()

# ── Step 4: Write output files ───────────────────────────────────────────────
print("=" * 70)
print("STEP 4: Writing split files to dataset_splits/")
print("=" * 70)

os.makedirs(OUTPUT_DIR, exist_ok=True)

def write_csv(rows, filepath):
    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['image_path', 'class'])
        writer.writeheader()
        writer.writerows(rows)

train_csv = os.path.join(OUTPUT_DIR, 'train.csv')
val_csv   = os.path.join(OUTPUT_DIR, 'val.csv')
test_csv  = os.path.join(OUTPUT_DIR, 'test.csv')

write_csv(train_rows, train_csv)
write_csv(val_rows,   val_csv)
write_csv(test_rows,  test_csv)

# Class-index mapping (sorted alphabetically → stable label encoding)
class_index = {cls: i for i, cls in enumerate(sorted(EXPECTED_CLASSES))}

# Metadata JSON
meta = {
    "random_seed"    : RANDOM_SEED,
    "split_ratios"   : {"train": TRAIN_RATIO, "val": VAL_RATIO, "test": TEST_RATIO},
    "color_dir"      : COLOR_DIR,
    "total_images"   : total_ok,
    "total_corrupted": total_bad,
    "train_count"    : len(train_rows),
    "val_count"      : len(val_rows),
    "test_count"     : len(test_rows),
    "num_classes"    : len(EXPECTED_CLASSES),
    "class_index"    : class_index,
    "per_class_split": split_counts,
    "corrupted_files": corrupted,
    "files_created"  : {
        "train_csv": train_csv,
        "val_csv"  : val_csv,
        "test_csv" : test_csv,
    }
}

meta_path = os.path.join(OUTPUT_DIR, 'dataset_meta.json')
with open(meta_path, 'w', encoding='utf-8') as f:
    json.dump(meta, f, indent=2)

print(f"  [CREATED] {train_csv}")
print(f"  [CREATED] {val_csv}")
print(f"  [CREATED] {test_csv}")
print(f"  [CREATED] {meta_path}")
print()

# ── Final Report ─────────────────────────────────────────────────────────────
print("=" * 70)
print("FINAL REPORT")
print("=" * 70)
print(f"  Random seed       : {RANDOM_SEED}")
print(f"  Total images      : {total_ok:,}")
print(f"  Train             : {len(train_rows):,}")
print(f"  Validation        : {len(val_rows):,}")
print(f"  Test              : {len(test_rows):,}")
print(f"  Corrupted/skipped : {total_bad}")
print()
print(f"  {'CLASS':<52}  {'TOTAL':>5}  {'TRAIN':>5}  {'VAL':>4}  {'TEST':>4}")
print("  " + "-" * 68)
for cls in EXPECTED_CLASSES:
    sc = split_counts[cls]
    print(f"  {cls:<52}  {sc['total']:>5}  {sc['train']:>5}  {sc['val']:>4}  {sc['test']:>4}")
print()
if corrupted:
    print("  CORRUPTED FILES:")
    for p, err in corrupted:
        print(f"    {p}  ({err})")
else:
    print("  No corrupted images found.")
print()
print("  Original images: NOT modified, NOT moved, NOT deleted.")
print("  Split info stored ONLY in dataset_splits/ as CSV + JSON.")
print("=" * 70)
print("Dataset preparation complete. Ready for training step.")

