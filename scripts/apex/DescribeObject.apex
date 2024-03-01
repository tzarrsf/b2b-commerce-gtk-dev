String selectedObject = 'PriceBookEntry';
Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
Schema.SObjectType ObjectSchema = schemaMap.get(selectedObject);
Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
List<String> fieldNames = new List<String>();
String buffer ='';

for(String fieldName: fieldMap.keySet()) {  
    buffer += 'Name: ' + fieldName;
    buffer += ' | Label: ' + fieldMap.get(fieldName).getDescribe().getLabel();
    buffer += ' | Type: ' + fieldMap.get(fieldName).getDescribe().getType();
    
    if(fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.REFERENCE)
    {
        buffer += ' to ' + fieldMap.get(fieldName).getDescribe().getReferenceTo().get(0);
        Schema.SObjectType parentSchema = fieldMap.get(fieldName).getDescribe().getReferenceTo().get(0);
        Map<String, Schema.SObjectField> parentFieldMap = parentSchema.getDescribe().fields.getMap();
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
        buffer = buffer.removeEnd(',');
    }
    
    buffer += '\r\n';
}

buffer = buffer.removeEnd('\r\n');
System.debug(buffer);