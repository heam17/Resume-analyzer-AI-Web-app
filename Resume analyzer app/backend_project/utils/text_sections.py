import re
from typing import Dict, List

# Common resume section headers, matched case-insensitively against a
# line that (mostly) contains just the header itself. Add more variants
# as you encounter resumes that phrase them differently.
SECTION_HEADERS: Dict[str, List[str]] = {
    "skills": [r"technical skills", r"skills", r"core competencies", r"key skills"],
    "projects": [r"projects", r"academic projects", r"personal projects", r"key projects"],
    "experience": [r"experience", r"internships?", r"work experience", r"professional experience", r"employment history"],
    "certifications": [r"certifications?", r"licenses? (and|&) certifications?", r"courses?( completed)?"],
    "education": [r"education", r"academic background", r"qualifications"],
    "summary": [r"summary", r"objective", r"profile", r"about me"],
}

_HEADER_PATTERNS = [
    (key, re.compile(pattern, re.IGNORECASE))
    for key, patterns in SECTION_HEADERS.items()
    for pattern in patterns
]


def split_sections(text: str) -> Dict[str, str]:
    """
    Splits resume text into labeled sections (skills, projects, experience,
    certifications, education, summary) based on common resume headers.

    Only a key that was actually detected as a header in the resume ends
    up in the returned dict — callers use `"projects" in sections` etc. to
    tell "this resume has no Projects section" apart from "it has one but
    it's empty/irrelevant", so scoring doesn't unfairly punish resumes
    with non-standard formatting.

    Anything before the first recognized header (or the entire resume, if
    no headers are found at all) is stored under "general".
    """
    lines = text.splitlines()
    header_positions = []

    for i, line in enumerate(lines):
        clean_line = line.strip().rstrip(':').strip()
        if not clean_line or len(clean_line) > 40:
            continue
        for key, pattern in _HEADER_PATTERNS:
            if pattern.fullmatch(clean_line):
                header_positions.append((i, key))
                break

    sections: Dict[str, str] = {}

    if not header_positions:
        sections["general"] = text
        return sections

    sections["general"] = "\n".join(lines[: header_positions[0][0]])

    for idx, (line_no, key) in enumerate(header_positions):
        start = line_no + 1
        end = header_positions[idx + 1][0] if idx + 1 < len(header_positions) else len(lines)
        chunk = "\n".join(lines[start:end])
        sections[key] = (sections.get(key, "") + "\n" + chunk).strip()

    return sections
