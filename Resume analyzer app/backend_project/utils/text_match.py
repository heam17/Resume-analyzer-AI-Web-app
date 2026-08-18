import re
from difflib import SequenceMatcher
from typing import Dict, List, Optional

# Deliberately keeps '+', '#', '.', '-' inside tokens so tech terms like
# C#, C++, Node.js, .NET survive tokenization intact.
_TOKEN_PATTERN = re.compile(r"[a-zA-Z0-9][a-zA-Z0-9+#.\-]*")


def normalize(text: str) -> str:
    return (text or "").lower()


def tokenize(text: str) -> List[str]:
    return _TOKEN_PATTERN.findall(normalize(text))


def term_present(text: str, term: str, aliases: Optional[List[str]] = None, fuzzy_threshold: int = 85) -> dict:
    """
    Generic phrase-presence check, shared by skill matching, domain
    matching, and certification matching:

    1. Exact substring match against the term and any known aliases.
    2. Falls back to fuzzy token matching (stdlib difflib — no extra
       dependency) so minor typos/variants not covered by an alias list
       still count, above a similarity threshold.
    """
    normalized_text = normalize(text)
    variants = aliases if aliases else [term.strip().lower()]

    for variant in variants:
        if variant and variant in normalized_text:
            return {"term": term, "matched": True, "confidence": 100.0, "method": "exact"}

    tokens = tokenize(text)
    best_score = 0.0
    for variant in variants:
        for token in tokens:
            score = SequenceMatcher(None, variant, token).ratio() * 100
            if score > best_score:
                best_score = score

    return {
        "term": term,
        "matched": best_score >= fuzzy_threshold,
        "confidence": round(best_score, 1),
        "method": "fuzzy",
    }
