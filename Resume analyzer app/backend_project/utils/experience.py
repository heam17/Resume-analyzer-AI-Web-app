import re

# Catches "5 years", "5+ years", "5 yrs", "5-year" — the old version only
# matched the literal "X years" pattern and missed common variants.
_PATTERNS = [
    r'(\d+)\s*\+?\s*years?',
    r'(\d+)\s*\+?\s*yrs?',
]


def extract_experience(text: str) -> int:
    text = (text or "").lower()
    years = []
    for pattern in _PATTERNS:
        years += [int(m) for m in re.findall(pattern, text)]
    return max(years) if years else 0
