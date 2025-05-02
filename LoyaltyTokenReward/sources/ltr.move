/*Practical-2 
=========>Loyalty Reward Token System<=============
==>Overview:

This system is designed to reward customers with digital tokens that act as loyalty points.These tokens can be earned, redeemed, and expire after a set period.

=>Features & Requirements:

1.LoyaltyToken 
    -> A custom coin that represents reward points.
2.Admin Control 
    -> Only the business owner can mint new tokens for customers. It's not directly transferred to the customer, it will be stored somewhere else.
3.Customer Functions
    ->Redeem tokens which admin minted for them.
    ->Check balance.
4.Token Expiry System
    ->Expired tokens cannot be used.
    ->At the time of minting the token, the business owner will provide a token expiry second.
    ->Admin is able to withdraw or burn these expired tokens.

NOTE: Main focus of this practice is to create custom coins, and any operation related to storage uses an object instead of a resource account.

*/


/*
===========>Work Flow<================
module owner @admin_rohit --> init_module --> Create Resource --> Admin Functions --> User Functions --> Error Handling

[admin @admin_rohit]
  |-- initialize module
  |-- create AdminData
        |-- mint cap
        |-- burn cap
        |-- freeze cap
        |-- users vector
  |-- initialize LoyaltyToken
        |-- balance
        |-- expiry

[admin Functions]
  |-- mint tokens
  |-- withdraw expired tokens
  |-- create object
  |-- generate signer
  |-- Update user account
  |-- check expiry
  |-- burn expired tokens

[User Functions]
  |-- redeem tokens 
  |-- token expiry check
  |-- transfer vild tokens

[ERROR handling]
  |-- E_NOT_ADMIN (Auth not admin): 100 
  |-- E_NOT_USER (Auth not User): 101
  |-- E_TOKENS_EXPIRED (token expired): 102

*/


module admin_rohit::ltr {
    use std::signer;
    use std::vector;
    use std::string::{String, utf8};
    use std::debug::print;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_framework::object::{Self, ObjectCore};

    // erros codes 

    /// Unautorized access
    const E_NOT_ADMIN: u64 = 100;
    /// User not found
    const E_NOT_USER: u64 = 101;
    /// Token expired
    const E_TOKENS_EXPIRED: u64 = 102;

    // custom coin 
    struct LoyaltyCoin {}

   // struct 
    struct LoyaltyToken has key 
    {
        balance: Coin<LoyaltyCoin>,
        expiry: u64,
    }


    // User account
    struct UserAccount has store, drop 
    {
        address: address,
        token_addresses: vector<address>
    }

    // admin data 
    struct AdminData has key 
    {
        mint_cap: coin::MintCapability<LoyaltyCoin>,
        burn_cap: coin::BurnCapability<LoyaltyCoin>,
        freeze_cap: coin::FreezeCapability<LoyaltyCoin>,
        users: vector<UserAccount>
    }

    // initialize module
    fun init_module(admin: &signer) 
    {
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<LoyaltyCoin>(
            admin,
            utf8(b"Loyalty Token"),
            utf8(b"LT"),
            2, // decimal
            true //  restricted
        );

        move_to(admin, AdminData {mint_cap,burn_cap,freeze_cap,users: vector::empty()});
    }

    // user index 
    fun find_user_index(users: &vector<UserAccount>, addr: address): u64 
    {
        let i = 0;
        let len = vector::length(users);
        while (i < len) 
        {
            let user = vector::borrow(users, i);
            if (user.address == addr) 
            {
                return i
            };
            i = i + 1;
        };
        len
    }

    // mint token 
    public entry fun mint_tokens(admin: &signer,user: address,amount: u64,expiry_days: u64) acquires AdminData 
    {
        assert!(signer::address_of(admin) == @admin_rohit, E_NOT_ADMIN);
        
        // fetch admin data and store in admin account 
        let admin_data = borrow_global_mut<AdminData>(@admin_rohit);
        let expiry_timestamp = timestamp::now_seconds() + (expiry_days * 86400);// expiry days
        
        // create a new object attech with admin 
        let constructor_ref = object::create_object(@admin_rohit);
        let object_signer = object::generate_signer(&constructor_ref); // signer 
        
        // mit token 
        let tokens = coin::mint<LoyaltyCoin>(amount, &admin_data.mint_cap);
        
        // move loyalty token resourece to the object 
        move_to(&object_signer, LoyaltyToken {balance: tokens,expiry: expiry_timestamp});

        let loyalty_object = object::object_from_constructor_ref<ObjectCore>(&constructor_ref);
        let object_addr = object::object_address(&loyalty_object);

        // check user is already thier or not 
        let index = find_user_index(&admin_data.users, user);
        if (index == vector::length(&admin_data.users)) 
        {
            let user_account = UserAccount 
            {
                address: user,
                token_addresses: vector::empty()
            };
            vector::push_back(&mut admin_data.users, user_account);
        };
        
        let user_account = vector::borrow_mut(&mut admin_data.users, index);
        vector::push_back(&mut user_account.token_addresses, object_addr);

        //transfer token to user 
        object::transfer(admin, loyalty_object, user);
    }

