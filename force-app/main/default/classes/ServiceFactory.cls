/**
 * @description       : Example code for instantating services via factory design pattern.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-26-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class ServiceFactory {

    private static HTTPService service;

    private ServiceFactory() {}

    public static HTTPService getService(String className)
    {
        if (service == null)
        {
            if (String.isNotEmpty(className))
            {
                Type t = Type.forName(className);
                service = (HTTPService) t.newInstance();
            }
            else
            {
                service = new HTTPService();
            }
        }

        return service;
    }
}