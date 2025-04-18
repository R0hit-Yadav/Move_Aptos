module addx::counter {
    use std::signer;
    use std::error;
    use std::event;
    use std::debug::print;

    struct Counter has key {
        value: u64,
    }

    public entry fun init_counter(account: &signer) {
        move_to(account, Counter { value: 0 });
    }

    public entry fun increment(account: &signer) acquires Counter {
        let counter = borrow_global_mut<Counter>(signer::address_of(account));
        counter.value = counter.value + 1;
    }

    public fun get_counter(address: address): u64 acquires Counter {
        let counter = borrow_global<Counter>(address);
        counter.value
    }

    #[view]
    public fun view_counter(address: address): u64  acquires Counter
    {
        if (exists<Counter>(address)) 
        {
            let counter = borrow_global<Counter>(address);
            counter.value
        } else {
            0 // Return 0 if the Counter does not exist
        }
    }

    //ed25519-priv-0x3c8a30fdeac6bfbeb00bcaad602dee6f01c12f4166ae2088f53fa5a1d78a3efb
    // #[test(account = @0x374ace93268d3250c156bb8d28837fa1c9c27864e3766fb4abcad08e50d81cef)]
    public fun test_counter_flow(account: &signer) acquires Counter
    {
        init_counter(account);

        let value1 = get_counter(signer::address_of(account));
        assert!(value1 == 0, 101);


        increment(account);


        let value2 = get_counter(signer::address_of(account));
        print(&value2);
        assert!(value2 == 1, 102); 

        increment(account);

        let value3 = get_counter(signer::address_of(account));
        print(&value3);
        assert!(value3 == 2, 103); 

        view_counter(signer::address_of(account));
    }
}

