public class GatiMDMUtil {
    public static List<ActionOutput> convertCreationResponse (String jsonString){
        List<ActionOutput> outputs = new List<ActionOutput>();
        GatiMDMCreationResponseBodyWrapper jsonObject = (GatiMDMCreationResponseBodyWrapper)JSON.deserialize(jsonString,GatiMDMCreationResponseBodyWrapper.Class);
        ActionOutput output = new ActionOutput();
        output.creationResponse = jsonObject;
        outputs.add(output);
        return outputs;
    }
    
    public class GatiMDMRequestRootWrapper {
        public Object content;
    }
    
    public class GatiMDMRequestContentWrapper {
        public String content;
    }
    
    public class GatiMDMApprovalRequestWrapper {
        public GatiMDMRequestContentWrapper EXISTING_CUST_ID;
        public GatiMDMRequestContentWrapper Additional_Approver_Requested_by_User;
        public GatiMDMRequestContentWrapper Query_Fired;
    }
    
    public class GatiMDMCsMappingWrapper {
        public GatiMDMRequestContentWrapper CUST_CODE;
        public GatiMDMRequestContentWrapper CompanyID;
        public GatiMDMRequestContentWrapper Customer_First_Name;
        public GatiMDMRequestContentWrapper Customer_Association_Type;
        public GatiMDMRequestContentWrapper Staff_Code;
        public GatiMDMRequestContentWrapper Staff_Name;
        public GatiMDMRequestContentWrapper Email_ID;
        public GatiMDMRequestContentWrapper Operating_Unit;
        public GatiMDMRequestContentWrapper OU_Type;
        public GatiMDMRequestContentWrapper Customer_Category;
        public GatiMDMRequestContentWrapper Status;
        public GatiMDMRequestContentWrapper Remarks;
    }
    
    public class GatiMDMSubCodeCreationWrapper {
        public GatiMDMRequestContentWrapper EXISTING_CUST_ID;
        public GatiMDMRequestContentWrapper CompanyID;
        public GatiMDMRequestContentWrapper Existing_Contract_Number;
        public GatiMDMRequestContentWrapper Sub_Code_Requested;
        public GatiMDMRequestContentWrapper account_ID;
    }

    public class ActionOutput {
        @InvocableVariable public GatiMDMCreationResponseBodyWrapper creationResponse;
        @InvocableVariable public Integer approvalStatusCode;
        @InvocableVariable public Integer cmStatusCode;
        @InvocableVariable public Integer subCodeCreationStatusCode;
        @InvocableVariable public String errorMessage;
    }
    
    public class ActionInput {
        @InvocableVariable public String action;
        @InvocableVariable public String jsonString;
        @InvocableVariable public String authorizationHeader;
        @InvocableVariable public String opportunityId;
        @InvocableVariable public String approval_existing_cust_id;
        @InvocableVariable public String approval_additional_approver_requested_by_user;
        @InvocableVariable public String approval_query_fired;
        @InvocableVariable public AccountTeamMember accountTeamMember;
        @InvocableVariable public Account account;
        @InvocableVariable public Quote quoteData;
        @InvocableVariable public String customerCode;
        @InvocableVariable public String staffCode;
        @InvocableVariable public String companyCode;
    }
    
}