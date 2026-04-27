from pathlib import Path
import random
import shutil
import csv

# =========================================================
# 1. Path configuration
# =========================================================

SOURCE_ROOT = Path(
    r"E:\A_connected environments\DLSN\Hass Avocado Ripening Photographic Dataset\Avocado Ripening Dataset"
)

OUTPUT_ROOT = Path(
    r"E:\A_connected environments\DLSN\Avocado_dataset"
)

# =========================================================
# 2. Adjustable parameters
# =========================================================

TRAIN_RATIO = 0.8
RANDOM_SEED = 42

# For the 1/3/5 experiment, use all available images first,
# then automatically balance all classes to the smallest class.
MAX_IMAGES_PER_CLASS = None

# If True, the output folder will be deleted and rebuilt
CLEAR_OUTPUT_FIRST = True

SUPPORTED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}

# Final mapping for this round:
# 1 -> unripe
# 3 -> ready
# 5 -> overripe
# Stages 2 and 4 are excluded automatically
STAGE_TO_CLASS = {
    "1": "unripe",
    "3": "ready",
    "5": "overripe",
}

# If True, all final classes will be balanced to the smallest class size
BALANCE_TO_SMALLEST_CLASS = True

# =========================================================
# 3. Helper functions
# =========================================================

def is_image_file(path: Path) -> bool:
    return path.is_file() and path.suffix.lower() in SUPPORTED_IMAGE_EXTENSIONS


