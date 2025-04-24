/*Practical 1 
===>Address Whitelisting and Fund Deposit<===

==>Overview:

This contract implements an address whitelisting mechanism, allowing only approved users to deposit funds. 
The contract admin can manage the whitelist, including adding and removing addresses individually or in bulk.

===>Features & Requirements:<===
=>1. Admin Controls:

- The contract should have an admin role with exclusive permissions to manage the whitelist.
- The admin can add or remove a single address from the whitelist.
- The admin can perform bulk addition and removal of addresses.

=>2. Whitelisting Mechanism:

- Only whitelisted addresses are allowed to deposit funds into the contract.
- Non-whitelisted addresses should be restricted from depositing funds.

=>3. Fund Deposit & Storage:

- A dedicated resource account should be created at the time of contract initialization.
- All client deposits should be stored in this resource account.
- To store whitelisting user records use different resource accounts.

=>4. Security & Access Control:

- The contract should ensure proper access control mechanisms, restricting critical functions to the admin.
- Deposits should only be accepted from whitelisted addresses.

==>Additional Considerations:

- Provide necessary view functions, 
- Implement an event system to log whitelist modifications and deposits.
- Allow the admin to transfer or withdraw funds if necessary.
- Write Unit test cases
*/





/*
===========>Work Flow<================
module owner @rohit_add --> create_vault() --> RESOURCE

    RESOURCES: Vault    RESOURCES: EventStore
    -balances           -whitelist_events
    -signercapability   -funds_events

[admin @rohit_add]
  |-- create_vault()
  |-- add_to_whitelist(addresses)
  |-- remove_from_whitelist(addresses)
  |-- withdraw(amount, recipient)
  |-- transfer(from, to, amount)

[Whitelisted User @0x123]
  |-- deposit(amount)

*/

module rohit_add::Whitelist {
    use std::signer;
    use std::vector;
    use std::event;
    use std::debug::print;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{AptosCoin, Self};
    use aptos_framework::account;

    // error codes
    /// Unautorized access
    const E_NOT_ADMIN: u64 = 100;
    /// User already whitelisted
    const E_ALREADY_WHITELISTED: u64 = 101;
    /// User not whitelisted
    const E_NOT_WHITELISTED: u64 = 102;
    /// Not enough funds in the account 
    const E_NOT_ENOUGH_FUNDS: u64 = 103;
    /// Account not found in the vault 
    const E_ACCOUNT_NOT_FOUND: u64 = 104;
    /// Invalid operation  
    const E_INVALID_OPERATION: u64 = 105;  

    // for generate resource address
    const VAULT_SEED: vector<u8> = b"SECURE_VAULT";

    // store the list of address 
    struct Whitelist has key 
    {
        users: vector<address>
    }

    // track of all whitelisted users 
    struct Vault has key 
    {
        balances: vector<UserBalance<AptosCoin>>,
        vault_signer: account::SignerCapability
    }

    // amount of coin for each user 
    struct UserBalance<phantom CoinType> has store 
    {
        coins: coin::Coin<CoinType>,
        owner: address
    }

    // event for track whitelist changes
    //whitelist action for add and remove users 
    public enum WhitelistAction has drop, store 
    {
        AddUser,
        RemoveUser
    }
    #[event]
    struct WhitelistEvent has drop, store 
    {
        action: WhitelistAction,
        users: vector<address>
    }

    // event for tracking funds
    // tx types deposit,withdrow or ya transfer 
    public enum TransactionType has drop, store 
    {
        Deposit,
        Withdraw,
        Transfer
    }
    #[event]
    struct FundEvent has drop, store 
    {
        user: address,
        amount: u64,
        type: TransactionType
    }


    // chek admin 
    fun check_admin(addr: address) 
    {
        assert!(addr == @rohit_add, E_NOT_ADMIN);
    }

    //check whitelisted user 
    fun check_whitelisted(list: &vector<address>, addr: address) 
    {
        assert!(vector::contains(list, &addr), E_NOT_WHITELISTED);
    }

    //check not whitelisted user 
    fun check_not_whitelisted(list: &vector<address>, addr: address) 
    {
        assert!(!vector::contains(list, &addr), E_ALREADY_WHITELISTED);
    }

    // check the index of balance 
    fun find_balance_index(balances: &vector<UserBalance<AptosCoin>>,user_addr: address): u64 
    {
        let i = 0;
        let len = vector::length(balances);
        while (i < len) 
        {
            let balance = vector::borrow(balances, i);
            if (balance.owner == user_addr) 
            {
                return i
            };
            i = i + 1;
        };
        len
    }

