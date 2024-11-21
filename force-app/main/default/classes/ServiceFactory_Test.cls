/**
 * @description       : Unit tests for the ServiceFactory class.
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-26-2024
 * @last modified by  : Tom Zarr
**/

@isTest
public class ServiceFactory_Test
{
    @IsTest
    static void testGetServiceWithClassName()
    {
        HTTPService service = ServiceFactory.getService('HTTPService');
        System.assertNotEquals(null, service, 'Service should not be null');
    }

    @IsTest
    static void testGetServiceWithoutClassName()
    {
        HTTPService service = ServiceFactory.getService(null);
        System.assertNotEquals(null, service, 'Service should not be null');
    }
}