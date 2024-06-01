import os
from flask import Flask, json, request, jsonify
from models import Exam, Subject, Submission, db, User, Student, Program
from competest import competest

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///students.db'
db.init_app(app)
with app.app_context():
     db.create_all()

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

@app.route('/get_programs', methods=['GET'])
def get_programs():
    subject_id = request.args.get('subject_id')
    if not subject_id:
        return jsonify({'error': 'subject_id is required'}), 400

    programs = Program.query.filter_by(subject_id=subject_id).all()
    return jsonify([program.serialize() for program in programs]), 200

# Add a new program
@app.route('/add_program', methods=['POST'])
def add_program():
    data = request.get_json()
    subject_id = data.get('subject_id')
    program_no = data.get('program_no')
    program_info = data.get('program_info')
    test_cases = data.get('test_cases')

    print(subject_id, program_no, program_info, test_cases)
    if not subject_id or not program_no or not program_info or not test_cases:
        return jsonify({'error': 'All fields are required'}), 400
    subject = Subject.query.get(subject_id)
    new_program = Program(
        subject_id=subject.id,
        program_no=program_no,
        program_info=program_info,
        test_cases=test_cases
    )
    db.session.add(new_program)
    db.session.commit()

    return jsonify(new_program.serialize()), 200

# Update an existing program
@app.route('/update_program/<int:program_id>', methods=['PUT'])
def update_program(program_id):
    data = request.get_json()
    program = Program.query.get(program_id)
    if not program:
        return jsonify({'error': 'Program not found'}), 404

    program.program_no = data.get('program_no', program.program_no)
    program.program_info = data.get('program_info', program.program_info)
    program.test_cases = data.get('test_cases', program.test_cases)

    db.session.commit()
    return jsonify(program.serialize()), 200

# Delete a program
@app.route('/delete_program/<int:program_id>', methods=['DELETE'])
def delete_program(program_id):
    program = Program.query.get(program_id)
    if not program:
        return jsonify({'error': 'Program not found'}), 404

    db.session.delete(program)
    db.session.commit()
    return '', 200

@app.route('/semesters', methods=['GET'])
def get_semesters():
    semesters = ['3', '4', '5','6','7', '8']  # Adjust as needed
    return jsonify(semesters)

@app.route('/subjects', methods=['GET'])
def get_subjects():
    subjects = Subject.query.all()
    subject_list = [subject.serialize() for subject in subjects]
    return jsonify(subject_list)

@app.route('/exams', methods=['POST'])
def create_exam():
    data = request.get_json()
    semester = data.get('semester')
    subject_id = data.get('subject_id')

    if not semester or not subject_id:
        return jsonify({'error': 'Missing required fields'}), 400

    new_exam = Exam(semester=int(semester), subject_id=subject_id)
    db.session.add(new_exam)
    db.session.commit()

    return jsonify(new_exam.serialize()), 201

@app.route('/students', methods=['GET'])
def get_students():
    semester = request.args.get('semester')
    if semester:
        filtered_students = Student.query.filter_by(semester=semester).all()
        return jsonify([student.serialize() for student in filtered_students])
    return jsonify([student.serialize() for student in Student.query.all()])

@app.route('/get_exam', methods=['GET'])
def get_exams():
    usn_id = request.args.get('usn_id')
    print(usn_id)
    student_info = Student.query.filter_by(id=usn_id).first()
    #exams = Exam.query.filter_by(semester=student_info.semester).all()
    exams_list = Exam.query.filter_by(semester=student_info.semester).first()
    #exams_list = [exam.serialize() for exam in exams]
    return jsonify(exams_list.serialize())

@app.route('/list_exams', methods=['GET'])
def list_exams():
    exams = Exam.query.all()
    return jsonify([exam.serialize() for exam in exams])

# Endpoint to delete an exam by ID
@app.route('/exams/<int:exam_id>', methods=['DELETE'])
def delete_exam(exam_id):
    exam = Exam.query.get(exam_id)
    if exam is None:
        return jsonify({'error': 'Exam not found'}), 404

    db.session.delete(exam)
    db.session.commit()
    return jsonify({'message': 'Exam deleted'}), 200

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
    new_user = User(username=new_student.usn, password=dob, user_type='student', user_id=new_student.id)
    db.session.add(new_user)
    db.session.commit()

    return jsonify(new_student.serialize()), 201

@app.route('/add_subject', methods=['POST'])
def add_subject():
    data = request.json
    name = data.get('name')
    code = data.get('code')
    scheme = data.get('scheme')

    if not name or not code or not scheme:
        return jsonify({'error': 'Missing required fields'}), 400

    subject = Subject(name=name, code=code, scheme=scheme)
    db.session.add(subject)
    db.session.commit()

    return jsonify({'message': 'Subject added successfully'}), 200

@app.route('/exams/<int:exam_id>/submissions', methods=['GET'])
def get_exam_submissions(exam_id):
    submissions = Submission.query.filter_by(exam_id=exam_id).all()
    result = []
    for submission in submissions:
        student = Student.query.get(submission.student_id)
        submission_info = submission.serialize()
        submission_info['student'] = student.serialize()
        result.append(submission_info)
        print(submission_info['test_cases'])

    return jsonify(result)

@app.route('/submit_code', methods=['POST'])
def submit_code():
    data = request.get_json()
    text = data.get('code')
    programming_language = data.get('language')
    usn = data.get('usn')
    program_no = data.get('program_no')
    subject_id = data.get("subject_id")

    file_name = f"{usn}.program"

    if programming_language == "c++":
        programming_language = "cpp"
        file_name = f"{usn}.cpp"
    test_case_name = f"{usn}.txt"
    if programming_language == "java":
        file_name = f"JavTest.java"
        test_case_name = f"JavTest.txt"

    with open(file_name, 'w') as f:
        f.write(text)
    student_info = Student.query.filter_by(id=usn).first()
    print(program_no, subject_id)
    test_cases = Program.query.filter_by(program_no=program_no, subject_id=subject_id).first()
    test_cases = test_cases.test_cases.replace('\r\n','\r')

    with open(test_case_name, 'w') as test_case_write:
        test_case_write.write(test_cases)
    output = competest.main(programming_language, file_name, None)
    test_cases_text = json.dumps(output)
    code_submission = Submission(exam_id=1,student_id=student_info.id, code=text, language=programming_language, test_cases=test_cases_text)
    db.session.add(code_submission)
    db.session.commit()
    

    os.remove(file_name)  # Remove the temporary file
    os.remove(test_case_name)

    return jsonify(output)

if __name__ == '__main__':
    db.create_all()
    app.run(debug=True)
