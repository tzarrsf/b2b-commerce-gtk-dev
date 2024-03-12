/**
 * @description       : This is a poor man's version of something like the C# Convert static Utility, mainly to facilitate type
 *                      conversion with collections which Apex treats with a pseudo-Generic approach but does not let you use in
 *                      a format like this as code:
 *
*                       public static List<T> GetQueryResult<T>(sObject sObjects)
 *                      {
 *                          var list = new List<T>();
 *                          // Convert it or instantiate a collection of a specific object type from another
 *                          return list;
 *                      }
 *
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-11-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class Convert {

    private static List<String> toStringList(List<Object> objectList)
    {
        List<String> results = new List<String>();

        for(Object o : objectList)
        {
            if(o instanceOf String) {
                results.add((String)o);
            }
        }

        return results;
    }

    private static List<Integer> toIntegerList(List<Object> objectList)
    {
        List<Integer> results = new List<Integer>();

        for(Object o : objectList)
        {
            if(o instanceOf Integer) {
                results.add((Integer)o);
            }
        }

        return results;
    }

    private static List<Decimal> toDecimalList(List<Object> objectList)
    {
        List<Decimal> results = new List<Decimal>();

        for(Object o : objectList)
        {
            if(o instanceOf Decimal) {
                results.add((Decimal)o);
            }
        }

        return results;
    }

    private static List<Id> toIdList(List<Object> objectList)
    {
        List<Id> results = new List<Id>();

        for(Object o : objectList)
        {
            if(o instanceOf Id) {
                results.add((Id)o);
            }
        }

        return results;
    }

    /***
     * One public static method to rule them all! By passing the outputList by reference instead of using a return type it avoids
     * Apex's inability to make a call like this passing the type dynamically for the return value and/or method signature...
     *
     *  List<T> GetQueryResult<T>(sObject sObjects)
     *
     * ...when all you want to do is project something like a Name element from a collection of sObjects on to a flattened array
     * or just get an array of Objects into a expected type without the dreaded "Illegal conversion from List<Object> to List<String>"
     * issue. By no means a true generic, but it preserves the D.R.Y. principle and avoids loops all over the place.
     */
    public static void toListOf(List<Object> inputElements, Type expectedType, List<Object> outputList)
    {
        // Clear the input as this is use more like a return by reference
        outputList.clear();

        if(outputList == null)
        {
            throw new NullPointerException();
        }

        String expectedType2 = expectedType.getName();

        switch on expectedType2
        {
            when 'String' {
                outputList.addAll(toStringList(inputElements));
            }
            when 'Integer' {
                outputList.addAll(toIntegerList(inputElements));
            }
            when 'Decimal' {
                outputList.addAll(toDecimalList(inputElements));
            }
            when 'Id' {
                outputList.addAll(toIdList(inputElements));
            }
            when else {
                throw new NotImplementedException('Not implemented - This method could be finished off by supporting more types.');
            }
        }
    }
}