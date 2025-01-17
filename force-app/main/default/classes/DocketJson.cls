public class DocketJson{
	public String sErrMsg;	//
	public cls_response[] response;
	public class cls_response {
		public String docketNo;	//100655233
		public String companyId;	//GKE
		public cls_result[] result;
		public String sErrMsg;	//
	}
	class cls_result {
		public String CONSIGNEE_MOBILE_NO;	//9575301802
		public String POD_TYPE;	//GOOD
		public String DOCKET_NO;	//100655233
		public String CONSIGNEE_PINCODE;	//122015
		public String DOCKET_TYPE;	//OWNERS RISK
		public String COD_TYPE;	//G
		public String DECL_CARGO_VAL;	//142794
		public String CONSIGNOR_NAME;	//VISION FREIGHT SOLUTIONS INDIA PVT LTD
		public String BOOKING_STN;	//BSP
		public String DOCKET_STATUS;	//DELIVERED
		public String CONTRACT_NO;	//SLQ/CON/07/2020/1020001
		public String ASSURED_DLY_DT;	//11-JAN-2021
		public String CONSIGNOR_MOBILE_NO;	//9575301802
		public String ACTUAL_WT;	//189
		public String BKG_DT;	//02-JAN-2021
		public String NO_OF_PKGS_DELIVERED;	//21
		public String APPROVED_DLY_DT;	//06-JAN-2021
		public String CUSTOMER_CODE;	//30072502
		public String DELIVERY_STN;	//GGN
		public String CONSIGNOR_PINCODE;	//495001
		public String PROD_SERV_CODE;	//24
		public String CHARGED_WT;	//189
		public String NO_OF_PKGS;	//21
        public String STOCK_OU;
		public String STOCK_IN_DATE_TIME;
        public String STOCK_RECEIVING_OU;
        public String STOCK_DISPATCH_OU;
		public String CONSIGNEE_NAME;	//ALCATEL LUCENT BLOCK D PLOT N 25 RES ELECTONIC
        public String PDC_BLOCK; //1 for block
	}
	public static DocketJson parse(String json){
		return (DocketJson) System.JSON.deserialize(json, DocketJson.class);
	}
}