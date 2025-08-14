#!/usr/bin/env python3
"""
Project file generator using Jinja2 .project-template and YAML configuration.
"""

import json
from pathlib import Path
from typing import Dict, Any

import yaml
from jinja2 import Environment, FileSystemLoader


class ProjectGenerator:
    def __init__(
        self, config_path: str = "project-config.yaml",
        templates_dir: str = ".project-template",
        output_dir: str = ".",
    ):
        self.config_path = Path(config_path)
        self.templates_dir = Path(templates_dir)
        self.output_dir = Path(output_dir)

        self.env = Environment(
            loader=FileSystemLoader(self.templates_dir),
            trim_blocks=True,
            lstrip_blocks=True,
        )

        self.env.filters['tojson'] = self._to_json_filter

    def _to_json_filter(self, value):
        return json.dumps(value)

    def load_config(self) -> Dict[str, Any]:
        with open(self.config_path, 'r') as f:
            return yaml.safe_load(f)

    def generate_file(self, template_path: Path, output_path: Path, context: Dict[str, Any]):
        template_rel_path = template_path.relative_to(self.templates_dir)
        template = self.env.get_template(str(template_rel_path))
        content = template.render(**context)

        output_path.parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, 'w') as f:
            f.write(content)

        print(f"Generated: {output_path}")

    def generate_all(self):
        config = self.load_config()
        self.output_dir.mkdir(parents=True, exist_ok=True)

        for template_path in self.templates_dir.rglob("*.j2"):
            rel_path = template_path.relative_to(self.templates_dir)
            output_name = str(rel_path)[:-3]  # Remove .j2 extension
            output_path = self.output_dir / output_name

            self.generate_file(template_path, output_path, config)


def main():
    generator = ProjectGenerator()
    generator.generate_all()


if __name__ == "__main__":
    main()
