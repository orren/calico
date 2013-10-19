public class Test
{
    public double last;

    /*@
      @assignable last;
 @ensures testCosine(x, \result) == true;
*/
    public double cosine(double x)
    {
	System.out.println("COSINE");
	last = Math.cos(x);
	return last;
    }
 public synchronized boolean testCosine(double x, double result) {
    double __last = last;
    try {
        if (!(cosine(x*2*Math.PI) == cosine(x))) return false;
        return true;
    }
    finally {
        last = __last;
    }
 }


    /*@
 @ensures testWhatever(a, \result) == true;
*/
    public int whatever(String[] a) 
    {
    	return a.length;
    }
 public synchronized boolean testWhatever(String[] a, int result) {
    try {
        if (!(whatever(a) == whatever(RuleProcessor.shuffle(a)))) return false;
        if (!(whatever(RuleProcessor.shuffle(a)) == result)) return false;
        return true;
    }
    finally {
    }
 }



    public static void main(String[] args)
    {
	Test t = new Test();
	t.cosine(Math.PI);
	System.out.println(t.last);
    }


}
