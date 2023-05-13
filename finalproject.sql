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

--QUERIES
--QUERY 1
--overall acceptance for BINT
SELECT
COUNT(*) AS total_applicants,
SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END),
SUM(CASE WHEN program_status = 'Dropped' THEN 1 ELSE 0 END),
SUM(CASE WHEN program_status = 'Terminated' THEN 1 ELSE 0 END),
(SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS acceptance_rate
FROM "Student_information"
WHERE
    program_status IN ('Graduated', 'Dropped', 'Terminated');
    
--QUERY2

--Then rank feeder institutions by admission 
--rates and grades.

--keep
SELECT 
f."feeder_institution",
COUNT(*) AS "total_applications",
COUNT(CASE WHEN s.program_status = 'Graduated' THEN 1 END) AS "total_accepted",
COUNT(CASE WHEN s.program_status = 'Graduated' THEN 1 END) / COUNT(*)::float AS "acceptance_rate"
FROM "Student_information" AS s
JOIN "Feeder" AS f ON s.feeder_id = f.feeder_id
WHERE s.program_status = 'Graduated'
GROUP BY f."feeder_institution"
ORDER BY "acceptance_rate" DESC;

--QUERY 3
--Then calculate the 
--graduation rate for BINT. 


SELECT
COUNT(*) AS "total_students",
SUM(CASE WHEN program_grade_date IS NOT NULL THEN 1 ELSE 0 END) AS "graduated_students",
(SUM(CASE WHEN program_grade_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS "graduation_rate"
FROM "Student_information";

--QUERY 4
--Then calculate the average amount of time it 
--takes AINT students to graduate and BINT 
--students take to graduate.

SELECT 
AVG(DATE_PART('year', AGE(TO_DATE(program_start_date, 'MM/DD/YYYY'), TO_DATE(program_end_date, 'MM/DD/YYYY'))) * 365 +
DATE_PART('day', AGE(TO_DATE(program_start_date, 'MM/DD/YYYY'), TO_DATE(program_end_date, 'MM/DD/YYYY')))) AS "average_time_to_graduation"
FROM "Student_information"
WHERE program_status = 'Graduated';

--PERSONAL QUERY 1
--analyzing different dates and times where graduation is lower, we can look into what causes these delays(in those specific time frames)and how to we can prevent prevent them or work around major delays or reasons that cause an extended graduation time. 

SELECT COUNT(*) as count, program_start_date, program_end_date
FROM "Student_information" as s
WHERE student_id IN (SELECT student_id FROM "Student_information" WHERE gender = 'M')
AND program_status LIKE 'Graduated%'
GROUP BY program_start_date, program_end_date;

--PERSONAL QUERY 2
-- THIS QUERY CALCULATED THE AMOUNT OF PEOPLE AND GRADUATION RATE FROM 
--WHO HAVE GRADUATED THE bint programs from every district and can be used for informed decision-making, allowing the UBIT program to tailor recruitment strategies and support systems to address the specific needs of students from different districts, ultimately increasing enrollment and improving student retention

SELECT district AS "district",
COUNT(*) AS "total_students",
SUM(CASE WHEN program_grade_date IS NOT NULL THEN 1 ELSE 0 END) AS "graduated_students",
(SUM(CASE WHEN program_grade_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS "graduation_rate"
FROM "Student_information"
WHERE district IN ('ORANGE WALK', 'STANN CREEK', 'BELIZE', 'COROZAL', 'STAN CREEK', 'TOLEDO', 'CAYO')
GROUP BY district;


--PERSONAL QUERY 3
--this query should look though the student graduated from each feeder feeder_institutionand return the result. this then we can see which feeder instituation provides the most graduates


SELECT f.feeder_institution,
COUNT(s.student_id) AS total_graduates
FROM "Feeder" AS f
JOIN "Student_information" AS s ON s.feeder_id = f.feeder_id AND s.program_status LIKE 'Grad%'
GROUP BY f.feeder_institution ;

--PERSONAL QUERY 4
--for this query we display average time of graduation for each of the 6 districts. (extention of the previous query). we can use this information to gather the data on best performing districts to see which districts are more likely to graduate first and how long they take at the institution.

WITH graduation_stats AS (
SELECT COUNT(*) AS total_students,
SUM(CASE WHEN program_grade_date IS NOT NULL THEN 1 ELSE 0 END) AS graduated_students,
(SUM(CASE WHEN program_grade_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS graduation_rate
FROM "Student_information"
), district_stats AS (
SELECT
district,
COUNT(*) AS total_students,
SUM(CASE WHEN program_grade_date IS NOT NULL THEN 1 ELSE 0 END) AS graduated_students,
(SUM(CASE WHEN program_grade_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS graduation_rate
FROM "Student_information"
WHERE district IN ('ORANGE WALK', 'STANN CREEK', 'BELIZE', 'COROZAL', 'STAN CREEK', 'TOLEDO', 'CAYO')
GROUP BY district
), average_graduation_time AS (
SELECT 
district,
AVG(DATE_PART('year', AGE(TO_DATE(program_start_date, 'MM/DD/YYYY'), TO_DATE(program_end_date, 'MM/DD/YYYY'))) * 365 +
DATE_PART('day', AGE(TO_DATE(program_start_date, 'MM/DD/YYYY'), TO_DATE(program_end_date, 'MM/DD/YYYY')))) AS average_time_to_graduation
FROM "Student_information"
WHERE program_status = 'Graduated'
AND district IN ('ORANGE WALK', 'STANN CREEK', 'BELIZE', 'COROZAL', 'STAN CREEK', 'TOLEDO', 'CAYO')
GROUP BY district
)
SELECT
graduation_stats.total_students,
graduation_stats.graduated_students,
graduation_stats.graduation_rate,
district_stats.district,
district_stats.total_students,
district_stats.graduated_students,
district_stats.graduation_rate,
average_graduation_time.average_time_to_graduation
FROM graduation_stats
CROSS JOIN district_stats
JOIN average_graduation_time ON district_stats.district = average_graduation_time.district;
