module my_addrx::oprator
{
    use std::debug::print;

    const ADD:u64=0;
    const SUB:u64=1;
    const MUL:u64=2;
    const DIV:u64=3;
    const MOD:u64=4;

    fun arthmetic_oprations(a:u64,b:u64,oprator:u64):u64
    {
        if (oprator==ADD)
        {
            return a+b
        }
        else if (oprator==SUB)
        {
            return a-b
        }
        else if (oprator==MUL)
        {
            return a*b
        }
        else if (oprator==DIV)
        {
            return a/b
        }
        else if (oprator==MOD)
        {
            return a%b
        }
        else
        {
            return 0
        }

    }


    #[test]
    fun test_arthmetic_oprations()
    {
        let result=arthmetic_oprations(10,20,MOD);
        print(&result);


    }



    const HIGHER:u64=0;
    const LOWER:u64=1;
    const HIGHER_EQ:u64=2;
    const LOWER_EQ:u64=3;

    fun eq_oprations(a:u64,b:u64,oprator:u64):bool
    {
        if (oprator==HIGHER)
        {
            return a > b
        }
        else if (oprator==LOWER)
        {
            return a < b
        }
        else if (oprator==HIGHER_EQ)
        {
            return a >= b
        }
        else if (oprator==LOWER_EQ)
        {
            return a <= b
        }
        else
        {
            return false
        }

    }


    #[test]

    fun test_eq_oprations()
    {
        let result=eq_oprations(10,20,LOWER);
        print(&result);

    }
    
}
