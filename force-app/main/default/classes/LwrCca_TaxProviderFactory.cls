/**
 * @description       : Factory pattern to instantiate tax providers of different types. Promotes flexibility
 *                      when moving from one tax provider to another in projects.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 11-20-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class LwrCca_TaxProviderFactory
{
    private static LwrCca_TaxAbstractProvider taxProvider;
    private static Map<String, LwrCca_TaxAbstractProvider> taxProviders = new Map<String, LwrCca_TaxAbstractProvider>();

    @testVisible
    private LwrCca_TaxProviderFactory(){}

    public static LwrCca_TaxAbstractProvider getTaxProvider(LwrCca_TaxMetaData taxMetaData)
    {
        if (taxProviders.containsKey(taxMetaData.providerImplClass))
        {
            taxProvider = taxProviders.get(taxMetaData.providerImplClass);
        }
        else
        {
            if (taxMetaData.providerImplClass != null)
            {
                Type t = Type.forName(taxMetaData.providerImplClass);
                taxProvider = (LwrCca_TaxAbstractProvider) t.newInstance();
                TaxProviders.put(taxMetaData.providerImplClass, taxProvider);
            }
        }

        return taxProvider;
    }
}