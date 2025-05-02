module owner::dice
{
    use std::signer;
    use std::vector;
    use aptos_framework::randomness;
    use aptos_framework::account;

    struct DiceRollHistory has key 
    {
        rolls: vector<u64>,
    }

    #[lint::allow_unsafe_randomness]
    public entry fun roll_v0(_account: signer)
    {
        let _ = randomness::u64_range(0,6);
    }

    #[randomness]
    entry fun roll(account: &signer) acquires DiceRollHistory
    {
        let addr = signer::address_of(account);
        let roll_history = if (exists<DiceRollHistory>(addr))
        {
            move_from<DiceRollHistory>(addr)
        }
        else 
        {
            DiceRollHistory { rolls: vector[] }
        };

        let new_roll = randomness::u64_range(0,6);
        vector::push_back(&mut roll_history.rolls, new_roll);
        move_to(account, roll_history);

    }

    public fun get_roll_history(account: address): vector<u64> acquires DiceRollHistory
    {
        if (exists<DiceRollHistory>(account)) 
        {
            let roll_history = borrow_global<DiceRollHistory>(account);
            roll_history.rolls
        } 
        else 
        {
            vector[] // Return an empty vector if no history exists
        }
    }

    #[randomness(max_gas=56789)]
    entry fun roll_v2(_account: signer)
    {
        let _  = randomness::u64_range(0,6);
    }


    #[test(user=@0x123,aptos_framework=@aptos_framework)]
    public fun test(user: &signer) acquires DiceRollHistory
    {

        let user_addr = signer::address_of(user);

        account::create_account_for_test(user_addr);
        
        roll(user);

        let history = get_roll_history(user_addr);
    
    }
}