    // redeem token
    public entry fun redeem_tokens(user: &signer) acquires AdminData, LoyaltyToken 
    {
        let user_addr = signer::address_of(user);
        let admin_data = borrow_global_mut<AdminData>(@admin_rohit);

        if (!coin::is_account_registered<LoyaltyCoin>(user_addr)) 
        {
            coin::register<LoyaltyCoin>(user);
        };
        
        //check existance of user 
        let index = find_user_index(&admin_data.users, user_addr);
        assert!(index != vector::length(&admin_data.users), E_NOT_USER);
        
        let user_account = vector::borrow_mut(&mut admin_data.users, index);
        let current_time = timestamp::now_seconds();
        
       vector::for_each_mut(&mut user_account.token_addresses, |token_addr| 
       {
            if (exists<LoyaltyToken>(*token_addr)) 
            {
                let loyalty_token = borrow_global_mut<LoyaltyToken>(*token_addr);

                assert!(loyalty_token.expiry > current_time, E_TOKENS_EXPIRED);
                if (current_time < loyalty_token.expiry) 
                {
                    let amount = coin::value(&loyalty_token.balance);
                    if (amount > 0) 
                    {
                        let tokens = coin::extract(&mut loyalty_token.balance, amount);
                        coin::deposit(user_addr, tokens);
                    };
                };
            };
        });
    }

    public entry fun withdraw_expired_tokens(admin: &signer) acquires AdminData, LoyaltyToken 
    {
        assert!(signer::address_of(admin) == @admin_rohit, E_NOT_ADMIN);
        let admin_addr = signer::address_of(admin);
        
        let admin_data = borrow_global_mut<AdminData>(@admin_rohit);

        if (!coin::is_account_registered<LoyaltyCoin>(admin_addr)) 
        {
            coin::register<LoyaltyCoin>(admin);
        };

        let current_time = timestamp::now_seconds();
        let users_to_remove = vector::empty<u64>();
        
        // itrate through users with index tracking
        let i = 0;
       vector::for_each_mut(&mut admin_data.users, |user_account| 
        {
            let expired_tokens = vector::empty<address>();
            let valid_tokens = vector::empty<address>();

            // first loop tp check the token expiry
            vector::for_each_ref(&user_account.token_addresses, |token_addr| 
            {
                if (exists<LoyaltyToken>(*token_addr)) 
                {
                    let loyalty_token = borrow_global<LoyaltyToken>(*token_addr);
                    if (loyalty_token.expiry <= current_time) 
                    {
                        vector::push_back(&mut expired_tokens, *token_addr);
                    } 
                    else 
                    {
                        vector::push_back(&mut valid_tokens, *token_addr);
                    }
                }
            });

            // expird token remove
            vector::for_each_mut(&mut expired_tokens, |token_addr| 
            {
                let loyalty_token = borrow_global_mut<LoyaltyToken>(*token_addr);
                let amount = coin::value(&loyalty_token.balance);
                if (amount > 0) 
                {
                    let tokens = coin::extract(&mut loyalty_token.balance, amount);
                    coin::burn(tokens, &admin_data.burn_cap);
                };
            });

            // update user account with valid tokens
            user_account.token_addresses = valid_tokens;

            //users with no tokens for removal
            if (vector::is_empty(&user_account.token_addresses)) 
            {
                vector::push_back(&mut users_to_remove, i);
            };
            i = i + 1;
        });

        // Remove empty users (reverse order to preserve indices)
        vector::for_each_mut(&mut users_to_remove, |index| 
        {
            vector::remove(&mut admin_data.users, *index);
        });
    }


    // // withdraw expired tokens 
    // public entry fun withdraw_expired_tokens(admin: &signer) acquires AdminData, LoyaltyToken 
    // {

