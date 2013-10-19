public class Test
{
    public double last;

    /*@
      @assignable last;
      @post-meta cosine(x*2*Math.PI) == cosine(x);
    */
    public double cosine(double x)
    {
	System.out.println("COSINE");
	last = Math.cos(x);
	return last;
    }

    /*@
    @post-meta whatever(a) == whatever(shuffle(a));
    @post-meta whatever(shuffle(a)) == \result;
    */
    public int whatever(String[] a) 
    {
    	return a.length;
    }


    public static void main(String[] args)
    {
	Test t = new Test();
	t.cosine(Math.PI);
	System.out.println(t.last);
    }


}
