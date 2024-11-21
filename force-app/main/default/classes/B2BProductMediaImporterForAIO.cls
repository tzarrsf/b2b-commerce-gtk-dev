public class B2BProductMediaImporterForAIO {

    /**
     * TODO: Set COMMUNITY_NAME value to your store name
     */
    private static final String COMMUNITY_NAME = 'B2B Aura Store from TSO';
    private static final String CONTENT_TYPE = 'cms_image';
    private static final String DEFAULT_LANGUAGE = 'en_US';
    private static final Integer DEFAULT_PAGE_SIZE = 50;
    private static final List<String> ELECTRONIC_MEDIA_GROUPS = new List<String>{'productDetailImage', 'productListImage'};
    private static String CommunityId = null;

    public static void createProductMedia() {
        List<ProductMedia> productMediaToBeCreated = new List<ProductMedia>();
        List<Product2> products = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode != null];
        List<ElectronicMediaGroup> electronicMediaGroups = getElectronicMediaGroupsForProducts();
        CommunityId = getCommunityIdByName(COMMUNITY_NAME);

        if(CommunityId == null)
        {
            System.debug('CommunityId not found for COMMUNITY_NAME: ' + COMMUNITY_NAME + ' - Stopping execution.');
            return;
        }

        ConnectApi.ManagedContentVersionCollection contentVersionMediaCollection =
            ConnectApi.ManagedContent.getAllManagedContent(CommunityId, null, DEFAULT_PAGE_SIZE, DEFAULT_LANGUAGE, CONTENT_TYPE);

        if(contentVersionMediaCollection == null)
        {
            System.debug('contentVersionMediaCollection not found for CommunityId: ' + CommunityId + ' - Stopping execution.');
            return;
        }

        for(Product2 product: products) {
            List<ProductMedia> productMedias = new List<ProductMedia>();
            productMedias = createProductMediaRecords(electronicMediaGroups, contentVersionMediaCollection.items, product);
            productMediaToBeCreated.addAll(productMedias);
        }

        if(productMediaToBeCreated.size() == 0)
        {
            System.debug('Looks like there aren\'t any updates to be made. Check that the assets have been created in the org as expected.');
            return;
        }

        try {
            insert productMediaToBeCreated;
        }
        catch(DmlException e)
        {
            System.debug('Error inserting productMediaToBeCreated: ' + e.getMessage());
        }
    }

    private static List<ElectronicMediaGroup> getElectronicMediaGroupsForProducts() {
        return [SELECT Id, DeveloperName
                FROM ElectronicMediaGroup
                WHERE DeveloperName
                IN :ELECTRONIC_MEDIA_GROUPS
                ORDER BY DeveloperName ASC];
    }

    private static Id getCommunityIdByName(String communityName) {
        ConnectApi.CommunityPage communityPages = ConnectApi.Communities.getCommunities();
        List<ConnectApi.Community> communities = communityPages.communities;

        for(ConnectApi.Community community : communities) {
            if(community.name == communityName) {
                return community.Id;
            }
        }

        return null;
    }

    private static List<ProductMedia> createProductMediaRecords(List<ElectronicMediaGroup> electronicMediaGroups,
                                                            List<ConnectApi.ManagedContentVersion> contentVersionMedias,
                                                            Product2 product) {
        List<ProductMedia> productMedias = new List<ProductMedia>();
        List<ConnectApi.ManagedContentVersion> mediaContentsForTheCurrentProduct = getMediaContentForTheProduct(contentVersionMedias,
                                                                                                                product.ProductCode);
        if(mediaContentsForTheCurrentProduct.size() == 0) {
            System.debug('mediaContentsForTheCurrentProduct has a length of 0. Skipping execution of media Contents for product: ' + product.Name + '(' + product.Id + ')');
            System.debug('Did you upload the JSON or other assets?');
            // Favors a return of empty collection to avoid null reference exception
            return productMedias;
        }

        for(ConnectApi.ManagedContentVersion mediaContent : mediaContentsForTheCurrentProduct) {
            ProductMedia productMedia = buildObjectMedia(electronicMediaGroups.get(0).Id, mediaContent.managedContentId, product.Id);
            productMedias.add(productMedia);
        }

        // Detail image is unique, in this case, it is getting the first one
        ProductMedia productMedia = buildObjectMedia(electronicMediaGroups.get(1).Id,
                                                    mediaContentsForTheCurrentProduct.get(0).managedContentId,
                                                    product.Id);
        productMedias.add(productMedia);

        return productMedias;
    }

    private static List<ConnectApi.ManagedContentVersion> getMediaContentForTheProduct(List<ConnectApi.ManagedContentVersion> contentVersionMedias, 
                                                                                    String ProductCode) {
        List<ConnectApi.ManagedContentVersion> mediaContentsForTheProduct = new List<ConnectApi.ManagedContentVersion>();

        for(ConnectApi.ManagedContentVersion mediaContent : contentVersionMedias) {
            if(mediaContent.title.contains(ProductCode)) {
                mediaContentsForTheProduct.add(mediaContent);
            }
        }

        return mediaContentsForTheProduct;
    }

    private static ProductMedia buildObjectMedia(Id electronicMediaGroupId, Id electronicMediaId, Id productId) {
        return new ProductMedia(
            ElectronicMediaGroupId = electronicMediaGroupId,
            ElectronicMediaId = electronicMediaId,
            ProductId = productId
        );
    }
}

//Highlight line below in VS Code and use Execute Anonymous Apex With Currently Selected Text to run it
//B2BProductMediaImporterForAIO.createProductMedia();