#!/bin/bash

# Directory to watch (default to current directory)
WATCH_DIR=src

# File extension to watch
FILE_EXT=".zig"

echo "Watching directory: $WATCH_DIR for changes in $FILE_EXT files..."

# Watch for file changes and run tests
fswatch -o "$WATCH_DIR" | while read; do
    clear

    # CHANGED_FILES=$(find "$WATCH_DIR" -name "*$FILE_EXT" -type f -print)
    echo "Detected changes in Zig files. Running tests..."
    
    # Run all tests in the project
    zig test src/root.zig 
    
    if [ $? -eq 0 ]; then
        echo "Tests passed!"
    else
        echo "Tests failed!"
    fi
done

