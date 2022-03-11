public class APICalloutsUtil {
    //Works only for synchronous not for asynchrnonous API calls
    public static HttpResponse doAPICallOut(String method,String endpoint,Map<String, String> mapOfHeaders,String requestBody, Integer timeOut){
        HttpResponse httpResponse;
        //create an instance of HTTPRequest
        HttpRequest request = new HttpRequest();
        //Set request method
        request.setMethod(method);
        //Set request endpoint
        request.setEndpoint(endpoint);
        //Set request method
        if(String.isNotBlank(requestBody)){
            request.setBody(requestBody);
        }
        //Set request headers
        request = setHeaders(request,mapOfHeaders);
        //Set request time out in milliseconds
        request.setTimeout(timeOut);
        
        System.debug('request: '+request);
        //create an instance of HTTP and use it to send the httpRequest
        Http http = new Http();
        httpResponse = http.send(request);
        
        return httpResponse;
    }
    public static HttpRequest setHeaders(HttpRequest request, Map<String , String> mapOfHeaders){
        //Iterate over the map of headers and set the request headers
        if(!mapOfHeaders.isEmpty()){
            for(String headerKey : mapOfHeaders.keySet()){
                request.setHeader(headerKey, mapOfHeaders.get(headerKey));
            }
        }
        return request;
    }
}