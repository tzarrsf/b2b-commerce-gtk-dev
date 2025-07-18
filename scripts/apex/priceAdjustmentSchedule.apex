// Get the known good Price Adjustment Schedule via SOQL
List<PriceAdjustmentSchedule> priceAdjustmentSchedules = [
    SELECT
        Id
        ,Name
        ,Description
        ,AdjustmentMethod
        ,CreatedById
        ,CreatedDate
        ,CurrencyIsoCode
        ,IsActive
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,OwnerId
        ,ScheduleType
        ,SystemModstamp
    FROM
        PriceAdjustmentSchedule
    WHERE
        NAME = :TestSettings.KNOWN_GOOD_PRICE_ADJUSTMENT_SCHEDULE_NAME
    WITH
        SECURITY_ENFORCED
    LIMIT
        10
];

Assert.isNotNull(priceAdjustmentSchedules, 'priceAdjustmentSchedules is null. Create a known good PriceAdjustmentSchedule and check the TestSettings class.');
Assert.isFalse(priceAdjustmentSchedules.isEmpty(),  'priceAdjustmentSchedules is empty. Create a known good PriceAdjustmentSchedule and check the TestSettings class.');
Assert.isTrue(priceAdjustmentSchedules.size() == 1, 'priceAdjustmentSchedules does not have a single record');
System.Debug('PriceAdjustmentSchedule Result => ' +  priceAdjustmentSchedules[0].Name + ' with size ' + priceAdjustmentSchedules.size());

//TODO: Call this via REST API with an Effective Account Id