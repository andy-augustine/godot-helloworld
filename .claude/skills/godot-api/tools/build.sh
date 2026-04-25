#!/usr/bin/env bash
# Rebuild .claude/skills/godot-api/doc_api/ from the latest Godot source.
# Run from the project root. Re-run after Godot ships a new version.
set -euo pipefail

SKILL_DIR=".claude/skills/godot-api"
BUILD_DIR="$SKILL_DIR/_build"

# Sparse-checkout Godot's doc/classes (skip if already present)
if [ ! -d "$BUILD_DIR/godot/doc/classes" ]; then
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    git clone --depth 1 --filter=blob:none --sparse https://github.com/godotengine/godot.git
    cd godot
    git sparse-checkout set doc/classes
    cd ../../../..
else
    echo "Godot source already present in $BUILD_DIR — pulling latest"
    cd "$BUILD_DIR/godot"
    git pull --depth 1 origin master
    cd ../../../..
fi

# Run the converter
python3 "$SKILL_DIR/tools/godot_api_converter.py" \
    -i "$BUILD_DIR/godot/doc/classes" \
    --split-dir "$SKILL_DIR/doc_api" \
    --unified-classes \
    --method-desc first \
    --lang gdscript

echo "Done. doc_api/ regenerated in $SKILL_DIR/doc_api/"
