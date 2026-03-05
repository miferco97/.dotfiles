#!/usr/bin/env python3
"""Install dotfiles by creating symlinks based on component deps.yaml files."""

import os
import sys
import yaml
from pathlib import Path


def load_components(repo_dir: Path) -> list[dict]:
    """Load all component deps.yaml files."""
    components_dir = repo_dir / "components"
    components = []
    for comp_dir in sorted(components_dir.iterdir()):
        deps_file = comp_dir / "deps.yaml"
        if deps_file.exists():
            with open(deps_file) as f:
                data = yaml.safe_load(f)
            data["_dir"] = comp_dir
            components.append(data)
    return components


def resolve_source(comp, repo_dir):
    """Resolve the symlink source path for a component."""
    comp_dir = comp["_dir"]
    source = comp_dir / "config"
    if not source.exists():
        return None

    link_target = comp.get("link")
    if not link_target:
        return None

    target_name = Path(link_target).name
    candidate = source / target_name
    if candidate.exists() and candidate.is_file():
        return candidate
    return source


def unlink_components(repo_dir, home_dir, components, only=None, dry_run=False):
    """Remove symlinks for specified components (or all if only=None)."""
    for comp in components:
        link_target = comp.get("link")
        if not link_target:
            continue

        if only and comp["_dir"].name not in only:
            continue

        source = resolve_source(comp, repo_dir)
        if source is None:
            continue

        target = home_dir / link_target

        if target.is_symlink():
            actual = target.resolve()
            if actual == source.resolve():
                print(f"  UNLINK {comp['name']}: {link_target}")
                if not dry_run:
                    target.unlink()
            else:
                print(f"  SKIP   {comp['name']}: {link_target} (points elsewhere)")
        else:
            print(f"  SKIP   {comp['name']}: {link_target} (not a symlink)")

    if dry_run:
        print("\n(dry run -- no changes made)")


def link_components(repo_dir, home_dir, components, only=None, dry_run=False):
    """Create symlinks for specified components (or all if only=None)."""
    for comp in components:
        link_target = comp.get("link")
        if not link_target:
            continue

        if only and comp["_dir"].name not in only:
            continue

        source = resolve_source(comp, repo_dir)
        if source is None:
            print(f"  SKIP {comp['name']} (no config/ directory)")
            continue

        target = home_dir / link_target

        # Ensure parent directory exists
        target.parent.mkdir(parents=True, exist_ok=True)

        # Handle existing target
        if target.is_symlink():
            existing = target.resolve()
            if existing == source.resolve():
                print(f"  OK     {comp['name']}: {link_target} -> {source.relative_to(repo_dir)}")
                continue
            print(f"  UPDATE {comp['name']}: {link_target} (was -> {existing})")
            if not dry_run:
                target.unlink()
        elif target.exists():
            backup = target.with_suffix(target.suffix + ".bak")
            print(f"  BACKUP {comp['name']}: {link_target} -> {backup.name}")
            if not dry_run:
                if target.is_dir():
                    import shutil
                    shutil.move(str(target), str(backup))
                else:
                    target.rename(backup)
        else:
            print(f"  LINK   {comp['name']}: {link_target} -> {source.relative_to(repo_dir)}")

        if not dry_run:
            target.symlink_to(source)

    if dry_run:
        print("\n(dry run -- no changes made)")


def main():
    repo_dir = Path(__file__).resolve().parent
    home_dir = Path.home()
    dry_run = "--dry-run" in sys.argv
    unlink = "--unlink" in sys.argv
    # --only comp1,comp2 to filter components
    only = None
    if "--only" in sys.argv:
        idx = sys.argv.index("--only")
        if idx + 1 < len(sys.argv):
            only = sys.argv[idx + 1].split(",")

    components = load_components(repo_dir)

    if unlink:
        unlink_components(repo_dir, home_dir, components, only=only, dry_run=dry_run)
    else:
        link_components(repo_dir, home_dir, components, only=only, dry_run=dry_run)


if __name__ == "__main__":
    main()
