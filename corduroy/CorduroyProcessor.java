/**
 * 
 * Main class for the Corduroy utility for converting metamorphic
 * properties (stated as JML code annotations) to corresponding JML 
 * assume/ensure statements and test code.
 * 
 *
 * @author Christian Murphy, Columbia University
 * December 2008
 *
 * This code is provided with no support and no guarantees. Neither the 
 * author nor the university will be held responsible for any harm or 
 * damage that results from the use of this code. 
 */

//package edu.columbia.cs.psl.corduroy;

import java.util.*;
import java.io.*;
import java.lang.reflect.*;


public class CorduroyProcessor
{
    private PrintWriter out = null;
    private Scanner in = null;

    // keeps track of the primitive types
    private static ArrayList<String> primitiveTypes = new ArrayList<String>();


    public static void main(String[] args)
    {
	if (args.length < 1)
	{
	    System.out.println("Please specify a file");
	    System.exit(0);
	}

	CorduroyProcessor p = new CorduroyProcessor();
	p.scan(args[0]);
    }


    public CorduroyProcessor()
    {
        primitiveTypes.add("byte");
	primitiveTypes.add("short");
	primitiveTypes.add("int");
	primitiveTypes.add("long");
	primitiveTypes.add("double");
	primitiveTypes.add("float");
	primitiveTypes.add("boolean");
	primitiveTypes.add("char");
	primitiveTypes.add("java.lang.String"); // not technically a primitive, but still works the same!
    }

    public void scan(String origFile)
    {
	// keeps track of what level of curly braces we're at, 0 meaning outside the class
	int level = 0;

	// indicates whether we found a rule, and thus we need the corresponding method name
	boolean ruleFound = false;

	// holds all the rules we found
	ArrayList<String> preRules = new ArrayList<String>();
        ArrayList<String> postRules = new ArrayList<String>();

	// holds the assignable variables
	ArrayList<String> assignable = new ArrayList<String>();

	// whether or not we should be capturing the method name
	boolean captureName = false;

	// whether or not we're supposed to add our test method
	boolean addTestMethod = false;

	// the name of the method we're creating a test for
	String methodName = "";
        
        // flag for recognization of metamorphic "pre-" and "post-" annotations for current method. 0 for none, 1 for post, 2 for post after pre
        int annotationFlag =0;

	try
	{
	    String backup = origFile + ".bak";

	    // make a copy of the original
	    Runtime.getRuntime().exec("cp " + origFile + " " + backup);
            

	    System.out.println("scanning the backed-up file");

	    // to read the file
	    in = new Scanner(new File(backup));

	    // each line that we read
	    String line = "";

	    // to rewrite the original file
	    out = new PrintWriter(new File(origFile));


	    // the name of the original class
	    String className = "";

	    while (in.hasNext())
	    {
		// read the next line of the file in its entirety
		line = in.nextLine();

		// if it's at the top level, just print it out
		if (level == 0 && line.contains("{") == false)
		{
		    out.println(line);
		}

		if (level == 0 && line.contains("class"))
		{
		    // TODO: what if the word "class" is in a comment???

		    //System.out.println("The class is " + line);

		    // this part reads the line containing the class declaration and breaks it apart

		    String permission = line.split("class")[0].trim();
		    //System.out.println("Permission " + permission);

		    String classPart = line.split("class")[1].trim();
		    //System.out.println("ClassPart " + classPart);

		    className = classPart.split(" ")[0].trim();
		    //System.out.println("ClassName " + className);
		    
		}
		else
		{
		    System.out.println(line);

                    if (line.trim().startsWith("@post-meta"))
                    {
                        annotationFlag = 1;
                    }
                    else if (line.trim().startsWith("@pre-meta"))
                    {
                        annotationFlag = 2;
                    }
                    else if (line.trim().endsWith("*/"))
                    {
                        
                    }
                    else if (captureName)
                    {
                        methodName = getMethod(line, false);
                        if ( annotationFlag == 1 )
                        {
			    System.out.println("METHOD " + methodName);
			    String signature = methodName.replace(")", ", \\result)");
			    out.println(" @ensures "+"test"+signature.substring(0,1).toUpperCase() + signature.substring(1, signature.length())+" == true;");
                            out.println("*/");
                        }
                        else if (annotationFlag == 2)
                        {
                            out.println(" @ensures "+"testPost"+methodName.substring(0,1).toUpperCase() + methodName.substring(1, methodName.length())+" == true;");
                            out.println(" @assumes "+"testPre"+methodName.substring(0,1).toUpperCase() + methodName.substring(1, methodName.length())+" == true;");
                            out.println(" */");
                        }
                        out.println(line);
                    }
                    else
                    {
                        out.println(line);
                    }
		}

		
	     		
		// trim it
		line = line.trim();


		// see what level of curly braces we're at
		if (line.contains("{")) level++;
		else if (line.contains("}")) level--;



		// we only care about such things at the method level
		if (level == 1 || line.startsWith("@"))
		{
                    // please start metamorphic annotation with "@ post-meta" or "@ pre-meta", white space between the keyword and the @ cannot be omitted
		    if (line.startsWith("@pre-meta") )
		    {
			// we found a pre-meta rule!!!
			line = line.split("@pre-meta")[1].trim().replace(";", "");
			preRules.add(line);
			//System.out.println("Rule " + line);
			ruleFound = true;
		    }
                    else if (line.startsWith("@post-meta"))
                    {
                        // we found a post-meta rule!!!
			line = line.split("@post-meta")[1].trim().replace(";", "");
			postRules.add(line);
			//System.out.println("Rule " + line);
			ruleFound = true;
                    }
		    else if (line.startsWith("@assignable"))
		    {
			// we found an assignable variable!
			line = line.split("@assignable")[1].trim().replace(";", "");
			//System.out.println("assignable: " + line);
			assignable.add(line);
		    }
		    else if (ruleFound && line.endsWith("*/"))
		    {
			// this means we are at the end of the comment and
			// we need to get ready for the method name
			captureName = true;
			ruleFound = false;
		    }
		    else if (captureName)
		    {
			//System.out.println("The method is " + line);
			methodName = getMethod(line, true);
			captureName = false;
			addTestMethod = true;
		    }
		    else if (addTestMethod)
		    {
			addTestMethod = false;
                        if (postRules.isEmpty()==false)
                            out.println(createTestMethod(postRules, methodName, className, assignable, true));
                        if (preRules.isEmpty()==false)
                            out.println(createTestMethod(preRules, methodName, className, assignable, false));
			preRules.clear();
                        postRules.clear();
			assignable.clear();
		    }			
		}

	    }

	    System.out.println("Done reading " + origFile);

	}
	catch (Exception e)
	{
	    e.printStackTrace();
	}
	finally
	{
	    try { out.flush(); } catch (Exception e) { }
	    try { out.close(); } catch (Exception e) { }
	}

	

    }

