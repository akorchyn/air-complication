#!/usr/bin/env python3
"""Derive the beta manifest from production, retaining version and devices."""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BETA_APP_ID = "9dc1cd75bb2a5479a841a40d7d6da39c"
NAMESPACE = "http://www.garmin.com/xml/connectiq"


def generate(destination: Path) -> None:
    tree = ET.parse(ROOT / "manifest.xml")
    app = tree.getroot().find(f"{{{NAMESPACE}}}application")
    if app is None or app.get("id") == BETA_APP_ID:
        raise ValueError("Production must have a distinct application ID")
    app.set("id", BETA_APP_ID)
    ET.register_namespace("iq", NAMESPACE)
    destination.parent.mkdir(parents=True, exist_ok=True)
    tree.write(destination, encoding="utf-8", xml_declaration=True)


if __name__ == "__main__":
    generate(Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "build/beta/manifest.xml")
