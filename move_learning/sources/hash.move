module my_addrx::Hashing
{
    use std::hash;
    use std::aptos_hash;
    use std::bcs;
    use std::debug::print;

    fun hashing_in_move():vector<u8>
    {
        let x:vector<u8> = bcs::to_bytes<u64>(&10);
        // let h=hash::sha2_256(x);
        // h
        let aptos_h=aptos_hash::keccak256(x);
        aptos_h
    }

    #[test]
    fun testing()
    {
        let test=hashing_in_move();
        print(&test);
    }
}