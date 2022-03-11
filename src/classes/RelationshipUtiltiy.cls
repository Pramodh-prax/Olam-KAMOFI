public class RelationshipUtiltiy{
    Map<String, List<Relationship>> relationshipMap = new Map<String, List<Relationship>>();
    public void registerRelationship(sObject record, sObject relatedTo, Schema.sObjectField relatedToField){
        String sObjectType = record.getSObjectType().getDescribe().getName();
        Relationship rel = new Relationship();
        rel.record = record;
        rel.relatedTo = relatedTO;
        rel.relatedToField = relatedToField;
        if(relationshipMap.containsKey(sObjectType)){
             relationshipMap.get(sObjectType).add(rel);
        }
        else{
             relationshipMap.put(sObjectType, new List<Relationship>{rel});
        }
    }
    public void resolve(String sObjectName){
        for(Relationship rel :relationshipMap.get(sObjectName)){
            rel.record.put(rel.relatedToField, rel.relatedTo.Id);
        }
    }
    public class Relationship{
        public sObject record;
        public sObject relatedTo;
        public Schema.sObjectField relatedToField;
    }
}