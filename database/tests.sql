-- UNSUCCESSFUL

-- register a student who is already registered, throws 'Already registered or in waiting list'
--INSERT INTO Registrations VALUES ('1111111111', 'CCC333');

-- register a student who is already in waiting list, throws 'Already registered or in waiting list'
--INSERT INTO Registrations VALUES ('2222222222', 'CCC333');

-- register a student who is missing prerequisite courses, throws 'Missing prerequisites'
--INSERT INTO Registrations VALUES ('7777777777', 'CCC222');

-- register a student who has already passed the course, throws 'Already passed course'
--INSERT INTO Registrations VALUES ('4444444444','CCC111');



-- SUCCESSFUL

-- registered to unlimited course, the student-course pair gets added to the Registered table.
INSERT INTO Registrations VALUES ('3333333333','CCC111');

-- registered to limited course, the student-course pair gets added to the Registered table.
INSERT INTO Registrations VALUES ('6666666666','CCC222');


-- waiting for limited course, the student-course pair gets added to the WaitingList table
INSERT INTO Registrations VALUES ('6666666666','CCC333');


-- removed from a waiting list (with additional students in it), the student-course pair gets removed
-- from the WaitingList table. The position changes are reflected in CourseQueuePositions.
DELETE FROM Registrations WHERE (student = '2222222222' AND course = 'CCC333');

-- unregistered from unlimited course, the student-course pair gets removed from the Registered table.
DELETE FROM Registrations WHERE (student = '1111111111' AND course = 'CCC111');


-- unregistered from limited course without waiting list, the student-course pair gets removed from the Registered table.
DELETE FROM Registrations WHERE (student = '5555555555' AND course = 'CCC222');


-- unregistered from limited course with waiting list, the student-course pair gets removed from the Registered table.
-- The student that is first on the waiting list (3333333333) gets added to registered and removed from waiting list
DELETE FROM Registrations WHERE (student = '5555555555' AND course = 'CCC333');


-- unregistered from overfull course with waiting list, the student-course pair gets removed from the Registered table.
-- No student on the waiting list gets added to registered. 
INSERT INTO Registered VALUES ('7777777777', 'CCC333');
INSERT INTO Registered VALUES ('5555555555', 'CCC333');
DELETE FROM Registrations WHERE (student = '5555555555' AND course = 'CCC333');