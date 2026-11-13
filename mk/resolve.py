#!/usr/bin/env python3
"""Resolve NELL build dependencies from local Dockerfile FROM instructions."""

import re
import sys
from pathlib import Path

ROOT = Path("nell")
REGISTRY = "oci.badsysadm.local:80"
ARG = re.compile(r"^\s*ARG\s+([A-Za-z_][A-Za-z0-9_]*)=([^\s#]+)")
FROM = re.compile(r"^\s*FROM\s+(?:--\S+\s+)*([^\s#]+)", re.IGNORECASE)
IMAGE = re.compile(
    rf"^{re.escape(REGISTRY)}/(?:src|dep|bin)/([^/]+)/([^:@/]+):([^\s]+)$"
)
VARIABLE = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}")


def find_projects():
    projects = {}
    for path in sorted(ROOT.glob("*/*")):
        if not (path / "03_bin.Dockerfile").is_file():
            continue
        if path.name in projects:
            raise ValueError(f"Duplicate project name: {path.name}")
        projects[path.name] = path
    return projects


def dependencies(package, projects):
    path = projects[package]
    result = {}
    for dockerfile in sorted(path.glob("*Dockerfile")):
        args = {}
        for line in dockerfile.read_text(encoding="utf-8").splitlines():
            if match := ARG.match(line):
                args[match.group(1)] = match.group(2).strip('"\'')
                continue
            match = FROM.match(line)
            if not match:
                continue
            image = IMAGE.match(match.group(1))
            if not image:
                continue
            section, name, version = image.groups()
            if section == path.parent.name and name == package:
                continue
            if name not in projects:
                raise ValueError(f"{dockerfile}: unknown NELL project {section}/{name}")
            if projects[name].parent.name != section:
                raise ValueError(f"{dockerfile}: section mismatch for {section}/{name}")

            def substitute(match):
                variable = match.group(1)
                if variable not in args:
                    raise ValueError(f"{dockerfile}: missing ARG {variable} for {section}/{name}")
                return args[variable]

            version = VARIABLE.sub(substitute, version)
            if "$" in version:
                raise ValueError(f"{dockerfile}: unsupported version expression {version}")
            if name in result and result[name] != version:
                raise ValueError(f"Conflicting versions for {name}: {result[name]} vs {version}")
            result[name] = version
    return result


def resolve(package, projects):
    if package not in projects:
        raise ValueError(f"Unknown project: {package}")
    versions = {}
    ordered = []
    visited = set()
    visiting = set()

    def visit(name):
        if name in visiting:
            raise ValueError(f"Circular dependency: {name}")
        if name in visited:
            return
        visiting.add(name)
        for dependency, version in sorted(dependencies(name, projects).items()):
            previous = versions.setdefault(dependency, version)
            if previous != version:
                raise ValueError(f"Conflicting versions for {dependency}: {previous} vs {version}")
            visit(dependency)
        visiting.remove(name)
        visited.add(name)
        ordered.append(name)

    visit(package)
    return [(name, versions[name]) for name in ordered if name != package]


def main():
    if len(sys.argv) != 2:
        raise ValueError("Usage: resolve.py <package>")
    for name, version in resolve(sys.argv[1], find_projects()):
        print(f"{name}\t{version}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        sys.exit(f"resolve-deps: {error}")
