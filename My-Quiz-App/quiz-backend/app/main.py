from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from . import models, schemas
from .database import engine, SessionLocal

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Quiz API")

#  Allow CORS for Flutter frontend (for LAN access too)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency for DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


#  Get all quizzes
@app.get("/quizzes/", response_model=list[schemas.Quiz])
def get_quizzes(db: Session = Depends(get_db)):
    quizzes = db.query(models.Quiz).all()
    return quizzes


#  Get single quiz by ID
@app.get("/quizzes/{quiz_id}", response_model=schemas.Quiz)
def get_quiz(quiz_id: int, db: Session = Depends(get_db)):
    quiz = db.query(models.Quiz).filter(models.Quiz.id == quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    return quiz


#  Create a new quiz with questions
@app.post("/quizzes/", response_model=schemas.Quiz)
def create_quiz(quiz: schemas.QuizCreate, db: Session = Depends(get_db)):
    new_quiz = models.Quiz(title=quiz.title, description=quiz.description)
    db.add(new_quiz)
    db.commit()
    db.refresh(new_quiz)

    # Add related questions
    for q in quiz.questions:
        question = models.Question(
            quiz_id=new_quiz.id,
            question_text=q.question_text,
            options=q.options,
            correct_answer=q.correct_answer
        )
        db.add(question)
    db.commit()

    quiz_with_questions = db.query(models.Quiz).filter(models.Quiz.id == new_quiz.id).first()
    return quiz_with_questions


@app.post("/quizzes/{quiz_id}/submit", response_model=schemas.SubmitResponse)
def submit_quiz(quiz_id: int, submission: schemas.SubmitRequest, db: Session = Depends(get_db)):
    quiz = db.query(models.Quiz).filter(models.Quiz.id == quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")

    questions = db.query(models.Question).filter(models.Question.quiz_id == quiz_id).all()
    score = 0
    correct_answers = {}

    for question in questions:
        user_answer = submission.answers.get(str(question.id))
        correct_answers[str(question.id)] = question.correct_answer
        if user_answer == question.correct_answer:
            score += 1

    return schemas.SubmitResponse(
        score=score,
        total=len(questions),
        correct_answers=correct_answers
    )

from fastapi import HTTPException

@app.delete("/quizzes/{quiz_id}")
def delete_quiz(quiz_id: int, db: Session = Depends(get_db)):
    quiz = db.query(models.Quiz).filter(models.Quiz.id == quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    db.delete(quiz)
    db.commit()
    return {"message": "Quiz deleted successfully"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
