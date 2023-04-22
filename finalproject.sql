CREATE TABLE Feeder (
  feeder_id INT PRIMARY KEY,
  feeder_instituation TEXT 
);

CREATE TABLE Programs(
  program_id  INT PRIMARY KEY,
  prog_name VARCHAR(25) NOT NULL,
  prog_code VARCHAR(25) NOT NULL,
  prog_degree TEXT NOT NULL
);

CREATE TABLE Student_information(
  student_id INT  PRIMARY KEY,
  DOB DATE,
  gender CHAR(1) NOT NULL,
  district TEXT ,
  city TEXT ,
  ethnicity TEXT NOT NULL,
  program_start_date VARCHAR(50) NOT NULL,
  program_end_date VARCHAR(50),
  program_status VARCHAR(50) NOT NULL,
  feeder_id INT,
  program_id INT,
  FOREIGN KEY(feeder_id)
  REFERENCES Feeder(feeder_id),
  FOREIGN KEY(program_id)
  REFERENCES Programs(program_id)
); 
--removed course points not in cvs file
--
CREATE TABLE Courses (
  course_id INT PRIMARY KEY,
  course_code CHAR(20) NOT NULL,
  course_title CHAR(50) NOT NULL,
  course_credits DECIMAL, 
  course_grade CHAR(2),
  course_gpa DECIMAL,
  CGPA DECIMAL,
  comments VARCHAR(50),
  semester_id INT
);

CREATE TABLE Enrolled_Semester (
  semester_id INT PRIMARY KEY,
  student_id INT,
  sem VARCHAR(25),
  sem_earned INT ,
  sem_points DECIMAL,
  semester_attempted INT,
  sem_gpa DECIMAL,
  program_grade_date DATE,
  FOREIGN KEY(student_id)
  REFERENCES Student_information(student_id)
);

CREATE TABLE Esem(
  Esem_id INT PRIMARY KEY,
  semester_id INT NOT NULL,
  course_id INT NOT NULL,
  program_id INT,
  FOREIGN KEY(program_id)
  REFERENCES Programs(program_id),
  FOREIGN KEY(course_id)
  REFERENCES Courses(course_id),
  FOREIGN KEY(semester_id)
  REFERENCES Enrolled_Semester(semester_id)
); 