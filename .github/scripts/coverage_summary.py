"""Writes a coverage table to the GitHub Actions job summary.

Usage:
  coverage_summary.py jacoco <root>   # every build/reports/jacoco/test/jacocoTestReport.xml under <root>
  coverage_summary.py lcov <file> <label>
No external services: the numbers come straight from the reports the build produced.
"""
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def pct(covered: int, total: int) -> str:
    return f"{100 * covered / total:.1f} %" if total else "n/a"


def jacoco(root: Path) -> list[str]:
    rows, tot_c, tot_m = [], 0, 0
    for report in sorted(root.glob("**/build/reports/jacoco/test/jacocoTestReport.xml")):
        module = report.parents[4].relative_to(root).as_posix()
        counters = {c.get("type"): c for c in ET.parse(report).getroot().findall("counter")}
        line = counters.get("LINE")
        if line is None:
            continue
        covered, missed = int(line.get("covered")), int(line.get("missed"))
        tot_c, tot_m = tot_c + covered, tot_m + missed
        rows.append(f"| `{module}` | {pct(covered, covered + missed)} | {covered} / {covered + missed} |")
    rows.append(f"| **Total** | **{pct(tot_c, tot_c + tot_m)}** | {tot_c} / {tot_c + tot_m} |")
    return ["### Backend test coverage (lines, JaCoCo)", "", "| Module | Coverage | Lines |", "|---|---|---|", *rows]


def lcov(file: Path, label: str) -> list[str]:
    found = hit = 0
    for raw in file.read_text().splitlines():
        if raw.startswith("LF:"):
            found += int(raw[3:])
        elif raw.startswith("LH:"):
            hit += int(raw[3:])
    return [f"### `{label}` test coverage (lines)", "", f"**{pct(hit, found)}** ({hit} / {found} lines)"]


if __name__ == "__main__":
    kind = sys.argv[1]
    lines = jacoco(Path(sys.argv[2])) if kind == "jacoco" else lcov(Path(sys.argv[2]), sys.argv[3])
    text = "\n".join(lines) + "\n"
    print(text)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as fh:
            fh.write(text)
