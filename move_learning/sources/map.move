module my_addrx::mapdemo
{
    use std::debug::print;
    use std::simple_map::{SimpleMap, Self};
    use std::string::{String, utf8};

    fun create_map():SimpleMap<u64,String>
    {
        let my_mapp:SimpleMap<u64,String> = simple_map::create();

        simple_map::add(&mut my_mapp,1,utf8(b"UAE"));
        simple_map::add(&mut my_mapp,2,utf8(b"INDIA"));
        simple_map::add(&mut my_mapp,3,utf8(b"POK"));
        simple_map::add(&mut my_mapp,4,utf8(b"NEPAL"));

        return my_mapp
    }

    fun check_map_length(my_mapp:SimpleMap<u64,String>):u64
    {
        let value = simple_map::length(&mut my_mapp);
        return value

    }

     fun remove_from_map(my_mapp:SimpleMap<u64,String>,key:u64):SimpleMap<u64,String>
    {
        simple_map::remove(&mut my_mapp,&key);
        return my_mapp
    }



    #[test]
    fun test_function()
    {
        let my_mapp= create_map();

        let conntry=simple_map::borrow(&mut my_mapp,&2);
        print(conntry);

        let len=check_map_length(my_mapp);
        print(&len);

        let new_map=remove_from_map(my_mapp,3);

        let len=check_map_length(new_map);
        print(&len);
        

    }
}