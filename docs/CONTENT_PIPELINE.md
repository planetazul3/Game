# RTS Content Pipeline & Modding Guide

## Overview
The engine uses a data-driven pipeline where all gameplay assets are defined as resources.

## Directory Structure
- `data/buildings/`: Building templates and stats.
- `data/tech/`: Research items and upgrade paths.
- `data/abilities/`: Combat abilities and effects.
- `data/biomes/`: Terrain and resource distribution profiles.

## GUID-Based Identification
Every content resource inherits from `GameContent` and must have a unique `guid`. This ensures that references remain stable even if files are moved or renamed.

## Validation
The `ContentValidator` tool (`scripts/tools/content_validator.gd`) should be run after any data changes to check for:
1.  **Duplicate GUIDs**: Ensures identity uniqueness.
2.  **Broken References**: Detects missing assets or invalid prerequisite links.
3.  **Circular dependencies**: Prevents infinite tech tree loops.

## Modding Support
By loading content dynamically from the `data/` folder, the engine is inherently mod-friendly. New content can be added by placing additional `.tres` files in the corresponding directories.
