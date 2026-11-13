"""Export the repository's maintained Markdown guides to readable PDF snapshots.

Requires reportlab. Run from any directory with Python 3.10 or newer.
"""

from __future__ import annotations

import html
import argparse
import re
from datetime import date
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    Image, LongTable, Paragraph, SimpleDocTemplate, Spacer, TableStyle,
)

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "output" / "pdf"
SOURCES = {
    "README.md": "readme.pdf",
    "docs/10-architecture/architecture-overview.md": "architecture.pdf",
    "docs/80-reference/terraform-reference.md": "TERRAFORM_REFERENCE.pdf",
    "docs/70-validation/validation-summary.md": "VALIDATION_SUMMARY.pdf",
}


def plain(value: str) -> str:
    value = html.unescape(re.sub(r"<br\s*/?>", "\n", value, flags=re.I))
    value = re.sub(r"</?(?:pre|code|a|p|em|strong|table|thead|tr|td|th|tbody|div|span)\b[^>]*>", "", value, flags=re.I)
    return value.translate(str.maketrans({"–": "-", "—": "-", "‑": "-", "→": "->", "’": "'", "“": '"', "”": '"'}))


def inline(value: str) -> str:
    value = plain(value)
    value = re.sub(r"!\[([^\]]*)\]\([^)]+\)", r"\1", value)
    value = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r"\1 (\2)", value)
    value = html.escape(value).replace("\n", "<br/>")
    value = re.sub(r"`([^`]+)`", r'<font name="Courier">\1</font>', value)
    value = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", value)
    return value


def export(source: str, filename: str, snapshot_date: str) -> Path:
    reference = "terraform-reference" in source
    page_size = landscape(A4) if reference else A4
    width = page_size[0] - 36 * mm
    styles = getSampleStyleSheet()
    body = ParagraphStyle("Body", parent=styles["BodyText"], fontName="Helvetica", fontSize=9, leading=13, spaceAfter=6, wordWrap="CJK")
    cell = ParagraphStyle("Cell", parent=body, fontSize=7.2 if reference else 8, leading=10, spaceAfter=0)
    code = ParagraphStyle("Code", parent=body, fontName="Courier", fontSize=7.2, leading=10, leftIndent=6, backColor=colors.HexColor("#f1f5f9"))
    story = []
    lines = (ROOT / source).read_text(encoding="utf-8-sig").splitlines()
    paragraph: list[str] = []
    rows: list[str] = []
    code_lines: list[str] = []
    in_code = False

    def flush_paragraph() -> None:
        if paragraph:
            story.append(Paragraph(inline(" ".join(paragraph)), body))
            paragraph.clear()

    def flush_table() -> None:
        if len(rows) < 2:
            rows.clear()
            return
        parsed = [[part.strip() for part in row.strip().strip("|").split("|")] for row in rows]
        parsed = [parsed[0]] + parsed[2:]
        columns = max(len(row) for row in parsed)
        if columns == 5:
            ratios = [0.22, 0.34, 0.20, 0.15, 0.09]
        else:
            ratios = [1 / columns] * columns
        data = [[Paragraph(inline(value), cell) for value in row + [""] * (columns - len(row))] for row in parsed]
        table = LongTable(data, colWidths=[width * ratio for ratio in ratios], repeatRows=1, splitByRow=1, splitInRow=1, hAlign="LEFT")
        table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e2e8f0")),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#cbd5e1")),
            ("LEFTPADDING", (0, 0), (-1, -1), 5),
            ("RIGHTPADDING", (0, 0), (-1, -1), 5),
            ("TOPPADDING", (0, 0), (-1, -1), 5),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ]))
        story.extend([table, Spacer(1, 7)])
        rows.clear()

    for line in lines:
        if line.strip().startswith("```"):
            flush_paragraph()
            flush_table()
            if in_code:
                story.append(Paragraph(html.escape(plain("\n".join(code_lines))).replace(" ", "&#160;").replace("\n", "<br/>"), code))
                code_lines.clear()
            in_code = not in_code
            continue
        if in_code:
            code_lines.append(line)
            continue
        if line.strip().startswith("|"):
            flush_paragraph()
            rows.append(line)
            continue
        flush_table()
        heading = re.match(r"^(#{1,6})\s+(.+)", line)
        image = re.match(r"!\[[^]]*\]\(([^)]+)\)", line.strip())
        if heading:
            flush_paragraph()
            level = min(len(heading[1]), 3)
            style = ParagraphStyle(f"H{level}", parent=styles[f"Heading{level}"], textColor=colors.HexColor("#12394a"), spaceBefore=12, spaceAfter=7, keepWithNext=True)
            story.append(Paragraph(inline(heading[2]), style))
        elif image:
            flush_paragraph()
            path = (ROOT / source).parent / image[1]
            if path.is_file():
                picture = Image(str(path))
                scale = min(width / picture.imageWidth, 135 * mm / picture.imageHeight)
                picture.drawWidth = picture.imageWidth * scale
                picture.drawHeight = picture.imageHeight * scale
                story.append(picture)
        elif not line.strip():
            flush_paragraph()
        elif re.match(r"^\s*(?:[-*+]\s|\d+[.)]\s|>\s)", line):
            flush_paragraph()
            story.append(Paragraph(inline(line.strip()), body))
        else:
            paragraph.append(line.strip())
    flush_paragraph()
    flush_table()
    destination = OUTPUT / filename
    title = next((plain(line.lstrip("# ")) for line in lines if line.startswith("# ")), Path(source).stem)
    document = SimpleDocTemplate(str(destination), pagesize=page_size, leftMargin=18 * mm, rightMargin=18 * mm, topMargin=19 * mm, bottomMargin=18 * mm, title=title, author="CCOE-Azure", allowSplitting=1)

    def page_footer(canvas, doc):
        canvas.saveState()
        canvas.setFont("Helvetica", 7)
        canvas.setFillColor(colors.HexColor("#475569"))
        canvas.drawString(18 * mm, page_size[1] - 12 * mm, f"Azure Landing Zone | Documentation snapshot | {snapshot_date}")
        canvas.drawString(18 * mm, 10 * mm, source)
        canvas.drawRightString(page_size[0] - 18 * mm, 10 * mm, str(doc.page))
        canvas.restoreState()

    document.build(story, onFirstPage=page_footer, onLaterPages=page_footer)
    return destination


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot-date", type=date.fromisoformat, default=date.today())
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for markdown, pdf in SOURCES.items():
        print(export(markdown, pdf, args.snapshot_date.isoformat()), flush=True)
