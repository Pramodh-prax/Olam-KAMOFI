public class KAM_CustomMetaDataDAO {
	@testVisible
    static private Map<String, List<SObject>> metaDataRecordsMap = new Map<String, List<SObject>> ();
    
    public static List<SObject> getCustomMetadataRecords (String query) {
        if (!metaDataRecordsMap.containsKey(query)) {
            metaDataRecordsMap.put (query, Database.query(query));
        }
        return metaDataRecordsMap.get (query);
    }
}