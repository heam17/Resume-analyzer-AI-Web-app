import re
from typing import Dict, List

from utils.text_match import term_present

# Alternate phrasings for common job domains, so "Game Developer" also
# matches a resume that says "gameplay programmer", etc. Extend as you
# see resumes phrase roles differently.
DOMAIN_ALIASES: Dict[str, List[str]] = {
    "game developer": ["game developer", "game development", "game programmer", "gameplay programmer", "game engine developer"],
    "game development": ["game developer", "game development", "game programmer", "gameplay programmer"],
    "full stack developer": ["full stack developer", "full-stack developer", "full stack engineer", "mern stack", "mean stack"],
    "backend developer": ["backend developer", "back-end developer", "backend engineer", "server-side developer"],
    "frontend developer": ["frontend developer", "front-end developer", "ui developer", "react developer"],
    "data scientist": ["data scientist", "data science", "machine learning engineer", "ml engineer"],
    "devops engineer": ["devops engineer", "devops", "site reliability engineer", "sre"],
    "mobile developer": ["mobile developer", "android developer", "ios developer", "flutter developer", "react native developer"],
}


def match_domain(text: str, job_role: str, fuzzy_threshold: int = 85) -> dict:
    """
    Scores whether a chunk of resume text reflects the target job domain.

    Uses the alias dictionary above for common roles. For roles not in
    the dictionary, falls back to a word-overlap score across the
    significant words in the job role, so unusual/unlisted job titles
    degrade gracefully instead of always scoring 0.
    """
    key = job_role.strip().lower()
    aliases = DOMAIN_ALIASES.get(key)

    if aliases:
        result = term_present(text, job_role, aliases=aliases, fuzzy_threshold=fuzzy_threshold)
        return {
            "score": 100.0 if result["matched"] else 0.0,
            "confidence": result["confidence"],
            "method": result["method"],
        }

    words = [w for w in re.findall(r"[a-z]+", key) if len(w) > 2]
    if not words:
        return {"score": 0.0, "confidence": 0.0, "method": "fallback"}

    normalized_text = (text or "").lower()
    found = sum(1 for w in words if w in normalized_text)
    score = round((found / len(words)) * 100, 2)
    return {"score": score, "confidence": score, "method": "word-overlap"}
