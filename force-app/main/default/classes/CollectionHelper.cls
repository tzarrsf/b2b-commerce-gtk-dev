/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-11-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class CollectionHelper {

    /***
     * Given an array of sObjects, pull a single property off all the elements in the array and project it on to a one-dimensional array
     * For example, get all the Name fields from Product in a flat array or all the Email Address fields from a Contact.
     */
    public static List<Object> projectPropertyToObjectList(List<sObject> sObjectArray, String propertyName)
    {
        Map<Id, sObject> m = new Map<Id, sObject>(sObjectArray);
        List<String> returnValue = new List<String>();

        for(sObject element : m.values())
        {
            returnValue.add((String)element.get(propertyName));
        }

        return returnValue;
    }
}