module my_addrx::bitwise_bitshift
{
    // bitwise  | or ,& and,^ xor
    use std::debug::print;

    fun bitwise_or(a:u64,b:u64):u64
    {
        return a|b
    }
    fun bitwise_and(a:u64,b:u64):u64
    {
        return a&b
    }
    fun bitwise_xor(a:u64,b:u64):u64
    {
        return a^b 
    }

    //bitshift  | <<,>>>

    fun bitshift_left(a:u64,times:u8):u64
    {
        return a << times
    }
    fun bitshift_right(a:u64,times:u8):u64
    {
        return a >> times
    }


    // #[test]
    fun test_bitwise()
    {
        let result=bitwise_or(7,4);
        print(&result);

        let result=bitwise_and(7,4);
        print(&result);

        let result=bitwise_xor(7,4);
        print(&result);
    }

    // #[test]
    fun test_bitshift()
    {
        let result=bitshift_left(7,2);
        print(&result);

        let result=bitshift_right(7,2);
        print(&result);
    }
}