    /**
     * Reads in a line and pulls out the name of the method, along with its parameters
     * If includeTypes is true, then it also includes the types of the parameters, like in a declaration.
     * If includeTypes is false, then it removes the parameter types, like in an invocation.
     */
    public static String getMethod(String line, boolean includeTypes)
    {
	// get rid of any words that could be there
	line = line.replace("public", "");
	line = line.replace("private", "");
	line = line.replace("protected", "");
	line = line.replace("static", "");
	line = line.replace("synchronized", "");
	line = line.replace("final", "");
	line = line.replace("{", "");
	line = line.trim();
	
	// scan the line
	Scanner reader = new Scanner(line);

	// the first token will be the return type
	String retType = reader.next();

	// everything else is the method name, including the parameters and their types
	String method = reader.nextLine().trim();
	System.out.println("METHOD: " + method);

	// if we want the parameter types, then add the "result" placeholder and we're done
	if (includeTypes) 
	{
	    method = method.replace(")", ", " + retType + " result)");
	    return method;
	}

	// this is the name of the method
	String name = method.split("\\(")[0];
	System.out.println("NAME:" + name);

	// this is the list of parameters, without the parentheses
	String paramList = method.split("\\(")[1].replace(")", "");
	System.out.println("PARAMLIST: " + paramList);
	

	// if there are no parameters, we're done
	if (paramList.equals("")) return name + "()";

	// this is the array of each individual parameter, with its type
	String[] params = paramList.split(",");

	// start the parens for the return value
	name += "(";

	// now add each param to the list, except the last one
	for (int i = 0; i < params.length - 1; i++)
	{
	    String param = params[i];
	    //System.out.println("PARAM: " + param.trim());
	    name += param.split(" ")[1] + ", ";
	}

	String param = params[params.length - 1];
	//System.out.println("PARAM: " + param.trim());
	name += param.split(" ")[1] + ")";

	return name;

	
    }



