module my_addrx::StorageDemo
{

    use std::signer;
    use std::debug::print;
    use std::string::{String, utf8};
    struct StakePool has key , drop
    {
        amount:u64
    }

    fun add_user(account:&signer)
    {
        let amount:u64=0;
        move_to(account,StakePool{amount})
    }

    fun read_pool(account:address):u64 acquires StakePool
    {
        borrow_global<StakePool>(account).amount
    }

    fun stake(account:address) acquires StakePool
    {
        let entry=&mut borrow_global_mut<StakePool>(account).amount;
        *entry+=100;

    }

    fun unstake(account:address) acquires StakePool
    {
        let entry=&mut borrow_global_mut<StakePool>(account).amount;
        *entry=0;

    }

    fun remove_user(account:&signer)  acquires StakePool
    {
        move_from<StakePool>(signer::address_of(account));

    }

    fun confirm_user(account:address):bool 
    {
        exists<StakePool>(account)
    }

    #[test(user=@0x123)]
    fun test_function(user:signer) acquires StakePool
    {
        add_user(&user);
        assert!(read_pool(signer::address_of(&user)) == 0, 1);
        print(&utf8(b"User added Sucessfully"));

        stake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 100, 1);
        print(&utf8(b"User stake 100 tokens "));

        unstake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 0, 1);
        print(&utf8(b"unstake successfully "));


        remove_user(&user);
        assert!(confirm_user(signer::address_of(&user)) == false, 1);
        print(&utf8(b"user removed successfully "));
        
        

    }
    
}