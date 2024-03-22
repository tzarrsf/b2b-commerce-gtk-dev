/**
 * @description       : This exception is  thrown when the org-level cache partition (default) can't be found.
 *                      If this exception is being encountered consult the official documentation:
 *                      https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_cache_partition_setup.htm
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-21-2024
 * @last modified by  : Tom Zarr
**/
public class MissingCachePartitionException extends Exception { }