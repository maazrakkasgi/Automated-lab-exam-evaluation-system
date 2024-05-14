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
    user_id = db.Column(db.Integer, nullable=False)