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