    //view functions
    #[view]
    public fun is_whitelisted(addr: address): bool acquires Whitelist  //check whitelisted
    {
        let whitelist = borrow_global<Whitelist>(@rohit_add);
        vector::contains(&whitelist.users, &addr)
    }

    #[view]
    public fun get_balance(addr: address): u64 acquires Vault //check balance
    {
        let vault = borrow_global<Vault>(get_vault_address());
        let index = find_balance_index(&vault.balances, addr);
        if (index == vector::length(&vault.balances)) 
        {
            return 0
        };
        let balance = vector::borrow(&vault.balances, index);
        coin::value(&balance.coins)
    }

    #[view]
    public fun get_vault_address(): address  // derrive vault address
    {
        account::create_resource_address(&@rohit_add, VAULT_SEED)
    }

    // main functions
    public entry fun create_vault(admin: &signer)  //crate vault
    {
        let admin_addr = signer::address_of(admin);
        check_admin(admin_addr);

        let (vault_signer, vault_signer_cap) = account::create_resource_account(admin, VAULT_SEED);
        coin::register<AptosCoin>(&vault_signer);

        move_to(&vault_signer, Vault {balances: vector::empty<UserBalance<AptosCoin>>(),vault_signer: vault_signer_cap});
        move_to(admin, Whitelist {users: vector::empty<address>()});
    }

    // add address to the whitelist
    public entry fun add_to_whitelist(admin: &signer, new_users: vector<address>) acquires Whitelist 
    {
        let admin_addr = signer::address_of(admin);
        check_admin(admin_addr);

        let whitelist = borrow_global_mut<Whitelist>(admin_addr);
        let length = vector::length(&new_users);

        for (i in 0..length) 
        {
            check_not_whitelisted(&whitelist.users, new_users[i]);
            vector::push_back(&mut whitelist.users, new_users[i]);
        };

        event::emit(WhitelistEvent 
        {
            action: WhitelistAction::AddUser,
            users: new_users
        });
    }

    // remove address from the whitelist
    public entry fun remove_from_whitelist(admin: &signer, users_to_remove: vector<address>) acquires Whitelist 
    {
        let admin_addr = signer::address_of(admin);

        check_admin(admin_addr);

        let whitelist = borrow_global_mut<Whitelist>(admin_addr);
        let length = vector::length(&users_to_remove);

        for (i in 0..length) 
        {
            check_whitelisted(&whitelist.users, users_to_remove[i]);
            let (found, index) = vector::index_of(&whitelist.users, &users_to_remove[i]);
            if (found) 
            {
                vector::remove(&mut whitelist.users, index);
            }
        };

        event::emit(WhitelistEvent {action: WhitelistAction::RemoveUser,users: users_to_remove});
    }

    // whitelisted user deposit
    public entry fun deposit(user: &signer, amount: u64) acquires Whitelist, Vault 
    {
        let user_addr = signer::address_of(user);
        let whitelist = borrow_global<Whitelist>(@rohit_add);
        check_whitelisted(&whitelist.users, user_addr);

        let vault = borrow_global_mut<Vault>(get_vault_address());
        let coins_to_deposit = coin::withdraw<AptosCoin>(user, amount);

        let index = find_balance_index(&vault.balances, user_addr);
        if (index == vector::length(&vault.balances)) 
        {
            vector::push_back(&mut vault.balances,
                UserBalance<AptosCoin> 
                {
                    coins: coins_to_deposit,
                    owner: user_addr
                }
            );
        } 
        else 
        {
            let balance = vector::borrow_mut(&mut vault.balances, index);
            coin::merge(&mut balance.coins, coins_to_deposit);
        };

        event::emit(FundEvent 
        {
            user: user_addr,
            amount: amount,
            type: TransactionType::Deposit
        });
    }

    //withdraw funds from the  resipient address - admin access
    public entry fun withdraw(admin: &signer, amount: u64, recipient: address) acquires Vault 
    {
        check_admin(signer::address_of(admin));

        let vault = borrow_global_mut<Vault>(get_vault_address());
        let index = find_balance_index(&vault.balances, recipient);
        assert!(index < vector::length(&vault.balances), E_ACCOUNT_NOT_FOUND);

        let balance = vector::borrow_mut(&mut vault.balances, index);
        let coins_to_withdraw = coin::extract(&mut balance.coins, amount);
        coin::deposit(recipient, coins_to_withdraw);

        event::emit(FundEvent 
        {
            user: recipient,
            amount: amount,
            type: TransactionType::Withdraw
        });
    }


