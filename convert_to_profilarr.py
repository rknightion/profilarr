#!/usr/bin/env python3
"""
Radarr/Sonarr Custom Format JSON to Profilarr/Dictionarry YAML Converter

This script converts your existing Radarr/Sonarr custom format JSON exports
to the YAML format used by Profilarr databases.

Usage:
    python convert_to_profilarr.py /path/to/json/files /path/to/output

Author: Claude (Anthropic)
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Any

# Map Radarr/Sonarr implementation types to Profilarr condition types
IMPLEMENTATION_MAP = {
    "ReleaseTitleSpecification": "release_title",
    "ReleaseGroupSpecification": "release_group",
    "IndexerFlagSpecification": "indexer_flag",
    "SourceSpecification": "source",
    "ResolutionSpecification": "resolution",
    "QualityModifierSpecification": "quality_modifier",
    "SizeSpecification": "size",
    "LanguageSpecification": "language",
    "EditionSpecification": "edition",
}


def sanitize_filename(name: str) -> str:
    """Convert a custom format name to a valid filename."""
    # Replace spaces and special chars with hyphens
    sanitized = re.sub(r'[^a-zA-Z0-9\-_]', '-', name.lower())
    # Remove multiple consecutive hyphens
    sanitized = re.sub(r'-+', '-', sanitized)
    # Remove leading/trailing hyphens
    sanitized = sanitized.strip('-')
    return sanitized


def determine_tags(name: str, conditions: list) -> list[str]:
    """Automatically determine appropriate tags based on the custom format content."""
    tags = []
    name_lower = name.lower()
    
    # Audio tags
    audio_keywords = ['atmos', 'dts', 'truehd', 'ddp', 'dd+', 'eac3', 'surround', '5.1', '7.1', 'lossless audio', 'audio']
    if any(kw in name_lower for kw in audio_keywords):
        tags.append('Audio')
    
    # HDR tags
    hdr_keywords = ['hdr', 'dv', 'dolby vision', 'dovi', 'hdr10']
    if any(kw in name_lower for kw in hdr_keywords):
        tags.append('HDR')
    
    # Codec tags
    codec_keywords = ['x264', 'x265', 'hevc', 'h.264', 'h.265', 'avc', '10-bit', '10bit']
    if any(kw in name_lower for kw in codec_keywords):
        tags.append('Codec')
    
    # Quality/Source tags
    quality_keywords = ['remux', 'br-disk', 'bluray', 'web-dl', 'webrip']
    if any(kw in name_lower for kw in quality_keywords):
        tags.append('Quality')
    
    # Unwanted tags
    unwanted_keywords = ['block', 'avoid', 'unwanted', 'bad']
    if any(kw in name_lower for kw in unwanted_keywords):
        tags.append('Unwanted')
    
    # Release Group tags
    group_keywords = ['group', 'trusted']
    if any(kw in name_lower for kw in group_keywords):
        tags.append('Release Group')
    
    # Language tags
    language_keywords = ['language', 'foreign', 'dubbed', 'multi']
    if any(kw in name_lower for kw in language_keywords):
        tags.append('Language')
    
    return tags if tags else ['Custom']


def generate_description(name: str, conditions: list) -> str:
    """Generate a meaningful description from the custom format."""
    condition_summaries = []
    for cond in conditions:
        action = "Matches" if not cond.get('negate', False) else "Excludes"
        pattern = cond.get('fields', {}).get('value', 'N/A')
        # Simplify pattern for description
        simplified = pattern.replace('(?i)', '').replace('\\b', '')
        condition_summaries.append(f"{action}: {simplified}")
    
    if len(condition_summaries) == 1:
        return f"{name} - {condition_summaries[0]}"
    else:
        return f"{name} custom format with {len(condition_summaries)} conditions"


def convert_condition(spec: dict) -> dict:
    """Convert a single Radarr/Sonarr specification to Profilarr condition format."""
    impl = spec.get('implementation', 'ReleaseTitleSpecification')
    condition_type = IMPLEMENTATION_MAP.get(impl, 'release_title')
    
    condition = {
        'name': spec.get('name', 'Unnamed Condition'),
        'type': condition_type,
    }
    
    # Handle the pattern/value field
    fields = spec.get('fields', {})
    if isinstance(fields, dict):
        pattern = fields.get('value', '')
    elif isinstance(fields, list):
        # Some exports have fields as a list
        pattern = next((f.get('value') for f in fields if f.get('name') == 'value'), '')
    else:
        pattern = ''
    
    if pattern:
        condition['pattern'] = pattern
    
    # Add negate and required flags
    if spec.get('negate', False):
        condition['negate'] = True
    
    if spec.get('required', True):
        condition['required'] = True
    
    return condition


def convert_json_to_yaml_dict(json_data: dict) -> dict:
    """Convert a Radarr/Sonarr JSON custom format to Profilarr YAML structure."""
    name = json_data.get('name', 'Unnamed Format')
    specifications = json_data.get('specifications', [])
    
    # Build conditions list
    conditions = []
    for spec in specifications:
        conditions.append(convert_condition(spec))
    
    # Build the YAML structure
    yaml_data = {
        'name': name,
        'description': generate_description(name, specifications),
        'tags': determine_tags(name, conditions),
        'conditions': conditions,
        'tests': [],
    }
    
    # Only include includeInName if it was true in the original
    if json_data.get('includeCustomFormatWhenRenaming', False):
        yaml_data['include_in_rename'] = True
    
    return yaml_data


def dict_to_yaml(data: dict, indent: int = 0) -> str:
    """Convert a dictionary to YAML string without external dependencies."""
    yaml_lines = []
    spaces = '  ' * indent
    
    for key, value in data.items():
        if isinstance(value, dict):
            yaml_lines.append(f"{spaces}{key}:")
            yaml_lines.append(dict_to_yaml(value, indent + 1))
        elif isinstance(value, list):
            yaml_lines.append(f"{spaces}{key}:")
            for item in value:
                if isinstance(item, dict):
                    first = True
                    for k, v in item.items():
                        prefix = '- ' if first else '  '
                        first = False
                        if isinstance(v, bool):
                            yaml_lines.append(f"{spaces}  {prefix}{k}: {str(v).lower()}")
                        elif isinstance(v, str):
                            # Check if string needs quoting
                            if any(c in v for c in ':{}[],"\'|>\\') or v.startswith(('#', '!', '&', '*')):
                                yaml_lines.append(f"{spaces}  {prefix}{k}: \"{v}\"")
                            else:
                                yaml_lines.append(f"{spaces}  {prefix}{k}: {v}")
                        else:
                            yaml_lines.append(f"{spaces}  {prefix}{k}: {v}")
                elif isinstance(item, str):
                    yaml_lines.append(f"{spaces}  - {item}")
                else:
                    yaml_lines.append(f"{spaces}  - {item}")
        elif isinstance(value, bool):
            yaml_lines.append(f"{spaces}{key}: {str(value).lower()}")
        elif isinstance(value, str):
            # Check if string needs quoting
            if any(c in value for c in ':{}[],"\'|>\\') or value.startswith(('#', '!', '&', '*')):
                yaml_lines.append(f"{spaces}{key}: \"{value}\"")
            else:
                yaml_lines.append(f"{spaces}{key}: {value}")
        elif value is None:
            yaml_lines.append(f"{spaces}{key}:")
        else:
            yaml_lines.append(f"{spaces}{key}: {value}")
    
    return '\n'.join(yaml_lines)


def convert_yaml_string(yaml_data: dict) -> str:
    """Convert dictionary to proper YAML string format for Profilarr."""
    lines = []
    
    # Name
    lines.append(f"name: {yaml_data['name']}")
    
    # Description
    lines.append(f"description: \"{yaml_data['description']}\"")
    
    # Tags
    lines.append("tags:")
    for tag in yaml_data.get('tags', []):
        lines.append(f"  - {tag}")
    
    # Conditions
    lines.append("conditions:")
    for i, cond in enumerate(yaml_data.get('conditions', [])):
        # First item gets the dash, subsequent keys are indented
        lines.append(f"  - name: {cond['name']}")
        lines.append(f"    type: {cond['type']}")
        if 'pattern' in cond:
            # Quote the pattern to preserve regex special chars
            lines.append(f"    pattern: \"{cond['pattern']}\"")
        if cond.get('negate'):
            lines.append(f"    negate: true")
        if cond.get('required'):
            lines.append(f"    required: true")
    
    # Tests (empty for now)
    lines.append("tests: []")
    
    # Include in rename if present
    if yaml_data.get('include_in_rename'):
        lines.append("include_in_rename: true")
    
    return '\n'.join(lines)


def process_directory(input_dir: str, output_dir: str) -> None:
    """Process all JSON files in a directory and output YAML files."""
    input_path = Path(input_dir)
    output_path = Path(output_dir) / 'custom_formats'
    output_path.mkdir(parents=True, exist_ok=True)
    
    json_files = list(input_path.glob('*.json'))
    
    if not json_files:
        print(f"No JSON files found in {input_dir}")
        return
    
    print(f"Found {len(json_files)} JSON files to convert")
    print(f"Output directory: {output_path}")
    print("-" * 50)
    
    for json_file in json_files:
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                json_data = json.load(f)
            
            # Convert to YAML structure
            yaml_data = convert_json_to_yaml_dict(json_data)
            
            # Generate YAML string
            yaml_string = convert_yaml_string(yaml_data)
            
            # Generate output filename
            output_filename = sanitize_filename(yaml_data['name']) + '.yml'
            output_file = output_path / output_filename
            
            # Write YAML file
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(yaml_string + '\n')
            
            print(f"✓ Converted: {json_file.name} -> {output_filename}")
            
        except json.JSONDecodeError as e:
            print(f"✗ Error parsing {json_file.name}: {e}")
        except Exception as e:
            print(f"✗ Error processing {json_file.name}: {e}")
    
    print("-" * 50)
    print(f"Conversion complete! Files saved to: {output_path}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python convert_to_profilarr.py <input_directory> [output_directory]")
        print("\nExample:")
        print("  python convert_to_profilarr.py ./json_exports ./profilarr_db")
        sys.exit(1)
    
    input_dir = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else './profilarr_output'
    
    if not os.path.isdir(input_dir):
        print(f"Error: Input directory '{input_dir}' does not exist")
        sys.exit(1)
    
    process_directory(input_dir, output_dir)


if __name__ == '__main__':
    main()