    private String createTestMethod(ArrayList<String> rules, String methodName, String className, ArrayList<String> assignable, boolean isPost) throws Exception
    {
	// this is the String representation of the method
	StringBuffer method = new StringBuffer();

        if (isPost)
        {
            String testMethodName = "test" + methodName.substring(0,1).toUpperCase() + methodName.substring(1, methodName.length());
            method.append(" public synchronized boolean " + testMethodName + " {\n");
        }
        else
        {
            String testMethodName = "testPre" + methodName.substring(0,1).toUpperCase() + methodName.substring(1, methodName.length());
            method.append(" public synchronized boolean " + testMethodName + " {\n");
        }

	// keeps track of what got backed up
	ArrayList<String> backedUp = new ArrayList<String>();

	// if there are assignable variables, back them up - need to do this here because of scope
	for (String variable : assignable)
	{
	    // get the type of the variable
	    Class type = getType(className, variable);
	    // if it's null, then the type couldn't be determined
	    if (type != null)
	    {
		// if it's a primitive, just copy it
		if (primitiveTypes.contains(type.getName()))
		{
		    // TODO: what if it's private??
		    method.append("    " + type.getName() + " __" + variable + " = " + variable + ";\n");

		    // add this variable to the list of ones that were backed up
		    backedUp.add(variable);
		}
		// otherwise, see if it implements cloneable
		else
		{
		    // get this class' interfaces
		    Class[] interfaces = type.getInterfaces();
		    // keeps track of whether it implements Cloneable
		    boolean implementsCloneable = false;
		    // loop through and see if Cloneable is one of the intefaces
		    for (Class i : interfaces)
			if (i.getName().equals("java.lang.Cloneable")) implementsCloneable = true;
		    // if it is, then write out the line
		    if (implementsCloneable)
		    {
			// make sure the "clone" method is public so we can call it
			try 
			{ 
			    // if this throws an exception, clone is not public
			    Method m = type.getMethod("clone"); 
			    method.append("    " + type.getName() + " __" + variable + " = (" + type.getName() + ")(" + variable + ".clone());\n");   
			    // add this variable to the list of ones that were backed up
			    backedUp.add(variable);
			}
			catch (NoSuchMethodException e) { }
		    }
		}
	    }
	}

	// everything is in a try block
	method.append("    try {\n");

	//for (String rule : rules) System.out.println(rule);
	for (String rule : rules)
	{
            
            // parse the rule to check for any keyword usage
            rule = parseRule(rule, methodName);
            
	    if (rule.contains("if") || rule.contains("}") || rule.contains("{")) 
                method.append(rule + "\n");
	    else method.append("        if (!(" + rule + ")) return false;\n");
	}

	// if we made it here, everything is okay
	method.append("        return true;\n");

	// end of try block
	method.append("    }\n");

	// now the finally block
	method.append("    finally {\n");

	// if there are backed-up variables, restore them
	for (String variable : backedUp)
	{
	    method.append("        " + variable + " = __" + variable + ";\n");
	}
	
	// end of the finally block
	method.append("    }\n");

	// end of the method
	method.append(" }\n");

	return method.toString();
    }
    
    private static String parseRule(String rule, String methodName)
    {
        // detect keyword "/result" and replace it with the return value of method, prohibited to use on methods with void return
        //rule = rule.replace("\\result", funcall(methodName));
        rule = rule.replace("\\result", "result");
        
        //System.out.println("replacing "+rule);
        

        // grammar: shuffle(param), param can be any List, array of primitive types of objects
        rule = rule.replace("shuffle", "RuleProcessor.shuffle");
        

        // grammar: reverse(param) where param is any List or array
        rule = rule.replace("reverse", "RuleProcessor.reverse");
        

        // grammar: negate(param) where param is an array of numeric primitive types
        rule = rule.replace("negate", "RuleProcessor.negate");
        

        // grammar: valueIn(param1, param2) where param1 is an Object or value in primitive types, param2 is an array of objects or variables of the same type of param1
        rule = rule.replace("valueIn", "RuleProcessor.valueIn");
        
        
        // grammar: inRange(param1, param2, param3), return true if param2 <= param1 <= param3, 3 parameters must be the same type => either Comparable objects or numeric primitive types
        rule = rule.replace("inRange", "RuleProcessor.inRange");

        
        // grammar: approximatelyEqualTo(value1, value2, offset), return true if the difference between value1 and value2 is less than the offset, values compared musst be numeric
        rule = rule.replace("approximatelyEqualTo", "RuleProcessor.approximatelyEqualTo");
        
        return rule;
    }
    
    /**
     * Uses Reflection to determine the type/class of the variable
     */
    private Class getType(String className, String variable)
    {
	try
	{
	    // get the Class
	    Class c = Class.forName(className);

	    // get the Field
	    Field field = c.getField(variable);

	    if (field != null) return field.getType();
	}
	catch (Exception e)
	{
	    // what can you do??
	}

	// if the type could not be determined, return null
	return null;
    }





    private static String funcall(String methodName)
    {

        String name = methodName.split("\\(")[0].trim()+"(";
        
        String arguments = methodName.split("\\(")[1].trim();
        if (arguments.contains(","))
        {
            String[] args = arguments.split(",");
            for (int i=0; i<args.length-1; i++)
            {
                String[] tokens = args[i].trim().split(" ");
                String actualArg = tokens[tokens.length-1];
                name = name + actualArg+",";
            }
            String[] lastTokens = args[args.length-1].trim().split(" ");
            String lastArg = lastTokens[lastTokens.length-1];
            name = name + lastArg;
        }
        else
        {
            String[] tokens = arguments.trim().split(" ");
                String actualArg = tokens[tokens.length-1];
                name = name + actualArg;
        }
        return name;
    }
    
    
    
    
    




}
