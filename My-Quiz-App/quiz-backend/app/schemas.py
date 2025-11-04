from pydantic import BaseModel
from typing import List, Dict, Optional



class QuestionBase(BaseModel):
    question_text: str
    options: List[str]
    correct_answer: str


class QuestionCreate(QuestionBase):
    pass


class Question(QuestionBase):
    id: int

    class Config:
        from_attributes = True  



class QuizBase(BaseModel):
    title: str
    description: Optional[str] = None


class QuizCreate(QuizBase):
    questions: List[QuestionCreate]


class Quiz(QuizBase):
    id: int
    questions: List[Question] = []

    class Config:
        from_attributes = True  



class SubmitRequest(BaseModel):
    answers: Dict[str, str]  


class SubmitResponse(BaseModel):
    score: int
    total: int
    correct_answers: Dict[str, str]
