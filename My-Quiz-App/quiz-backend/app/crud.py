from sqlalchemy.orm import Session
from . import models, schemas


def create_quiz(db: Session, quiz: schemas.QuizCreate):
    db_quiz = models.Quiz(title=quiz.title, description=quiz.description)
    db.add(db_quiz)
    db.commit()
    db.refresh(db_quiz)

    for q in quiz.questions:
        db_question = models.Question(
            question_text=q.question_text, answer=q.answer, quiz_id=db_quiz.id
        )
        db.add(db_question)
    db.commit()
    db.refresh(db_quiz)
    return db_quiz

def get_quizzes(db: Session):
    return db.query(models.Quiz).all()

def get_quiz(db: Session, quiz_id: int):
    return db.query(models.Quiz).filter(models.Quiz.id == quiz_id).first()


def evaluate_quiz(db: Session, quiz_id: int, user_answers: dict):
    quiz = db.query(models.Quiz).filter(models.Quiz.id == quiz_id).first()
    if not quiz:
        return None

    total = len(quiz.questions)
    score = 0
    correct_answers = {}

    for q in quiz.questions:
        correct_answers[q.id] = q.answer
        if q.id in user_answers and user_answers[q.id].strip().lower() == q.answer.strip().lower():
            score += 1

    return {
        "score": score,
        "total": total,
        "correct_answers": correct_answers
    }
