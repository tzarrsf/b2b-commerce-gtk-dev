/*
Mimics the Developer Console Execute Anonymous functionality
Option A: Selection
1. Paste your code in and highlight it
2. Ctrl + Shift + P to activate Command Palette
3. Choose "Execute Anonymous Apex with Currently Selected Text"
Option B: All contents
1. Ctrl + Shift + P to activate Command Palette
2. Choose "Execute Anonymous Apex with Editor Contents"
*/

// Simple example
//List<Account> accountsTest = [select Id, Name from Account limit 100];
//System.debug(accountsTest.size() + ' accounts found.');

List<Object> stuff = [ SELECT n.Name, n.Description,
    ss.Name, ss.Description,
    ws.Name, ws.Description,
    wsc.Name, wsc.Description,
    pc.Name, pc.Description,
    pc.Category__r.Name, pc.Category__r.Description,
    p.Name, p.Description,
    pcp.ProductCategory__r.Name, pcp.ProductCategory__r.Description,
    wspb.Name, wspb.Description,
    pb.Name, pb.Description,
    pbe.UnitPrice
FROM 
    Network__c n,
    SalesStore__c ss,
    WebStore__c ws,
    WebStoreCatalog__c wsc,
    ProductCatalog__c pc,
    Product__c p,
    ProductCategoryProduct__c pcp,
    WebStorePricebook__c wspb,
    Pricebook2 pb,
    PricebookEntry pbe
WHERE 
    ss.Network__c = n.Id AND
    ws.SalesStore__c = ss.Id AND
    wsc.WebStore__c = ws.Id AND
    pc.WebStoreCatalog__c = wsc.Id AND
    p.ProductCatalog__c = pc.Id AND
    pcp.Product__c = p.Id AND
    pcp.ProductCategory__c = pc.Category__c AND
    wspb.WebStore__c = ws.Id AND
    pb.Id = wspb.Pricebook2__c AND
    pbe.Pricebook2Id = pb.Id AND
    pbe.Product2Id = p.Id
];