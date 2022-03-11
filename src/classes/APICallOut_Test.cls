//created by ashwini godase
@isTest
public class APICallOut_Test {
    @isTest
    public static void apiCall()
    {
        Test.setMock(HttpCalloutMock.class, new MockGenerator());  
        Blob headerValue = Blob.valueOf('olam.pi@olamnet.com'+ ':' + 'OlamPI@123');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        Map<String,String> mapOfHeaders = new Map<String,String>();
        mapOfHeaders.put('authorization', authorizationHeader);
        mapOfHeaders.put('Content-Type', 'application/json');
        String requestBody='[{ "customer_sap_id" : "1000018", "customer_material_code" : "321321355", "olam_material_code" : "100000000061"},{"customer_sap_id" : "1000018", "customer_material_code" : "33112244", "olam_material_code" : "100000000091"}]';
        Integer timeOut=120000;
        String endpoint='https://olamapi.prod.apimanagement.eu10.hana.ondemand.com:443/ProductConfig_QA';
        HttpResponse res= APICalloutsUtil.doAPICallOut('POST', endpoint, mapOfHeaders, requestBody, timeOut);
    }
 
}