    //     assert!(signer::address_of(admin) == @admin_rohit, E_NOT_ADMIN);
    //     let admin_addr = signer::address_of(admin);
        
    //     let admin_data = borrow_global_mut<AdminData>(@admin_rohit);

    //       if (!coin::is_account_registered<LoyaltyCoin>(admin_addr)) 
    //     {
    //         coin::register<LoyaltyCoin>(admin);
    //     };

    //     let current_time = timestamp::now_seconds();
    //     let users_to_remove = vector::empty<u64>();
        
    //     let i = 0;

    //     while (i < vector::length(&admin_data.users)) 
    //     {
    //         let user_account = vector::borrow_mut(&mut admin_data.users, i);
    //         let j = 0;
    //         while (j < vector::length(&user_account.token_addresses)) 
    //         {
    //             let token_addr = *vector::borrow(&user_account.token_addresses, j);
    //             if (exists<LoyaltyToken>(token_addr)) 
    //             {
    //                 let loyalty_token = borrow_global_mut<LoyaltyToken>(token_addr);
    //                 if (current_time >= loyalty_token.expiry) 
    //                 {
    //                     let amount = coin::value(&loyalty_token.balance);
    //                     if (amount > 0) 
    //                     {
    //                         let tokens = coin::extract(&mut loyalty_token.balance, amount);
    //                         coin::burn(tokens, &admin_data.burn_cap);
    //                     };
    //                     vector::remove(&mut user_account.token_addresses, j);
    //                     continue
    //                 };
    //             };
    //             j = j + 1;
    //         };
            
    //         if (vector::is_empty(&user_account.token_addresses)) 
    //         {
    //             vector::push_back(&mut users_to_remove, i);
    //         };
    //         i = i + 1;
    //     };
        
    //     // no token no user
    //     let k = vector::length(&users_to_remove);
    //     while (k > 0) 
    //     {
    //         k = k - 1;
    //         let index = vector::pop_back(&mut users_to_remove);
    //         vector::remove(&mut admin_data.users, index);
    //     };
    // }

    // check balance 
    #[view]
    public fun check_balance(user_addr: address): u64 acquires AdminData, LoyaltyToken 
    {
        let admin_data = borrow_global<AdminData>(@admin_rohit);
        let balance = 0;
        
        let index = find_user_index(&admin_data.users, user_addr);
        if (index == vector::length(&admin_data.users)) 
        {
            return balance;
        };
        
        let user_account = vector::borrow(&admin_data.users, index);
        let current_time = timestamp::now_seconds();
        
        vector::for_each_ref(&user_account.token_addresses, |token_addr| 
        {
            if (exists<LoyaltyToken>(*token_addr)) 
            {
                let loyalty_token = borrow_global<LoyaltyToken>(*token_addr);
                if (current_time < loyalty_token.expiry) 
                {
                    balance = balance + coin::value(&loyalty_token.balance);
                };
            };
        });
    
    balance
}

#[view]
public fun check_token_expiry(user_addr: address): vector<u64> acquires AdminData, LoyaltyToken 
{
    let admin_data = borrow_global<AdminData>(@admin_rohit);
    let expiry_list = vector::empty<u64>();

    let index = find_user_index(&admin_data.users, user_addr);
    if (index == vector::length(&admin_data.users)) 
    {
        return expiry_list;
    };

    let user_account = vector::borrow(&admin_data.users, index);
    let current_time = timestamp::now_seconds(); 
    vector::for_each_ref(&user_account.token_addresses, |token_addr| 
    {
        if (exists<LoyaltyToken>(*token_addr)) 
        {
            let loyalty_token = borrow_global<LoyaltyToken>(*token_addr);
            if (loyalty_token.expiry > current_time) 
            {
                let remaining_seconds = loyalty_token.expiry - current_time;
                let remaining_days = remaining_seconds / 86400; 
                vector::push_back(&mut expiry_list, remaining_days);
            } else {
                vector::push_back(&mut expiry_list, 0); 
            };
        };
    });

    expiry_list
}

