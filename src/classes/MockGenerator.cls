//created by ashwini godase
@isTest
global class MockGenerator implements HttpCalloutMock {
    // Implement this interface method
     global HTTPResponse respond(HTTPRequest req) {
        System.debug('req: '+req);
         String json='[{"olam_material_code":"100000039072","customer_sap_id":"1234","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 700,00"}]}]';
        //Fake Response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/json');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
                
    }
    
}