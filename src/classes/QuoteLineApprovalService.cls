public class QuoteLineApprovalService implements QuoteLineApprovalServiceInterface {
    public List<QuoteLineApprovalWrapper> getQuoteLineApprovers(String businessUnit, String region, List<QuoteLineItem> quoteLineList){
        List<QuoteLineApprovalWrapper> quoteLineApprovalList = new List<QuoteLineApprovalWrapper>();
        
        Set<String> productCategorySet = new Set<String>();
        Set<String> productSubCategorySet = new Set<String>{null};
        Set<String> productSubCategory2Set = new Set<String>{null};
        
        for(QuoteLineItem quoteLine :quoteLineList){
            if(quoteLine.Product2.Product_Category__c != null){
                productCategorySet.add(quoteLine.Product2.Product_Category__c);
            }
            
            if(quoteLine.Product2.Product_Sub_Category__c != null){
                productSubCategorySet.add(quoteLine.Product2.Product_Sub_Category__c);
            }
            
            if(quoteLine.Product2.Product_Sub_Category_2__c != null){
                productSubCategory2Set.add(quoteLine.Product2.Product_Sub_Category_2__c);
            }
        }
        
        Map<String, Approval_Matrix__c> approvalMatrixMap = getApprovalMatrixMap(businessUnit, region, productCategorySet, productSubCategorySet, productSubCategory2Set);
        
        for(QuoteLineItem quoteLine :quoteLineList){
            if(approvalMatrixMap.containsKey(getKey(quoteLine, 'SubCategory2'))){
                quoteLineApprovalList.add(new QuoteLineApprovalWrapper(quoteLine, approvalMatrixMap.get(getKey(quoteLine, 'SubCategory2'))));
            }
            else
                if(approvalMatrixMap.containsKey(getKey(quoteLine, 'SubCategory'))){
                    quoteLineApprovalList.add(new QuoteLineApprovalWrapper(quoteLine, approvalMatrixMap.get(getKey(quoteLine, 'SubCategory'))));
                }
            else
                if(approvalMatrixMap.containsKey(getKey(quoteLine, 'Category'))){
                    quoteLineApprovalList.add(new QuoteLineApprovalWrapper(quoteLine, approvalMatrixMap.get(getKey(quoteLine, 'Category'))));
                }
            else{
                quoteLineApprovalList.add(new QuoteLineApprovalWrapper(quoteLine, new Approval_Matrix__c()));
            }
        }
        
        return quoteLineApprovalList;
    }
    
    
    public String getKey(QuoteLineItem quoteLine, String level){
        String key = '';
        
        if(level == 'SubCategory2'){
            key = quoteLine.Product2.Product_Category__c + '_' + quoteLine.Product2.Product_Sub_Category__c + '_' + quoteLine.Product2.Product_Sub_Category_2__c;
        }
        if(level == 'SubCategory'){
            key = quoteLine.Product2.Product_Category__c + '_' + quoteLine.Product2.Product_Sub_Category__c;
        }
        if(level == 'Category'){
            key = quoteLine.Product2.Product_Category__c;
        }
        
        return key;
    }
    
    
    public Map<String, Approval_Matrix__c> getApprovalMatrixMap(String businessUnit, String region, Set<String> productCategorySet, Set<String> productSubCategorySet, Set<String> productSubCategory2Set){
        Map<String, Approval_Matrix__c> approvalMatrixMap = new Map<String, Approval_Matrix__c>();
        
        String queryString = getQueryString(businessUnit, region, productCategorySet, productSubCategorySet, productSubCategory2Set);
        
        for(Approval_Matrix__c approvalMatrix :Database.query(queryString)){
            String key = '';
            if(approvalMatrix.Product_Category__c != null && approvalMatrix.Product_Category__c != ''){
                key += approvalMatrix.Product_Category__c;
            }
            
            if(approvalMatrix.Product_Sub_Category__c != null && approvalMatrix.Product_Sub_Category__c != ''){
                key += '_' + approvalMatrix.Product_Sub_Category__c;
            }
            
            if(approvalMatrix.Product_Sub_Category_2__c != null && approvalMatrix.Product_Sub_Category_2__c != ''){
                key += '_' + approvalMatrix.Product_Sub_Category_2__c;
            }
            
            approvalMatrixMap.put(key, approvalMatrix);
        }
        
        return approvalMatrixMap;
    }
    
    
    public String getQueryString(String businessUnit, String region, Set<String> productCategorySet, Set<String> productSubCategorySet, Set<String> productSubCategory2Set){
        String queryString = 'SELECT Approver_1__c, Approver_2__c, Approver_3__c, Approver_1__r.Name, Approver_2__r.Name, Approver_3__r.Name, Brand__c, Product_Category__c, Product_Sub_Category__c, Product_Sub_Category_2__c ';
        queryString += 'FROM Approval_Matrix__c ';
        queryString += 'WHERE Business_Unit__c = :businessUnit AND Region__c = :region ';
        
        if(!productCategorySet.isEmpty()){
            queryString += 'AND Product_Category__c IN :productCategorySet ';
        }
        
        if(!productSubCategorySet.isEmpty()){
            queryString += 'AND Product_Sub_Category__c IN :productSubCategorySet ';
        }
        
        if(!productSubCategory2Set.isEmpty()){
            queryString += 'AND Product_Sub_Category_2__c IN :productSubCategory2Set ';
        }
        
        System.debug('Query String ---'+ queryString);
        
        return queryString; 
    }
}