    #[test(admin=@admin_rohit, user=@0x123, user2=@0x345, aptos_framework=@aptos_framework)]
    fun test_cases(admin: &signer,user: &signer,user2: &signer,aptos_framework: &signer) acquires AdminData, LoyaltyToken 
    {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(user);
        let user2_addr = signer::address_of(user2);

        account::create_account_for_test(admin_addr);
        account::create_account_for_test(user1_addr);
        account::create_account_for_test(user2_addr);

        timestamp::set_time_has_started_for_testing(aptos_framework);
        
        init_module(admin);
        coin::register<LoyaltyCoin>(user);
        coin::register<LoyaltyCoin>(user2);

        //start balance 0
        print(&utf8(b"Starting Balance"));
        print(&utf8(b"User1 balance"));
        print(&check_balance(user1_addr));
        print(&utf8(b"User2 balance"));
        print(&check_balance(user2_addr));

        //after mint
        print(&utf8(b"Mint Some tokens"));
        mint_tokens(admin, user1_addr, 5000, 40);
        print(&utf8(b"User1 balance after mint"));
        print(&check_balance(user1_addr));
        assert!(check_balance(user1_addr) == 5000, 1);

        // check expiry of token of address
        print(&utf8(b"Check user1 tokens expiry in days"));
        print(&check_token_expiry(user1_addr));

        // Redeem tokens
        print(&utf8(b"Redeem tokens"));
        redeem_tokens(user);
        assert!(coin::balance<LoyaltyCoin>(user1_addr) == 5000, 2);
        print(&utf8(b"User1 balance after redeem"));
        print(&check_balance(user1_addr));
        assert!(check_balance(user1_addr) == 0, 3);

        // Test expiry 86400 seconds = 1 day
        print(&utf8(b"Test Expiry"));
        mint_tokens(admin,user1_addr, 100, 2); // 2 days
        mint_tokens(admin,user2_addr, 200, 5); // 5 days

        //3 days later 
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds() + (3 * 86400));
        assert!(check_balance(user1_addr) == 0, 6); //expired
        assert!(check_balance(user2_addr) == 200, 7); // valid 

        print(&utf8(b"User1 balance after 3 days"));
        print(&check_balance(user1_addr));
        print(&utf8(b"User2 balance after 3 days"));
        print(&check_balance(user2_addr));

        print(&utf8(b"Redeem tokens from user2"));
        redeem_tokens(user2);
        assert!(coin::balance<LoyaltyCoin>(user2_addr) == 200, 9);
        
        withdraw_expired_tokens(admin);
        assert!(check_balance(user2_addr) == 0, 5);
        print(&check_balance(user2_addr));


    }

    #[test(admin=@admin_rohit, user=@0x123, aptos_framework=@aptos_framework)]
    #[expected_failure(abort_code = E_NOT_ADMIN)]
    fun test_mint_by_user(admin: &signer,user: &signer,aptos_framework: &signer) acquires AdminData 
    {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(user);
        
        account::create_account_for_test(admin_addr);
        account::create_account_for_test(user1_addr);
        
        timestamp::set_time_has_started_for_testing(aptos_framework);
        init_module(admin);
        
        //mint by user 
        print(&utf8(b"Mint by user (Expected Failure)"));
        mint_tokens(user,user1_addr, 100, 10);
    }

    #[test(admin=@admin_rohit, user=@0x123, aptos_framework=@aptos_framework)]
    #[expected_failure(abort_code = E_NOT_USER)]
    fun test_redeem_token_from_0mint_user(admin: &signer,user: &signer,aptos_framework: &signer) acquires AdminData, LoyaltyToken 
    {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(user);

        account::create_account_for_test(admin_addr);
        account::create_account_for_test(user1_addr);
        
        timestamp::set_time_has_started_for_testing(aptos_framework);
        init_module(admin);

        print(&utf8(b"Redeem token from 0mint user (Expected Failure)"));
        // print(&check_balance(user1_addr));
        redeem_tokens(user);
    }

    #[test(admin=@admin_rohit, user=@0x123, aptos_framework=@aptos_framework)]
    #[expected_failure(abort_code = E_TOKENS_EXPIRED)]
    fun test_redeem_expired_token(admin: &signer,user: &signer,aptos_framework: &signer) acquires AdminData, LoyaltyToken 
    {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(user);

        account::create_account_for_test(admin_addr);
        account::create_account_for_test(user1_addr);

        timestamp::set_time_has_started_for_testing(aptos_framework);
        init_module(admin);
        
        mint_tokens(admin,user1_addr, 100, 2); // 2 days

        //3 days later 
        timestamp::update_global_time_for_test_secs(timestamp::now_seconds() + (3 * 86400));
        assert!(check_balance(user1_addr) == 0, 6); //expired

        print(&utf8(b"Redeem tokens from user1 (Expected Failure)"));
        redeem_tokens(user);

    }
}
