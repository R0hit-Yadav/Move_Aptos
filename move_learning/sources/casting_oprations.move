address my_addrx
{
    module priceoracle
    {
        public fun btc_price():u128
        {
            return 54200
        }

    }

    module castingdemo
    {
        use my_addrx::priceoracle;
        use std::debug::print;

        fun calculate_swap()
        {
            let price = priceoracle::btc_price();
            let price_w_fee:u64=(price as u64)+5;
            let price_u128:u128=(price_w_fee as u128);
            print(&price_w_fee);
            print(&price_u128);
        }

        #[test]

        fun test_calculate_swap()
        {
            calculate_swap();
        }


    }
}