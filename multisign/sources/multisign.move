module addx::multisign
{
    use std::signer;
    use std::debug::print;
    use std::string::{String,utf8};

    struct Message has key
    {
        value:String,
    }

    entry fun init_module(account:&signer)
    {
        move_to(account,Message{value: utf8(b"Hello I Am Rohit1!")});
    }

    public entry fun update_message(admin: &signer, new_message: String) acquires Message
    {
        let message = borrow_global_mut<Message>(signer::address_of(admin));
        message.value = new_message;
    }

    #[view]
    public fun get_message(account:address):String acquires Message
    {
        borrow_global<Message>(account).value
    }
}

//ed25519-priv-0x08200af3d593134b5bbcb386dd3f196a7e8992b772d860aed5463b1c97505b27
//ed25519-priv-0xd5710117cde981be60a5516b4fe7a8a7455e65eac130adf91f34d4ea95bae93c