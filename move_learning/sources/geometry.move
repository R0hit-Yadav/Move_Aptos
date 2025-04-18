module my_addrx::point
{
    use std::debug::print;
    struct Point has copy,drop,store 
    {
        x:u64,
        y:u64,
    }
    public fun new(x:u64,y:u64): Point 
    {
        Point{x,y}
    }
    public fun x(p:&Point):u64 
    {
        p.x
    }
    public fun y(p:&Point):u64 
    {
        p.y
    }
    fun abs_sub(a:u64,b:u64):u64{
        if(a < b)
        {
            b - a
        }
        else
        {
            a - b
        }
    }

    public fun dist_square(p1:&Point,p2:&Point):u64 
    {
        let dx = abs_sub(p1.x,p2.x);
        let dy = abs_sub(p1.y,p2.y);
        dx * dx + dy * dy
    }

    #[test]
    fun testing()
    {
        let p1 = new(1,2);
        let p2 = new(4,6);
        let d = dist_square(&p1,&p2);
        print(&d);
        // assert(d == 25);
    }

}