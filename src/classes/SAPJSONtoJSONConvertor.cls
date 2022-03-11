public class SAPJSONtoJSONConvertor {

	public cls_TT_HEADER TT_HEADER;
	public cls_TT_ITEM TT_ITEM;
	public class cls_TT_HEADER {
		public cls_header[] header;
	}
	public class cls_header {
		public String FGMAT;	//100000000085
		public String MAKTX;	//PAP WIP 54/60M MAP NNST181+
		public String PROCODE;	//1000004
		public String CUSTPROD;	//45454545
		public String CONFIGURATION;	//1
		public String INDEX_VAL;	//0-15
	}
	public class cls_TT_ITEM {
		public cls_item[] item;
	}
	public class cls_item {
		public String CONFIGURATION;	//1
		public String CONTRACT;	//NA
		public String MIC;	//USSP0322
		public String ZVARCHAR;	//OFIUS_VAR_MOLD
		public String ZDESC;	//MOLD
		public String UOM;	//%
		public String QUANT;	//YES
		public String QUALI;	//
		public String RANGE;	//0,00 - 500,00
		public String C_RANGE;	//
		public String SPEC;	//P
		public String DATA_TYPE;	//
		public String DECIMALS;	//0
		public String INTERVALS;	//
	}
	public static SAPJSONtoJSONConvertor parse(String json){
		return (SAPJSONtoJSONConvertor) System.JSON.deserialize(json, SAPJSONtoJSONConvertor.class);
	}

}