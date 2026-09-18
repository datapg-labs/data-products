#!/usr/bin/env python3
"""Pull-request checks for datapg-labs/data-products (GitHub-hosted runner, no secrets).

For every learner dbt project (top-level folder with dbt_project.yml, except the two
platform samples): README.md present, no dbt packages (the platform build has no
internet), no hard-coded credentials, and `dbt parse` succeeds with dbt-trino and the
same kind of profile the platform supplies. Parsing needs no database connection.
Every problem is printed as a GitHub annotation on the file it concerns.
"""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SAMPLES = {"sub_ledger", "asset_transactions"}
PROJECT_NAME = re.compile(r"^[a-z0-9][a-z0-9_-]{1,63}$")
SECRET = re.compile(r"""(?i)\b(pass(word|wd)?|secret|token|api[_-]?key)\b\s*[:=]\s*["']?([^"'\s{]{6,})""")
PLACEHOLDER = re.compile(r"(env_var|\{\{|\$\{|<[^>]*>|x{4,}|your[_-]|change[_-]?me|example)", re.I)
PROFILE = """pipelines:
  target: prod
  outputs:
    prod:
      type: trino
      method: none
      user: pipelines
      host: trino
      port: 8080
      http_scheme: http
      database: iceberg
      schema: lp_{schema}
      threads: 1
"""

problems = 0


def error(path: Path, message: str, line: int | None = None) -> None:
    global problems
    problems += 1
    loc = f",line={line}" if line else ""
    print(f"::error file={path.relative_to(ROOT).as_posix()}{loc}::{message}")


def projects() -> list[Path]:
    return sorted(d for d in ROOT.iterdir()
                  if d.is_dir() and d.name not in SAMPLES and (d / "dbt_project.yml").is_file())


def check(project: Path) -> None:
    if not PROJECT_NAME.match(project.name):
        error(project, "folder names are lowercase letters, digits, - and _ (the name becomes lp_<name>)")
        return
    if not (project / "README.md").is_file():
        error(project, "add a README.md: what it builds, from which tables, at what grain, who built it")
    for name in ("packages.yml", "dependencies.yml"):
        if (project / name).exists():
            error(project / name, "dbt packages are not available - the platform build has no internet")
    for f in project.rglob("*"):
        if f.is_file() and f.suffix in {".sql", ".yml", ".yaml", ".md"}:
            for n, line in enumerate(f.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
                m = SECRET.search(line)
                if m and not PLACEHOLDER.search(line):
                    error(f, "looks like a hard-coded credential - the platform supplies the connection", n)

    with tempfile.TemporaryDirectory() as tmp:
        Path(tmp, "profiles.yml").write_text(PROFILE.format(schema=project.name.replace("-", "_")))
        r = subprocess.run(
            ["dbt", "parse", "--project-dir", str(project), "--profiles-dir", tmp,
             "--profile", "pipelines", "--target", "prod", "--no-use-colors"],
            capture_output=True, text=True)
        if r.returncode != 0:
            detail = " | ".join(l.strip() for l in (r.stdout + r.stderr).splitlines()
                                if l.strip() and ("Error" in l or "error" in l))[:900]
            error(project / "dbt_project.yml", f"dbt parse failed: {detail or 'see the job log'}")
            print(r.stdout[-4000:])
        else:
            print(f"dbt parse ok: {project.name}")


def main() -> int:
    found = projects()
    print(f"{len(found)} learner project(s): {[p.name for p in found]}")
    for p in found:
        check(p)
    print(f"\n{problems} problem(s) found" if problems else "\nAll checks passed")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
