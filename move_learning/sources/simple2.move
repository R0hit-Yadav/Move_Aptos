module my_addrx::simple2
{

    const ADD:address=@my_addrx; 

    // #[test_only]
    use std::debug::print;

    // #[test]
    fun simple2_testing()
    {
        print(&@std);
        print(&ADD);
    }
}