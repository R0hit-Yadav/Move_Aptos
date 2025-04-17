module my_addrx::Generics
{
    fun example<T>(num:T):T 
    {
        num
    }

    // #[test]
    fun testing()
    {
        let x:u64=example<u64>(10);
        let y:bool=example<bool>(true);

        assert!(x==10,101);
        assert!(y==true,101);
    }
}