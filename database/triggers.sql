CREATE VIEW CourseQueuePositions AS 
    SELECT o.course, o.student, 
    (SELECT COUNT(*)+1 
        FROM WaitingList AS i 
        WHERE i.course = o.course AND i.position < o.position
    ) as place 
    FROM WaitingList AS o;


    
-- Note that the value passed to 'status' (either 'registered' or 'waiting') is ignored.
-- Any insert will be viewed as an attempt to register with being put on the waiting 
-- list as a fallback.
CREATE FUNCTION registerFunction()
    RETURNS trigger AS
$$
BEGIN
    -- Check if student is already registered or in the waiting list
    IF EXISTS (SELECT * FROM Registrations WHERE NEW.student = student AND NEW.course = course)
    THEN RAISE EXCEPTION 'Already registered or in waiting list';
    END IF;

    -- Check if student is missing requirements
    IF EXISTS (
        (SELECT requires AS course FROM PrerequisiteOf WHERE NEW.course = course)
        EXCEPT
        (SELECT course FROM PassedCourses WHERE NEW.student = student)
        ) 
    THEN RAISE EXCEPTION 'Missing prerequisits';
    END IF;

    -- Check if student has taken course
    IF EXISTS (SELECT * FROM PassedCourses WHERE NEW.student = student AND NEW.course = course)
    THEN RAISE EXCEPTION 'Already passed course';
    END IF;   

    -- Check if course is full
    IF EXISTS (SELECT * FROM LimitedCourses WHERE NEW.course = code AND capacity <= (SELECT COUNT(*) FROM Registered WHERE NEW.course = course))
    THEN INSERT INTO WaitingList VALUES (NEW.student, NEW.course);
    ELSE
        INSERT INTO Registered VALUES (NEW.student, NEW.course);
    END IF;

    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER registerTrigger
    INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE registerFunction();


CREATE FUNCTION unregisterFunction()
    RETURNS TRIGGER AS
$$
DECLARE
    firstPlaceStudent TEXT;
BEGIN
    -- Set firstPlaceStudent to be first student in waiting list for the course
    SELECT student FROM CourseQueuePositions WHERE course = OLD.course AND place = 1 INTO firstPlaceStudent;
    
    -- Check if the student to be unregistered is registered. 
    IF (OLD.status = 'registered') THEN
        DELETE FROM Registered WHERE (student = OLD.student AND course = OLD.course);
        -- If there is space in the course and there is a student waiting
        IF (
            EXISTS (SELECT * FROM LimitedCourses WHERE OLD.course = code AND capacity > (SELECT COUNT(*) FROM Registered WHERE OLD.course = course)) 
            AND 
            firstPlaceStudent IS NOT NULL
        ) THEN
            -- Remove the first student from the waiting list and add as registered to the course
            DELETE FROM WaitingList WHERE (student = firstPlaceStudent AND course = OLD.course);
            INSERT INTO Registered VALUES (firstPlaceStudent, OLD.course);
        END IF;
    -- Check if the student to be unregistered is inthe waiting list. 
    ELSIF (OLD.status = 'waiting') THEN
        DELETE FROM WaitingList WHERE (student = OLD.student AND course = OLD.course);
    END IF;

    RETURN OLD;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER unregisterTrigger
    INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE PROCEDURE unregisterFunction();


CREATE VIEW GetInfo AS 
    SELECT idnr, jsonb_build_object(
    'student',idnr,
    'name',name,
    'login',login,
    'program',program,
    'branch',(SELECT branch FROM StudentBranches WHERE (StudentBranches.student = Students.idnr)),
    'finished',(SELECT jsonb_agg(
        jsonb_build_object(
            'course',(SELECT name FROM Courses WHERE(FinishedCourses.course = Courses.code)),
            'code',course,
            'credits',credits,
            'grade',grade
        )
    ) FROM FinishedCourses WHERE (FinishedCourses.student = Students.idnr)),
    'registered', (SELECT jsonb_agg(
        jsonb_build_object(
            'course',(SELECT name FROM Courses WHERE(Registrations.course = Courses.code)),
            'code',course,
            'status',status,
            'position',(SELECT place FROM CourseQueuePositions 
                        WHERE (CourseQueuePositions.student = Students.idnr AND CourseQueuePositions.course = Registrations.course))
        )
    ) FROM Registrations WHERE(Registrations.student = Students.idnr)), 
    'seminarCourses',(SELECT seminarCourses FROM SeminarCount WHERE (SeminarCount.student = Students.idnr)),
    'mathCredits',(SELECT mathcredits FROM MathCredits WHERE (MathCredits.student = Students.idnr)),
    'researchCredits',(SELECT researchCredits FROM ResearchCredits WHERE (ResearchCredits.student = Students.idnr)),
    'totalCredits',(SELECT totalCredits FROM AllStudentCredits WHERE (AllStudentCredits.student = Students.idnr)),
    'canGraduate', (SELECT qualified FROM StudentsQualified WHERE (StudentsQualified.student = Students.idnr))
) AS jsondata FROM Students;

