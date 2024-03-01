/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 02-29-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class RecursiveObjectDescriber {

    public static void describeEntity(String objectName, Integer maxStackDepth) {
        describeEntity(objectName, 0, maxStackDepth);
    }

    private static String makeTabs(Integer numberOfTabs) {
        String tabs = '';

        Integer i = 0;

        while( i < numberOfTabs) {
            tabs += '----';
            i++;
        }

        return tabs;
    }

    private static void describeEntity(String objectName, Integer stackDepth, Integer maxStackDepth)
    {
        if(stackDepth == maxStackDepth) {
            return;
        }

        stackDepth++;

        String tabs = makeTabs(stackDepth);
        String buffer = tabs + 'Object: ' + objectName + + '\r\n';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>();

        for(String fieldName: fieldMap.keySet()) {


            if(fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.REFERENCE)
            {
                tabs = makeTabs((stackDepth + 1) * 2);
                buffer += tabs + 'Name: ' + fieldName;
                buffer += ' | Label: ' + fieldMap.get(fieldName).getDescribe().getLabel();
                buffer += ' | Type: ' + fieldMap.get(fieldName).getDescribe().getType();

                buffer += ' to ' + fieldMap.get(fieldName).getDescribe().getReferenceTo().get(0);
                Schema.SObjectType parentSchema = fieldMap.get(fieldName).getDescribe().getReferenceTo().get(0);
                Map<String, Schema.SObjectField> parentFieldMap = parentSchema.getDescribe().fields.getMap();
                String objectName2 = fieldMap.get(fieldName).getDescribe().getReferenceTo().get(0).toString();
                List<String> parentFields = new List<String>(parentFieldMap.keySet());

                for(String parentField : parentFieldMap.keySet())
                {
                    if(parentFields[0] == parentField) {
                        buffer += ' on Column ' + parentFields[0] + ' | ';
                        buffer += ' Other columns:';
                    }
                    else {
                        buffer += ' ' + parentField + ',';
                    }
                }

                if(stackDepth < maxStackDepth) {
                    RecursiveObjectDescriber.describeEntity(objectName2, stackDepth);
                }
            } else {
                tabs = makeTabs(stackDepth + 1);
                buffer += tabs + 'Name: ' + fieldName;
                buffer += ' | Label: ' + fieldMap.get(fieldName).getDescribe().getLabel();
                buffer += ' | Type: ' + fieldMap.get(fieldName).getDescribe().getType();
            }

            buffer += '\r\n';
        }

        System.debug(buffer);
    }
}