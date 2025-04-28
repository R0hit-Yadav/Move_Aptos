module rohit_add::attendance 
{
    use std::vector;
    use std::debug::print;
    use std::string::{String,utf8};
    use aptos_framework::account;
    use std::signer;

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

    entry fun init_module(account: &signer) 
    {
        move_to(account, Students { students: vector::empty() });
    }

    public fun create_student(account: &signer,_student:Student) acquires Students
    {
        let students = borrow_global_mut<Students>(signer::address_of(account));
        let newStudent = Student 
        {
            age:_student.age,
            fname:_student.fname,
            lname:_student.lname,
            attendanceValue:_student.attendanceValue,
            rollNo:_student.rollNo,
        };
        add_student(students, newStudent);
    }

    public fun add_student(_students: &mut Students, _student: Student) 
    {
        vector::push_back(&mut _students.students, _student);
    }

     public entry fun increment_attendance(account: &signer, roll_no: u8) acquires Students
     {
        let students = borrow_global_mut<Students>(signer::address_of(account));
        let i = 0;
        while (i < vector::length(&students.students)) 
        {
            let student = vector::borrow_mut(&mut students.students, i);
            if (student.rollNo == roll_no) 
            {
                student.attendanceValue = student.attendanceValue + 1;
                break;
            };
            i = i + 1;
        };
    }

    #[view]
    public fun get_student(account: address, roll_no: u8): Student acquires Students {
        let students = borrow_global<Students>(account);
        let i = 0;
        while (i < vector::length(&students.students)) {
            let student = vector::borrow(&students.students, i);
            if (student.rollNo == roll_no) {
                return *student;
            };
            i = i + 1;
        };
        abort 1 // Student not found
    }

    #[view]
     public fun get_total_students(account: address): u64 acquires Students {
        let students = borrow_global<Students>(account);
        vector::length(&students.students)
    }


    #[test(admin=@rohit_add,aptos_framework=@aptos_framework)]
    fun test_create_student(admin: &signer) acquires Students
    {

        let admin_addr = signer::address_of(admin);
        account::create_account_for_test(admin_addr);

        init_module(admin);

        let rohit = Student{
            age: 20,
            fname: utf8(b"Rohit"),
            lname: utf8(b"Yadav"),
            attendanceValue: 0,
            rollNo: 1,
        };
        create_student(admin, rohit);

        let dev = Student{
            age:21,
            fname: utf8(b"Dev"),
            lname: utf8(b"Patel"),
            attendanceValue: 0,
            rollNo: 2,
        };
        create_student(admin, dev);

        let krina = Student{
            age:20,
            fname: utf8(b"Krina"),
            lname: utf8(b"Limbachiya"),
            attendanceValue: 0,
            rollNo: 3,
        };
        create_student(admin,krina);

        let ronil = Student{
            age:22,
            fname: utf8(b"Ronil"),
            lname: utf8(b"Kansogda"),
            attendanceValue: 0,
            rollNo: 4,
        };
        create_student(admin,ronil);

        let yash = Student{
            age:19,
            fname: utf8(b"Yash"),
            lname: utf8(b"Parkeh"),
            attendanceValue: 0,
            rollNo: 5,
        };
        create_student(admin,yash);



        increment_attendance(admin,1);
        increment_attendance(admin,2);
        increment_attendance(admin,1);
        increment_attendance(admin,3);
        increment_attendance(admin,4);
        increment_attendance(admin,3);
        increment_attendance(admin,3);
        increment_attendance(admin,5);
        increment_attendance(admin,1);


        let rohit_data = get_student(admin_addr, 1);
        print(&rohit_data);
        let dev_data = get_student(admin_addr, 2);
        print(&dev_data);
        let krina_data = get_student(admin_addr,3);
        print(&krina_data);

    }
}