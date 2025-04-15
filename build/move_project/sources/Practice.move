// module my_addrx::Sample
// {
//     use std::debug;

//     fun sample_function()
//     {
//         debug::print(&12345);
//     }

//     #[test]
//     fun testing()
//     {
//         sample_function();
//     }
// }


module my_addrx::Practice 
{
    use std::debug::print;
    fun primitive_types()
    {
        //integers
        let a: u8 = 1;
        print(&a);
        let a: u64 = 100;
        print(&a);
        let a: u128 = 123456789;
        print(&a);
        let c=123; // u64
        print(&c);

        //boolean 

        let a:bool = true;
        let b=false;
        print(&a);
        print(&b);

        //address 
        let address1:address=@my_addrx; // names address
        let address2:address=@0x1234;

        print(&address1);
        print(&address2);

    }

    #[test]
    fun testing()
    {
        primitive_types();
    }
}


// functions
module my_addrx::A
{
    // public fun A_foo() : u8
    // {
    //     return 1
    // }
    
    friend my_addrx::B;
    public(friend) fun A_foo() : u8
    {
        return 1
    }
}

module my_addrx::B 
{
    use std::debug::print;
    fun B_foo():u8
    {
        return my_addrx::A::A_foo()
    }

    #[test]
    fun testing()
    {
        let a = B_foo();
        print(&a);
    }
}

//reference types
module my_addrx::References
{
    use std::debug::print;

    fun practice()
    {
        //immutable reference
        let a =100;
        let ima =&a;
          
        print(&a);
        print(ima);

        //mutble reference
        let b = 201;
        let ma=&mut b;
        print(ma);
        *ma=202; // now chage the value
        print(ma);


    }

    #[test]
    fun testing()
    {
        practice();
    }
}

//vectors 
module my_addrx::vectors
{
    use std::debug::print;
    use std::vector;

    fun practice()
    {
        let v:vector<u64> =vector<u64> [10,20,30,40,50];

    
        let a= *vector::borrow(&v,1); // borrow the seconnd element of the vector
        print(&a); // 20
        //borrow_mut
        *vector::borrow_mut(&mut v,1)=150;
        print(vector::borrow(&v,1)); // 20


        //push_back
        vector::push_back(&mut v,1000); // push 1000 to the vector
        print(vector::borrow(&v,5)); // 1000

        //pop_back
        vector::pop_back(&mut v); // pop the last element of the vector
        // print(vector::borrow(&v,5)); // 50
    }

    #[test]
    fun testing()
    {
        practice();

    }

}


//Strings
module my_addrx::Strings
{
    use std::debug::print;
    use std::string::{String,utf8};

    fun practice_string()
    {
        //vector<u8>
        let a:vector<u8> =b"hello world"; // byte string
        print(&a); // hello world in bytes
        print(&utf8(a)); // hello world


        //string data type
        let s:String= utf8(b"hello world"); // string data type
        print(&s);

    }

    #[test]
    fun testing()
    {
        practice_string();
    }
}

//if else statement
module my_addrx::expression_bloks
{
    use std::debug::print;
    use std::string::{String,utf8};

    fun control_flow(marks:u64): vector<u8>
    {
        // if(marks>90)
        // {
        //     print(&utf8(b"A"));

        // }
        // else if(marks>80)
        // {
        //     print(&utf8(b"B"));
        // }
        // else 
        // {
        //     print(&utf8(b"C"));
        // }

        let a = if(marks>80) b"This is Bright Student " else  b"This student need to do some Work"; 
        return a

    }

    #[test]
    fun testing()
    {
       let a = control_flow(60);
       print(&utf8(a));
       let a= control_flow(100);
       print(&utf8(a));

    }

}

//errors 
module my_addrx::Errors 
{
    use std::debug::print;
    use std::string::{String,utf8};

    fun isEven(num:u64)
    {

        // //abort 
        // if(num%2==0)
        // {
        //     print(&utf8(b"Even Number"));
        // }
        // else 
        // {
            
        //     abort 1 
        // }

        assert!(num%2==0, 1);

    }

    #[test]
    fun testing1()
    {
        isEven(9); 
    }
    fun testing2()
    {
        isEven(12); 
    }
}
