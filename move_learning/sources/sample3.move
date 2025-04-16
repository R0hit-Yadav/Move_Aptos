module my_addrx::loops
{
    use std::debug::print;

    fun simple_loop(count:u64):u64
    {
        let value=0;
        for(i in 0..count)
        {
            // print(&i);
            print(&value);
            value+=i;
        };
        value

    }

    fun simple_while(count:u64):u64
    {
        let value=0;
        let i:u64=1;
        while(i<=count)
        {
            value+=1;
            count+=1;
        };
        value
    }
    // #[test]
    fun test_loop()
    {
        let a = simple_loop(10);
        print(&a);

        let w= simple_while(10);
        print(&w);
    }

}