module my_addrx::signerdemo
{
    use std::signer;
    use std::debug::print;
    use std::string::{String,utf8};

    const NOT_OWNER:u64= 0;
    const OWNER:address=@my_addrx;

    fun check_owner(account:signer)
    {

        let address_val=signer::borrow_address(&account);
        assert!(signer::address_of(&account) == OWNER, NOT_OWNER);
        print(address_val);
        print(&signer::address_of(&account));
    }

    // #[test(account = @my_addrx)]
    fun test_function(account:signer)
    {
        check_owner(account);
    }


}