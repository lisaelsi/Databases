CREATE TABLE Programs(
    pname TEXT PRIMARY KEY,
    pabbrv TEXT NOT NULL
);

CREATE TABLE Students(
    idnr TEXT PRIMARY KEY,
    CHECK (idnr NOT LIKE '%[^0-9]%'),
    CHECK (CHAR_LENGTH(idnr) = 10),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Programs(pname),
    UNIQUE(login),
    UNIQUE (idnr, program)
);

CREATE TABLE Departments(
    dname TEXT PRIMARY KEY,
    dabbrv TEXT NOT NULL
);

CREATE TABLE Branches(
    name TEXT,
    program TEXT REFERENCES Programs(pname),
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits NUMERIC NOT NULL,
    CHECK (credits >= 0),
    department TEXT NOT NULL,
    FOREIGN KEY (department) REFERENCES Departments(dname)
);

CREATE TABLE LimitedCourses(
    code CHAR(6) PRIMARY KEY,
    capacity INT NOT NULL,
    CHECK (capacity > 0),
    FOREIGN KEY (code) REFERENCES Courses(code)
); 

CREATE TABLE StudentBranches(
    student TEXT PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);
 
CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
); 
 
CREATE TABLE Classified(
    course CHAR(6),
    classification TEXT,
    PRIMARY KEY (course, classification),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (classification) REFERENCES Classifications(name)
); 

CREATE TABLE PrerequisiteOf(
    course CHAR(6),
    requires CHAR(6),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (requires) REFERENCES Courses(code)
);
 
CREATE TABLE MandatoryProgram(
    course CHAR(6),
    program TEXT REFERENCES Programs(pname),
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses(code)
); 
 
CREATE TABLE MandatoryBranch(
    course CHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
); 
 
CREATE TABLE RecommendedBranch(
    course CHAR(6),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);
 
CREATE TABLE Registered(
    student TEXT,
    course CHAR(6),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
); 

CREATE TABLE Taken(
    student TEXT,
    course CHAR(6),
    grade CHAR(1) NOT NULL,
    CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
); 

-- position is either a SERIAL, a TIMESTAMP or the actual position 
CREATE TABLE WaitingList(
    student TEXT,
    course CHAR(6), 
    position TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student, course),
    UNIQUE (course, position),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses(code)
); 

CREATE TABLE HostedBy(
    program TEXT,
    department TEXT,
    PRIMARY KEY (program, department),
    FOREIGN KEY (program) REFERENCES Programs(pname),
    FOREIGN KEY (department) REFERENCES Departments(dname)
);



INSERT INTO Programs VALUES ('Prog1', 'p1');
INSERT INTO Programs VALUES ('Prog2', 'p2');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');
INSERT INTO Students VALUES ('7777777777','Nx','ls7','Prog2');

INSERT INTO Departments VALUES ('Dep1', 'd1');
INSERT INTO Departments VALUES ('Dep2', 'd2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',4);
INSERT INTO LimitedCourses VALUES ('CCC333',2);
INSERT INTO LimitedCourses VALUES ('CCC555',1);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');

INSERT INTO PrerequisiteOf VALUES ('CCC222', 'CCC111');

INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('2222222222','CCC333');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');
INSERT INTO Registered VALUES ('1111111111','CCC555');
INSERT INTO Registered VALUES ('2222222222','CCC555');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');
INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');
INSERT INTO Taken VALUES('1111111111','CCC111','3');
INSERT INTO Taken VALUES('6666666666','CCC111','3');
INSERT INTO Taken VALUES('2222222222','CCC222','U');


-- Removed the position argument since we use timestamp for the position
--INSERT INTO WaitingList VALUES('3333333333','CCC222');
INSERT INTO WaitingList VALUES('3333333333','CCC333');
INSERT INTO WaitingList VALUES('1111111111','CCC333');
INSERT INTO WaitingList VALUES('3333333333','CCC555');

INSERT INTO HostedBy VALUES ('Prog1', 'Dep1');




CREATE VIEW BasicInformation AS 
    SELECT idnr, name, login, Students.program, branch FROM Students LEFT OUTER JOIN StudentBranches ON (student = idnr);

CREATE VIEW FinishedCourses AS
    SELECT student, course, grade, credits FROM Taken JOIN Courses ON (course = code);

CREATE VIEW PassedCourses AS 
    SELECT student, course, credits FROM FinishedCourses WHERE grade != 'U';

CREATE VIEW Registrations AS
    (SELECT student, course, 'registered' as status FROM Registered)
    UNION
    (SELECT student, course, 'waiting' as status FROM WaitingList);

CREATE VIEW UnreadMandatory AS (
    WITH StudentsCoursesByProgram AS (SELECT idnr AS student, course FROM Students, MandatoryProgram WHERE Students.program = MandatoryProgram.program),
         StudentsCoursesByBranch AS (SELECT student, course FROM StudentBranches, MandatoryBranch WHERE StudentBranches.branch = MandatoryBranch.branch AND StudentBranches.program = MandatoryBranch.program)
    (SELECT * FROM StudentsCoursesByProgram UNION SELECT * FROM StudentsCoursesByBranch)
    EXCEPT
    (SELECT student, course FROM PassedCourses)
);