    //transder funds from one to another - admin access
    public entry fun transfer(admin: &signer,from: address,to: address,amount: u64) acquires Vault 
    {
        check_admin(signer::address_of(admin));

        let vault = borrow_global_mut<Vault>(get_vault_address());
        let from_index = find_balance_index(&vault.balances, from);
        let to_index = find_balance_index(&vault.balances, to);

        assert!(from_index < vector::length(&vault.balances), E_ACCOUNT_NOT_FOUND);
        let from_balance = vector::borrow_mut(&mut vault.balances, from_index);
        assert!(coin::value(&from_balance.coins) >= amount, E_NOT_ENOUGH_FUNDS);

        let coins = coin::extract(&mut from_balance.coins, amount);

        event::emit(FundEvent 
        {
            user: from,
            amount: amount,
            type: TransactionType::Withdraw
        });

        if (to_index == vector::length(&vault.balances)) 
        {
            vector::push_back(&mut vault.balances,UserBalance<AptosCoin> {coins: coins,owner: to});
        } 
        else 
        {
            let to_balance = vector::borrow_mut(&mut vault.balances, to_index);
            coin::merge(&mut to_balance.coins, coins);
        };

        event::emit(FundEvent 
        {
            user: to,
            amount: amount,
            type: TransactionType::Deposit
        });
    }


    #[test_only]
    fun mint_test_coins(aptos_framework: &signer, recipient: &signer, amount: u64) 
    {
        if (!coin::is_coin_initialized<AptosCoin>()) 
        {
            let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
            coin::destroy_burn_cap(burn_cap);
            coin::destroy_mint_cap(mint_cap);
        };

        coin::register<AptosCoin>(recipient);
        aptos_coin::mint(aptos_framework, signer::address_of(recipient), amount);
    }

    // test cases
    #[test(aptos_framework=@aptos_framework, admin=@rohit_add, user1=@0x123, user2=@0x456, user3=@0x789)]
    public fun test_operations(aptos_framework: &signer,admin: &signer,user1: &signer,user2: &signer,user3: &signer) acquires Whitelist, Vault 
    {
        let admin_addr = signer::address_of(admin);
        let user1_addr = signer::address_of(user1);
        let user2_addr = signer::address_of(user2);
        let user3_addr = signer::address_of(user3);

        account::create_account_for_test(admin_addr);
        account::create_account_for_test(user1_addr);
        account::create_account_for_test(user2_addr);
        account::create_account_for_test(user3_addr);

        mint_test_coins(aptos_framework, admin, 0);
        mint_test_coins(aptos_framework, user1, 100);
        mint_test_coins(aptos_framework, user2, 100);
        mint_test_coins(aptos_framework, user3, 100);

        create_vault(admin);

        let new_users: vector<address> = vector::empty();
        vector::push_back(&mut new_users, user1_addr);
        vector::push_back(&mut new_users, user2_addr);
        // vector::push_back(&mut new_users, user3_addr);
        add_to_whitelist(admin, new_users);
        print(&new_users);

        //try to add duplicate user 
        // let duplicate_users: vector<address> = vector::empty();
        // vector::push_back(&mut duplicate_users, user1_addr);
        // add_to_whitelist(admin, duplicate_users);
        // print(&duplicate_users);

        assert!(is_whitelisted(user1_addr), 1);
        assert!(is_whitelisted(user2_addr), 2);
        // assert!(is_whitelisted(user3_addr), 3);

        // deposit test
        deposit(user1, 50);
        deposit(user2, 50);
        // deposit(user3, 50); // not whitelisted
        print(&get_balance(user1_addr));
        print(&get_balance(user2_addr));
        assert!(get_balance(user1_addr) == 50, 3);
        assert!(get_balance(user2_addr) == 50, 4);


        // transfer test
        transfer(admin, user1_addr, user2_addr, 25);

        print(&get_balance(user1_addr));
        print(&get_balance(user2_addr));

        assert!(get_balance(user1_addr) == 25, 5);
        assert!(get_balance(user2_addr) == 75, 6);

        // withdraw test
        withdraw(admin, 25, user1_addr);

        assert!(get_balance(user1_addr) == 0, 7);
        print(&get_balance(user1_addr));

        withdraw(admin, 75, user2_addr);

        assert!(get_balance(user2_addr) == 0, 8);
        print(&get_balance(user2_addr));

        // whitelist removal test
        let remove_users: vector<address> = vector::empty();
        vector::push_back(&mut remove_users, user1_addr);

        remove_from_whitelist(admin, remove_users);
        assert!(!is_whitelisted(user1_addr), 9);
        print(&remove_users);
    
    }
} 