def reset_output_directory(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def ensure_directory(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def parse_image_filename(path: Path):
    """
    Expected filename format:
    T10_d01_002_a_1.jpg

    Parsed fields:
    storage = T10
    day = d01
    sample = 002
    side = a
    stage = 1

    Returns a dictionary like:
    {
        "path": Path(...),
        "storage": "T10",
        "day": "d01",
        "sample": "002",
        "side": "a",
        "stage": "1",
        "class_name": "unripe",
        "group_id": "T10_d01_002_1"
    }

    If the stage is not in STAGE_TO_CLASS (e.g. 2 or 4),
    the file will be skipped automatically.
    """
    stem = path.stem
    parts = stem.split("_")

    if len(parts) < 5:
        return None

    storage = parts[0]
    day = parts[1]
    sample = parts[2]
    side = parts[3]
    stage = parts[4]

    if not day.startswith("d"):
        return None

    if side not in {"a", "b"}:
        return None

    if stage not in STAGE_TO_CLASS:
        return None

    class_name = STAGE_TO_CLASS[stage]

    # Keep paired views (a/b) of the same sample and stage together
    group_id = f"{storage}_{day}_{sample}_{stage}"

    return {
        "path": path,
        "storage": storage,
        "day": day,
        "sample": sample,
        "side": side,
        "stage": stage,
        "class_name": class_name,
        "group_id": group_id,
    }


def collect_image_records(source_root: Path):
    records = []
    skipped_files = []

    for path in source_root.rglob("*"):
        if not is_image_file(path):
            continue

        parsed = parse_image_filename(path)
        if parsed is None:
            skipped_files.append(str(path))
        else:
            records.append(parsed)

    return records, skipped_files


def group_records_by_class_and_group(records):
    grouped = {
        "unripe": {},
        "ready": {},
        "overripe": {},
    }

    for record in records:
        class_name = record["class_name"]
        group_id = record["group_id"]
        grouped[class_name].setdefault(group_id, []).append(record)

    return grouped


def limit_groups_by_image_count(group_dict, max_images=None):
    """
    group_dict structure:
    {
        "group_id_1": [record1, record2],
        "group_id_2": [record3, record4],
        ...
    }

    If max_images is None, keep all groups.
    Otherwise, shuffle groups and keep adding groups until the image count
    reaches or slightly exceeds max_images.
    """
    group_keys = list(group_dict.keys())
    random.shuffle(group_keys)

    if max_images is None:
        return {key: group_dict[key] for key in group_keys}

    selected = {}
    image_count = 0

    for key in group_keys:
        group_size = len(group_dict[key])
        if image_count >= max_images:
            break
        selected[key] = group_dict[key]
        image_count += group_size

    return selected


def count_images_in_groups(group_dict):
    return sum(len(group) for group in group_dict.values())


def balance_all_classes_to_smallest(grouped_records):
    """
    Balance all final classes to the smallest class size, based on image count.
    """
    class_counts = {
        class_name: count_images_in_groups(group_dict)
        for class_name, group_dict in grouped_records.items()
    }

    smallest_class_size = min(class_counts.values())

    balanced_records = {}
    for class_name, group_dict in grouped_records.items():
        balanced_records[class_name] = limit_groups_by_image_count(
            group_dict,
            max_images=smallest_class_size
        )

    return balanced_records, class_counts, smallest_class_size


def split_groups_into_train_test(group_dict, train_ratio=0.8):
    """
    Split by group to avoid placing paired images (a/b) into different subsets.
    """
    group_keys = list(group_dict.keys())
    random.shuffle(group_keys)

    total_groups = len(group_keys)
    if total_groups == 0:
        return {}, {}

    if total_groups == 1:
        return {group_keys[0]: group_dict[group_keys[0]]}, {}

    train_group_count = int(total_groups * train_ratio)

    if train_group_count <= 0:
        train_group_count = 1
    if train_group_count >= total_groups:
        train_group_count = total_groups - 1

    train_keys = set(group_keys[:train_group_count])
    test_keys = set(group_keys[train_group_count:])

    train_groups = {key: group_dict[key] for key in train_keys}
    test_groups = {key: group_dict[key] for key in test_keys}

    return train_groups, test_groups


def flatten_group_dictionary(group_dict):
    records = []
    for group_records in group_dict.values():
        records.extend(group_records)
    return records


def copy_records_to_output(records, subset_name, class_name):
    target_dir = OUTPUT_ROOT / subset_name / class_name
    ensure_directory(target_dir)

    copied_paths = []
    for record in records:
        source_path = record["path"]
        destination_path = target_dir / source_path.name
        shutil.copy2(source_path, destination_path)
        copied_paths.append(destination_path)

    return copied_paths


# =========================================================
# 4. Main pipeline
# =========================================================

def main():
    random.seed(RANDOM_SEED)

    if CLEAR_OUTPUT_FIRST:
        reset_output_directory(OUTPUT_ROOT)
    else:
        ensure_directory(OUTPUT_ROOT)

    print("Scanning source dataset...")
    records, skipped_files = collect_image_records(SOURCE_ROOT)

    if not records:
        raise RuntimeError(
            "No valid images were found. Please check the source path and filename format."
        )

    print(f"Successfully parsed images: {len(records)}")
    print(f"Skipped files: {len(skipped_files)}")

    if skipped_files:
        skipped_file_path = OUTPUT_ROOT / "skipped_files.txt"
        with open(skipped_file_path, "w", encoding="utf-8") as file:
            for item in skipped_files:
                file.write(item + "\n")
        print(f"Skipped file list saved to: {skipped_file_path}")

    grouped_records = group_records_by_class_and_group(records)

    # First, optionally limit each class independently
    limited_records = {}
    for class_name in ["unripe", "ready", "overripe"]:
        limited_records[class_name] = limit_groups_by_image_count(
            grouped_records[class_name],
            max_images=MAX_IMAGES_PER_CLASS
        )

    # Then balance all classes to the smallest one
    if BALANCE_TO_SMALLEST_CLASS:
        balanced_records, original_counts, smallest_class_size = balance_all_classes_to_smallest(
            limited_records
        )
        print("\nBalancing classes to the smallest class size...")
        for class_name in ["unripe", "ready", "overripe"]:
            print(f"{class_name}: original={original_counts[class_name]}")
        print(f"Balanced target size per class: {smallest_class_size}")
    else:
        balanced_records = limited_records

    summary_rows = []
    total_train_images = 0
    total_test_images = 0

    for class_name in ["unripe", "ready", "overripe"]:
        class_groups_before = grouped_records[class_name]
        class_groups_after = balanced_records[class_name]

        original_group_count = len(class_groups_before)
        original_image_count = sum(len(group) for group in class_groups_before.values())

        selected_group_count = len(class_groups_after)
        selected_image_count = sum(len(group) for group in class_groups_after.values())

        train_groups, test_groups = split_groups_into_train_test(
            class_groups_after,
            train_ratio=TRAIN_RATIO
        )

        train_records = flatten_group_dictionary(train_groups)
        test_records = flatten_group_dictionary(test_groups)

        copied_train = copy_records_to_output(train_records, "training", class_name)
        copied_test = copy_records_to_output(test_records, "testing", class_name)

        total_train_images += len(copied_train)
        total_test_images += len(copied_test)

        summary_rows.append({
            "class_name": class_name,
            "original_group_count": original_group_count,
            "original_image_count": original_image_count,
            "selected_group_count": selected_group_count,
            "selected_image_count": selected_image_count,
            "train_image_count": len(copied_train),
            "test_image_count": len(copied_test),
        })

        print(
            f"[{class_name}] "
            f"original_images={original_image_count}, "
            f"selected_images={selected_image_count}, "
            f"train_images={len(copied_train)}, "
            f"test_images={len(copied_test)}"
        )

    summary_csv_path = OUTPUT_ROOT / "dataset_summary.csv"
    with open(summary_csv_path, "w", newline="", encoding="utf-8-sig") as csv_file:
        writer = csv.DictWriter(
            csv_file,
            fieldnames=[
                "class_name",
                "original_group_count",
                "original_image_count",
                "selected_group_count",
                "selected_image_count",
                "train_image_count",
                "test_image_count",
            ]
        )
        writer.writeheader()
        writer.writerows(summary_rows)

    print("\nProcessing completed successfully.")
    print(f"Output directory: {OUTPUT_ROOT}")
    print(f"Total training images: {total_train_images}")
    print(f"Total testing images: {total_test_images}")
    print(f"Summary file: {summary_csv_path}")

    print("\nFinal folder structure:")
    print(OUTPUT_ROOT / "training" / "unripe")
    print(OUTPUT_ROOT / "training" / "ready")
    print(OUTPUT_ROOT / "training" / "overripe")
    print(OUTPUT_ROOT / "testing" / "unripe")
    print(OUTPUT_ROOT / "testing" / "ready")
    print(OUTPUT_ROOT / "testing" / "overripe")


if __name__ == "__main__":
    main()