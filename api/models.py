from flask import json
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Student(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    dob = db.Column(db.String(10), nullable=False)
    usn = db.Column(db.String(10), nullable=False, unique=True)
    semester = db.Column(db.String(10), nullable=False)

    def serialize(self):
        return {
            'id': self.id,
            'name': self.name,
            'dob': self.dob,
            'usn': self.usn,
            'semester': self.semester
        }

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    user_type = db.Column(db.String(20), nullable=False)
    user_id = db.Column(db.String(30), nullable=False)

class Subject(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    code = db.Column(db.String(20), nullable=False)
    scheme = db.Column(db.String(50), nullable=False)
    programs = db.relationship('Program', backref='subject', lazy=True)

    def serialize(self):
        return {
            'id': self.id,
            'name': self.name,
            'code': self.code,
            'scheme': self.scheme,
            'programs': [program.serialize() for program in self.programs]
        }

class Program(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    subject_id = db.Column(db.Integer, db.ForeignKey('subject.id'), nullable=False)
    program_no = db.Column(db.String(20), nullable=False)
    program_info = db.Column(db.String(200), nullable=False)
    test_cases = db.Column(db.Text, nullable=False)

    def serialize(self):
        return {
            'id': self.id,
            'subject_id': self.subject_id,
            'program_no': self.program_no,
            'program_info': self.program_info,
            'test_cases': self.test_cases
        }

class Exam(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    semester = db.Column(db.String(10), nullable=False)
    subject_id = db.Column(db.Integer, db.ForeignKey('subject.id'), nullable=False)
    subject = db.relationship('Subject', backref=db.backref('exams', lazy=True))

    def serialize(self):
        return {
            'id': self.id,
            'semester': self.semester,
            'subject_id' : self.subject_id,
            'subject': self.subject.serialize() if self.subject else None
        }

class Grades(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    usn = db.Column(db.String(20), nullable=False)
    grades = db.Column(db.String(20), nullable=False)
    test_cases_passed =  db.Column(db.Integer, nullable=False)

class Submission(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    exam_id = db.Column(db.Integer, db.ForeignKey('exam.id'), nullable=False)
    student_id = db.Column(db.Integer, db.ForeignKey('student.id'), nullable=False)
    code = db.Column(db.Text, nullable=False)
    language = db.Column(db.String(20), nullable=False)
    test_cases = db.Column(db.String, nullable=False)

    def serialize(self):
        return {
            'id': self.id,
            'exam_id': self.exam_id,
            'student_id': self.student_id,
            'code': self.code,
            'language': self.language,
            'test_cases' : json.loads(self.test_cases) if self.test_cases != None else {}
        }