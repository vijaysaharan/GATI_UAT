public class Constants {
    //Integrations
    public static final String ETARIFF_SERVICE = 'EtariffService';
    public static final String STATUS_SERVICE = 'CustomerStatusService';
    public static final String ACCOUNT_PUSH = 'AccountCalloutService';
    public static final String TEU_NOTIFICATION = 'TEUNotification';
    public static final String AUTHORIZATION_URL = 'Authorization';
    public static final String TEU_TRANSACTION = 'TEUTransaction';

    //GATI
    public static final String LEAD_PUSH = 'GATILeadCalloutService';
    public static final String GATI_AUTHORIZATION_URL = 'GATIAuthorizationApi';
    
    
    public static final String SUCCESS = 'Success';
    public static final String ERROR = 'Error';
    public static final String TEU_TRANSACTION_SERVICE='TEU Transaction';
    //Tag Constants
    public static final String BATCH_RECORD_DETAILS = 'BatchRecordDetails';
    public static final String TRADE_ENTITY = 'TradeEntity';
    public static final String BILLING_ADDRESS = 'BillingAddress';
    public static final String ATTACHMENT_DETAILS = 'AttachmentDetails';
    public static final String UNIQUE_BATCH_ID = 'UniqueBatchId';
    public static final String CONTACT_DETAILS = 'ContactDetails';
    public static final String CONTACT_NAME = 'ContactName';
    public static final String CONTACT_MOBILE = 'ContactMobilePhone';
    public static final String CONTACT_EMAIL = 'ContactEmail';
    public static final String LEAD_STATUS = 'Cross_Sell_Lead_Status__c';
 	public static final String EXTERNAL_ID = 'ExternalID__c';
    

    public static final Set<String> EXCEPTION_CASE_TAG_SET = new Set<String>{TRADE_ENTITY,BILLING_ADDRESS,ATTACHMENT_DETAILS,CONTACT_DETAILS};
    public static final Set<String> TEU_EXCEPTION_CASE_TAG_SET = new Set<String>{};
    public static final Set<String> GATI_EXCEPTION_TAG_SET = new Set<String>{};  
    //Object Api 
    public static final String TEU_OBJECT = 'TEU__c'; 

    
    public static final String SEPARATOR = ' '; 
    public static final String ADDRESS_SEPARATOR = ','; 
    public static final String ETARIFF_STAGE = 'E-tariff';
    
    //Opportunity 
    public static final String STAGE_CLOSED_LOST = 'Closed Lost'; 
    public static final String STAGE_CLOSED_WON = 'Closed Won';
    //Http Method
    public static final String POST = 'POST';
    public static final String PATCH = 'PATCH';
    //RecordType
     public static final String GATI = 'GATI';

    //Lead
   
    public static final Set<String> LEAD_WORKING_STATUS = new Set<String>{'New','First Interaction done','Commercial Shared','Follow-up','Asking for KYC','KYC Received(Commercial Closed)'};
    public static final String WORKING = '5';
    public static final String CLOSE_CONVRT = 'Closed Converted';
    public static final String CLOSE_NOT_CONVRT = 'Closed Not Converted';
    public static final Map<String,String> STATUS_MAP = new  Map<String,String>{
        														'Closed Converted' => '7',
                                                                'Closed Not Converted' => '6'
    													   }; 
           
         
    
    

    
}