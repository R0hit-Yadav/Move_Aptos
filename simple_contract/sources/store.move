module add::store {
    struct Store has key {
        value: u64,
    }

    public entry fun set(account: &signer, value: u64) {
        move_to(account, Store { value });
    }

    public fun get(addr: address): u64 acquires Store {
        borrow_global<Store>(addr).value
    }
}
