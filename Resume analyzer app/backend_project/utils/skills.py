from typing import Dict, List

from utils.text_match import term_present

# Alternate spellings / forms for common tech skills. This is the main
# lever for improving accuracy over time — just add more entries as you
# run into resumes that phrase things differently.
SKILL_ALIASES: Dict[str, List[str]] = {
    "c#": ["c#", "c-sharp", "csharp"],
    "c++": ["c++", "cpp", "c plus plus"],
    ".net": [".net", "dotnet", "dot net"],
    "unity": ["unity", "unity3d", "unity engine"],
    "godot": ["godot", "godot engine"],
    "unreal": ["unreal", "unreal engine", "ue4", "ue5"],
    "node.js": ["node.js", "nodejs", "node"],
    "react": ["react", "react.js", "reactjs"],
    "next.js": ["next.js", "nextjs"],
}


def match_skill(resume_text: str, skill: str, fuzzy_threshold: int = 85) -> dict:
    """Checks whether a single required skill is present in a given
    chunk of text (whole resume, or just a section like Projects)."""
    key = skill.strip().lower()
    aliases = SKILL_ALIASES.get(key, [key])
    result = term_present(resume_text, skill, aliases=aliases, fuzzy_threshold=fuzzy_threshold)
    result["skill"] = result.pop("term")
    return result


def match_skills(text: str, required_skills: List[str]) -> dict:
    """Scores a chunk of text against a list of required skills as
    (skills found) / (skills required)."""
    breakdown = [match_skill(text, skill) for skill in required_skills]
    matched_count = sum(1 for s in breakdown if s["matched"])
    total = len(required_skills) or 1

    return {
        "score": round((matched_count / total) * 100, 2),
        "matched_count": matched_count,
        "total_count": len(required_skills),
        "breakdown": breakdown,
    }
