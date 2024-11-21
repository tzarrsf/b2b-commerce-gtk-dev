/**
 * @description       : This code helps fill some gaps and limitations with Apex, Namely that it does not support generics or late binding
 *                      and I wanted to know the type at runtime for conversions without having to write the same loops everywhere. This
 *                      helps preserve the "D.R.Y." principle in code examples.
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-25-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class TypeUtility {
   /***
     * Original source for this method:
     * https://salesforce.stackexchange.com/questions/48019/how-to-get-the-runtime-type-of-an-object-dynamically-for-primitive-data-types-a
     */
    public static String typeOf(Object o)
    {
        if(o==null)                         return '';              // we can't say much about null
        String                              result  = 'Object';     // if we can't find out anything, we will return 'Object'
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';
        if(o instanceof Double)             return 'Double';
        if(o instanceof List<object>)       return 'List';
        /***
         * Crazy but powerful workaround based on the answer of Arpi Jakab (20217-04-17) on SFSE==>
         * https://salesforce.stackexchange.com/questions/48019/how-to-get-the-runtime-type-of-an-object-dynamically-for-primitive-data-types-a 
         * INTENTIONALLY force runtime exception like: "Invalid conversion from runtime type Map<Id,List<Account>> to Name"
         */
        try {
            Name a = (Name) o;
        } catch (Exception e) {
            result = e.getMessage().substringAfter('from runtime type ').substringBefore(' ');
        }
        return result;
    }
}