global class KMA_PDFViewCntl {
    @RemoteAction 
	global static String createContentVersion(String data, String fileName, String parentId) {
        ContentVersion versionData = new ContentVersion ();
        versionData.ContentLocation = 's';
        versionData.VersionData = EncodingUtil.base64Decode(data);
        versionData.PathOnClient = fileName;
        versionData.Title = fileName;
        insert versionData;
        
        ContentDocumentLink conDocLink = new ContentDocumentLink();
		conDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :versionData.Id].ContentDocumentId;
		conDocLink.LinkedEntityId = parentId;
		conDocLink.ShareType = 'V';
		insert conDocLink;
        
        return Json.serialize(new ContentWrapper (versionData.Id, conDocLink, versionData.Title));
    }
    public class ContentWrapper {
        public String name;
        public Id contentId;
        public ContentDocumentLink contentDocumentLink;
        
        public ContentWrapper () {
            name = '';
        }
        public ContentWrapper (Id contentId, ContentDocumentLink contentDocumentLink, String name) {
            this.contentId = contentId;
            this.contentDocumentLink = contentDocumentLink;
            this.name = name;
        }
    }
}