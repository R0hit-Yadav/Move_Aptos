module rohit_add::attendance 
{
    use std::vector;
    use std::debug::print;
    use std::string::{String,utf8};

    struct Students has store, key, drop, copy
    {
        students: vector<Student>
    }
    struct Student has store, key, drop, copy
    {
        age: u8,
        fname: String,
        lname: String,
        attendanceValue: u8,
        rollNo: u8,
    }

    public fun create_student(_student: Student,_students: &mut Students): Student 
    {
        let newStudent = Student 
        {
            age:_student.age,
            fname:_student.fname,
            lname:_student.lname,
            attendanceValue:_student.attendanceValue,
            rollNo:_student.rollNo,
        };
        add_student(_students, newStudent);
        return newStudent
    }

    public fun add_student(_students: &mut Students, _student: Student) 
    {
        vector::push_back(&mut _students.students, _student);
    }

    public fun incrementAttendance(student: &mut Student)
    {
        student.attendanceValue = student.attendanceValue + 1;
    }

    public fun getParticularStudent(student: &Student): &Student 
    {
        return student
    }

    public fun getTotalnoOfStudent(student : &Students):u64
    {
        let totalStudent = vector::length(&student.students);
        return totalStudent
    }


    #[test]
    fun test_create_student()
    {
        let rohit = Student{
            age: 20,
            fname: utf8(b"Rohit"),
            lname: utf8(b"Yadav"),
            attendanceValue: 0,
            rollNo: 1,
        };
        let stud = Students{ students: (vector[rohit])};

        let dev = Student{
            age:21,
            fname: utf8(b"Dev"),
            lname: utf8(b"Patel"),
            attendanceValue: 0,
            rollNo: 2,
        };
        let stud2 = Students{ students: (vector[dev])};

        let krina = Student{
            age:20,
            fname: utf8(b"Krina"),
            lname: utf8(b"Limbachiya"),
            attendanceValue: 0,
            rollNo: 3,
        };
        let stud3 = Students{ students: (vector[krina])};

        let ronil = Student{
            age:22,
            fname: utf8(b"Ronil"),
            lname: utf8(b"Kansogda"),
            attendanceValue: 0,
            rollNo: 4,
        };
        let stud4 = Students{ students: (vector[ronil])};

        let yash = Student{
            age:19,
            fname: utf8(b"Yash"),
            lname: utf8(b"Parkeh"),
            attendanceValue: 0,
            rollNo: 5,
        };
        let stud5 = Students{ students: (vector[yash])};


        let createStud = create_student(rohit, &mut stud);  
        assert!(createStud.fname == rohit.fname,0);

        let createStud2 = create_student(dev, &mut stud2);
        let createStud3 = create_student(krina, &mut stud3);
        let createStud4 = create_student(ronil, &mut stud4);
        let createStud5 = create_student(yash, &mut stud5);

        incrementAttendance(&mut createStud);
        incrementAttendance(&mut createStud2);
        incrementAttendance(&mut createStud);
        incrementAttendance(&mut createStud);
        incrementAttendance(&mut createStud);
        incrementAttendance(&mut createStud);
        incrementAttendance(&mut createStud3);
        incrementAttendance(&mut createStud2);
        incrementAttendance(&mut createStud);
        incrementAttendance(&mut createStud4);
        incrementAttendance(&mut createStud2);
        incrementAttendance(&mut createStud5);
        incrementAttendance(&mut createStud);
        incrementAttendance(&mut createStud2);
        incrementAttendance(&mut createStud2);


        let p_student = getParticularStudent(&mut createStud);
        print(p_student);
        let p_student2 = getParticularStudent(&mut createStud2);
        print(p_student2);
        let p_student3 = getParticularStudent(&mut createStud3);
        print(p_student3);

    }
}