CREATE VIEW PassedCredits AS (
    SELECT student, sum(credits) AS totalCredits
    FROM  PassedCourses 
    GROUP BY student  
);

CREATE VIEW AllStudentCredits AS (
    SELECT idnr AS student, COALESCE(totalCredits, 0) AS totalCredits
    FROM Students LEFT OUTER JOIN PassedCredits
    ON Students.idnr = PassedCredits.student
);

CREATE VIEW MandatoryLeft AS (
    SELECT idnr AS student, COALESCE(mandatoryleft, 0) AS mandatoryLeft
    FROM Students LEFT OUTER JOIN (SELECT student, COUNT(*) AS mandatoryleft 
    FROM UnreadMandatory
    GROUP BY student) AS SparseMandatoryLeft
    ON Students.idnr = SparseMandatoryLeft.student
);

CREATE VIEW MathCredits AS (
    SELECT idnr AS student, COALESCE(mathcredits, 0) as mathcredits
    FROM Students LEFT OUTER JOIN (SELECT student as student, SUM(credits) AS mathCredits FROM PassedCourses JOIN Classified USING (course)
    WHERE classification = 'math'
    GROUP BY student) AS SparseMathCredits
    ON Students.idnr = SparseMathCredits.student
);

CREATE VIEW ResearchCredits AS (
    SELECT idnr AS student, COALESCE(researchCredits, 0) as researchCredits
    FROM Students LEFT OUTER JOIN (SELECT student as student, SUM(credits) AS researchCredits FROM PassedCourses JOIN Classified USING (course)
    WHERE classification = 'research'
    GROUP BY student) AS SparseResearchCredits
    ON Students.idnr = SparseResearchCredits.student
);

CREATE VIEW SeminarCount AS (
    SELECT idnr AS student, COALESCE(seminarCourses, 0) as seminarCourses
    FROM Students LEFT OUTER JOIN (SELECT student as student, COUNT(*) AS seminarCourses FROM PassedCourses JOIN Classified USING (course)
    WHERE classification = 'seminar'
    GROUP BY student
    ) AS SparseSeminarCount
    ON Students.idnr = SparseSeminarCount.student
);

CREATE VIEW RecommendedBranchCredits AS (
    SELECT idnr, branch, RecommendedBranch.course, credits FROM BasicInformation
    LEFT OUTER JOIN RecommendedBranch USING (branch, program)
    LEFT OUTER JOIN PassedCourses ON (RecommendedBranch.course = PassedCourses.course AND BasicInformation.idnr = PassedCourses.student)
);

CREATE VIEW NoBranchStudents AS (
    SELECT idnr AS student, FALSE AS passedRecommended FROM RecommendedBranchCredits WHERE (branch IS NULL)
); 

CREATE VIEW NoRecommendedCoursesStudents AS (
    SELECT idnr AS student, FALSE AS passedRecommended FROM RecommendedBranchCredits WHERE (branch IS NOT NULL AND course IS NULL)
);

CREATE VIEW HasPassedTenCreditsOfRecommended AS (
    SELECT idnr AS student, TRUE AS passedrecommended FROM 
    (SELECT idnr, SUM(credits) AS creditSum FROM RecommendedBranchCredits GROUP BY (idnr)) AS SummedCredits
    WHERE (SummedCredits.creditSum >= 10)
);

CREATE VIEW HasNotPassedTenCreditsOfRecommended AS (
    SELECT idnr AS student, FALSE AS passedrecommended FROM 
    (SELECT idnr, SUM(COALESCE(credits,0)) AS creditSum FROM RecommendedBranchCredits WHERE (branch IS NOT NULL AND course IS NOT NULL) GROUP BY (idnr)) AS SummedCredits
    WHERE (SummedCredits.creditSum < 10)
);

CREATE VIEW HasPassedRecommended AS (
    SELECT * FROM NoBranchStudents
    UNION
    SELECT * FROM NoRecommendedCoursesStudents
    UNION
    SELECT * FROM HasPassedTenCreditsOfRecommended
    UNION
    SELECT * FROM HasNotPassedTenCreditsOfRecommended
);

CREATE VIEW QualificationCriterias AS (
    SELECT * FROM 
    MathCredits 
    NATURAL JOIN ResearchCredits 
    NATURAL JOIN SeminarCount
    NATURAL JOIN HasPassedRecommended
);

CREATE VIEW StudentsQualified AS (
    SELECT student, 
        CASE 
            WHEN (mathCredits >= 20 AND researchCredits >= 10 AND seminarCourses > 0 and passedRecommended) THEN TRUE
            ELSE FALSE
        END AS qualified
    FROM QualificationCriterias
);

CREATE VIEW PathToGraduation AS (
    SELECT * FROM
    AllStudentCredits
    NATURAL JOIN MandatoryLeft
    NATURAL JOIN MathCredits
    NATURAL JOIN ResearchCredits
    NATURAL JOIN SeminarCount
    NATURAL JOIN StudentsQualified
);
