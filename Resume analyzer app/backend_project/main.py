import re

from fastapi import FastAPI, UploadFile, File, Form
from typing import List

from utils.parser import extract_text_from_pdf
from utils.experience import extract_experience
from utils.skills import match_skills
from utils.domain import match_domain
from utils.text_sections import split_sections

app = FastAPI()

# ---------------------------------------------------------------------
# Scoring rubric — fixed point values that total 100:
#   Skills match          35   proportional: (matched / required) * 35
#   Domain match           10   proportional: job-role relevance * 10
#   Experience              10   years meet requirement
#   Internship               10   binary — relevant internship found
#   Projects              20/25   20 for 1 matching project, 25 for 2+
#   Certifications      5 each, capped at 10 (max 2 counted)
# ---------------------------------------------------------------------
W_SKILLS = 35
W_DOMAIN = 10
W_EXPERIENCE = 10
W_INTERNSHIP = 10
W_PROJECTS_ONE = 20
W_PROJECTS_MULTI = 25
W_CERT_EACH = 5
W_CERT_CAP = 10


def _count_matching_entries(section_text: str, required_skills: List[str], line_mode: bool = False) -> int:
    """
    Splits a section's text into individual entries — projects separated
    by blank lines, or certifications listed one per line — and counts
    how many entries mention at least one required skill. This scopes the
    skill check to "does THIS project/cert use the skill" rather than
    "does the skill appear anywhere in the resume."
    """
    if not section_text or not section_text.strip():
        return 0

    chunks = section_text.splitlines() if line_mode else re.split(r"\n\s*\n", section_text)

    count = 0
    for chunk in chunks:
        chunk = chunk.strip()
        if len(chunk) < 8:
            continue
        if match_skills(chunk, required_skills)["matched_count"] > 0:
            count += 1
    return count


# -------------------------------
# 🎯 SCORING FUNCTION
# -------------------------------
def score_resume(resume_text: str, skills_input: str, job_role: str, required_exp: int) -> dict:
    required_skills = [s.strip() for s in skills_input.split(",") if s.strip()]
    sections = split_sections(resume_text)

    # 1) Skills (35)
    skill_result = match_skills(resume_text, required_skills)
    skills_component = (skill_result["score"] / 100) * W_SKILLS

    # 2) Domain / job role match (10)
    domain_result = match_domain(resume_text, job_role)
    domain_component = (domain_result["score"] / 100) * W_DOMAIN

    # 3) Experience (10)
    exp_years = extract_experience(resume_text)
    exp_fraction = min(exp_years / required_exp, 1) if required_exp > 0 else 1
    experience_component = exp_fraction * W_EXPERIENCE

    # 4) Internship relevance (10, binary) — internships often live under
    #    an "Experience" header, so check that section for both the word
    #    "intern" and an actual required skill.
    experience_text = sections.get("experience", "")
    has_internship_signal = "intern" in experience_text.lower()
    internship_relevant = (
        match_skills(experience_text, required_skills)["matched_count"] > 0
        if experience_text.strip() else False
    )
    internship_component = W_INTERNSHIP if (has_internship_signal and internship_relevant) else 0

    # 5) Projects (20 for 1 matching project, 25 for 2+)
    matching_projects = _count_matching_entries(sections.get("projects", ""), required_skills)
    if matching_projects >= 2:
        project_component = W_PROJECTS_MULTI
    elif matching_projects == 1:
        project_component = W_PROJECTS_ONE
    else:
        project_component = 0

    # 6) Certifications (5 per matching cert, capped at 10 / 2 certs)
    matching_certs = _count_matching_entries(sections.get("certifications", ""), required_skills, line_mode=True)
    cert_component = min(matching_certs, 2) * W_CERT_EACH

    total = (
        skills_component + domain_component + experience_component
        + internship_component + project_component + cert_component
    )
    total = min(round(total, 2), 100)

    return {
        "score": total,
        "breakdown": {
            "skills": round(skills_component, 2),
            "domain": round(domain_component, 2),
            "experience": round(experience_component, 2),
            "internship": internship_component,
            "projects": project_component,
            "certifications": cert_component,
        },
        "skills_matched": skill_result["matched_count"],
        "skills_total": skill_result["total_count"],
        "skills_breakdown": skill_result["breakdown"],
        "experience_years": exp_years,
        "matching_projects": matching_projects,
        "matching_certifications": matching_certs,
    }


# -------------------------------
# 🏠 HOME ROUTE
# -------------------------------
@app.get("/")
def home():
    return {"message": "AI Resume Screening API Ready 🚀"}


# -------------------------------
# 🔥 FINAL API (UPLOAD + ANALYZE)
# -------------------------------
@app.post("/analyze-job")
async def analyze_job(
    job_role: str = Form(...),
    skills: str = Form(...),
    experience: int = Form(...),
    files: List[UploadFile] = File(...),
):
    results = []

    for file in files:
        try:
            text = extract_text_from_pdf(file.file)
            result = score_resume(text, skills, job_role, experience)
            results.append({
                "name": file.filename,
                "score": result["score"],
                "breakdown": result["breakdown"],
                "skills_matched": result["skills_matched"],
                "skills_total": result["skills_total"],
                "skills_breakdown": result["skills_breakdown"],
                "experience": result["experience_years"],
                "matching_projects": result["matching_projects"],
                "matching_certifications": result["matching_certifications"],
            })
        except Exception as e:
            results.append({
                "name": file.filename,
                "score": 0,
                "experience": 0,
                "error": f"Could not process file: {e}",
            })

    results = sorted(results, key=lambda x: x["score"], reverse=True)

    return {
        "job_role": job_role,
        "total_resumes": len(results),
        "results": results,
    }
