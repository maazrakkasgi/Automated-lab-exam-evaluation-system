import os
from flask import Flask, request, jsonify
from models import db, User, Student
from competester.competest import competest

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///students.db'
db.init_app(app)
# with app.app_context():
#     db.create_all()

@app.route('/auth', methods=['POST'])
def authenticate_user():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    user_type = data.get('userType')
    print(user_type)

    if not username or not password or not user_type:
        return jsonify({'message': 'Username, password, and userType are required'}), 400

    user = User.query.filter_by(username=username, user_type=user_type).first()
    if user and user.password == password:
        return jsonify({'userId': user.user_id}), 200
    else:
        return jsonify({'message': 'Invalid username or password'}), 401

@app.route('/students', methods=['GET'])
def get_students():
    semester = request.args.get('semester')
    if semester:
        filtered_students = Student.query.filter_by(semester=semester).all()
        return jsonify([student.serialize() for student in filtered_students])
    return jsonify([student.serialize() for student in Student.query.all()])

@app.route('/students', methods=['POST'])
def add_student():
    data = request.get_json()
    name = data.get('name')
    dob = data.get('dob')
    usn = data.get('usn')
    semester = data.get('semester')

    if not name or not dob or not usn or not semester:
        return jsonify({'message': 'Name, dob, usn, and semester are required'}), 400

    new_student = Student(name=name, dob=dob, usn=usn, semester=semester)
    db.session.add(new_student)
    db.session.commit()

    # Set default password as DOB
    new_user = User(username=f'student{new_student.id}', password=dob, user_type='student', user_id=new_student.id)
    db.session.add(new_user)
    db.session.commit()

    return jsonify(new_student.serialize()), 201

@app.route('/run', methods=['POST'])
def submit_code():
    data = request.get_json()
    text = data.get('text')
    programming_language = data.get('programming_language')
    usn = data.get('usn')

    file_name = f"{usn}_text.txt"
    with open(file_name, 'w') as f:
        f.write(text)

    output = competest(programming_language, file_name, test_cases)

    os.remove(file_name)  # Remove the temporary file

    return jsonify({'output': output})

if __name__ == '__main__':
    db.create_all()
    app.run(debug=True)
