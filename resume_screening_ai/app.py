from flask import Flask, render_template, request
from model import load_resumes, evaluate_resumes

app = Flask(__name__)

# Put the DOCX resumes for the selected domain in this folder.
RESUME_FOLDER = "dataset/resumes/ml"


@app.route("/", methods=["GET"])
def home():
    return render_template("index.html")


@app.route("/results", methods=["POST"])
def results():
    skills = [
        skill.strip()
        for skill in request.form.getlist("skills[]")
        if skill.strip()
    ]

    if not skills:
        return render_template(
            "index.html",
            error="Please enter at least one required skill."
        )

    resumes, filenames = load_resumes(RESUME_FOLDER)

    if not resumes:
        return render_template(
            "index.html",
            error="No DOCX resumes were found in dataset/resumes/ml/."
        )

    results = evaluate_resumes(resumes, filenames, skills)

    return render_template(
        "results.html",
        results=results,
        skills=skills
    )


if __name__ == "__main__":
    app.run(debug=True)
