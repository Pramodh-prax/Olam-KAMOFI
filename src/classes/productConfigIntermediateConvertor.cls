public class productConfigIntermediateConvertor {
    public static string sapJSONParse(string inputJSON){
        SAPJSONtoJSONConvertor sapJSON = new SAPJSONtoJSONConvertor();
        sapJSON = SAPJSONtoJSONConvertor.parse(inputJSON);
        List<ProductConfigWrapper> outputJSON = new List<ProductConfigWrapper>();
        List<SAPJSONtoJSONConvertor.cls_item> slicedArray = new List<SAPJSONtoJSONConvertor.cls_item>();
        List<productConfigIntermediateConvertor.configs> sfConfigs = new List<productConfigIntermediateConvertor.configs>();
        for(SAPJSONtoJSONConvertor.cls_header tempHeader : sapJSON.TT_HEADER.header ){
            ProductConfigWrapper tempConfig = new ProductConfigWrapper();
            tempConfig.customer_sap_id = tempHeader.PROCODE;
            tempConfig.customer_material_code = tempHeader.CUSTPROD;
            tempConfig.olam_material_code = tempHeader.FGMAT;
            If(tempHeader.INDEX_VAL != '' && tempHeader.INDEX_VAL != null){
                integer startIndex = integer.valueOf(tempHeader.INDEX_VAL.substringBefore('-'));
                integer endIndex = integer.valueOf(tempHeader.INDEX_VAL.substringAfter('-'));
                
                slicedArray = productConfigIntermediateConvertor.slice(sapJSON.TT_ITEM.item,startIndex,endIndex);
            }
            for(SAPJSONtoJSONConvertor.cls_item tempJSONConfig : slicedArray){
                productConfigIntermediateConvertor.configs tempSFConfig = new productConfigIntermediateConvertor.configs();
                tempSFConfig.mic = tempJSONConfig.MIC;
                tempSFConfig.varient_character_mapping = tempJSONConfig.ZVARCHAR ;
                tempSFConfig.description = tempJSONConfig.ZDESC ;
                tempSFConfig.qualitative = tempJSONConfig.QUALI ;
                tempSFConfig.quantitative = tempJSONConfig.QUANT ;
                tempSFConfig.uom = tempJSONConfig.UOM ;
                tempSFConfig.olam_range = tempJSONConfig.RANGE ;
                tempSFConfig.customer_range = tempJSONConfig.C_RANGE ;
                If(tempJSONConfig.SPEC == 'P'){
                    tempSFConfig.indicator = 'Product Spec';
                }else If(tempJSONConfig.SPEC == 'M'){
                    tempSFConfig.indicator = 'Material Spec';
                }else{
                    tempSFConfig.indicator = '';
                }
                sfConfigs.add(tempSFConfig);
            }
            tempConfig.configurations = sfConfigs;
            outputJSON.add(tempConfig);
        }
        
        return JSON.serialize(outputJSON) ;
        
    }
    public static SAPJSONtoJSONConvertor.cls_item[] slice(SAPJSONtoJSONConvertor.cls_item[] ary, Integer first, Integer last) {
        SAPJSONtoJSONConvertor.cls_item[] res = ary.clone(), temp;
        Integer size = ary.size(),
            startIndex = Math.min(size, Math.max(-1, first<0? size+first: first)),
            endIndex = Math.min(size, Math.max(-1, last<0? size+last: last-1)),
            offset = Math.max(-1, endIndex-startIndex);
        temp = new SAPJSONtoJSONConvertor.cls_item[offset+1];
        for(Integer h = 0, i = startIndex, j = endIndex; i <= j; ) {
            temp[h++] = ary[i++];
        }
        res.clear();
        res.addAll(temp);
        return res;
    }
    public class ProductConfigWrapper {
        public String customer_sap_id {get;set;}
        public String customer_material_code {get;set;}
        public String olam_material_code {get;set;}
        public List<configs> configurations{get;set;}
    }
    class configs{
        public String mic {get;set;}
        public String varient_character_mapping {get;set;}
        public String description {get;set;}
        public String uom {get;set;}
        public String quantitative {get;set;}
        public String qualitative {get;set;}
        public String olam_range {get;set;}
        public String customer_range {get;set;}
        public String indicator {get;set;}
    }
}