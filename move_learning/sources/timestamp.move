module my_addrx::Timestamp
{
    use std::timestamp;
    use std::debug::print;

    public entry fun time()
    {
        let t1=timestamp::now_microseconds();
        print(&t1);

        let t2=timestamp::now_seconds();
        print(&t2);

    }

    // #[test(framework=@0x1)]
    fun testing(framework:signer)
    {
        timestamp::set_time_has_started_for_testing(&framework);
        time();
    }
}