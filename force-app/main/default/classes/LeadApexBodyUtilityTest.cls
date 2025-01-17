@isTest
private class LeadApexBodyUtilityTest {
    @isTest
    static void testGetStringFromRequestBody() {
        LeadApexBodyUtility.requestBodyJSON requestBodyObj = new LeadApexBodyUtility.requestBodyJSON();
        requestBodyWrapper innerRequestBody = new requestBodyWrapper();
        innerRequestBody.Cross_Sell_Visit_Remarks = 'TEST';
        innerRequestBody.Company = 'TEST';
        innerRequestBody.Email = 'TEST';
        innerRequestBody.Description = 'TEST';
        innerRequestBody.Existing_Service_Provider = 'TEST';
        innerRequestBody.Rating = 'TEST';
        innerRequestBody.Turnover_of_the_Company = 100000;
        innerRequestBody.PostalCode = 'TEST';
        innerRequestBody.Receiver_Email = 'TEST';
        innerRequestBody.Salutation = 'TEST';
        innerRequestBody.Product_List = 'TEST';
        innerRequestBody.MobilePhone = 'TEST';
        innerRequestBody.Receiver_Location = 'TEST';
        innerRequestBody.Payment_mode = 'TEST';
        innerRequestBody.Reason_for_Revisit = 'TEST';
        innerRequestBody.Industry = 'TEST';
        innerRequestBody.Cross_Sell_Zone = 'TEST';
        innerRequestBody.Monthly_Spent_on_express_Logistic = 'TEST';
        innerRequestBody.Description_c = 'TEST';
        innerRequestBody.Phone = 'TEST';
        innerRequestBody.Street = 'TEST';
        innerRequestBody.Lead_Data = 'TEST';
        innerRequestBody.Receiver_Zone = 'TEST';
        innerRequestBody.FirstName = 'TEST';
        innerRequestBody.Title = 'TEST';
        innerRequestBody.Working_on_Location = 'TEST';
        innerRequestBody.City = 'TEST';
        innerRequestBody.Cross_Sell_Lead_Status = 'TEST';
        innerRequestBody.Receiver_Name = 'TEST';
        innerRequestBody.Cross_Sell_Topic = 'TEST';
        innerRequestBody.Lead_Rejection_Reason = 'TEST';
        innerRequestBody.LeadSource = 'TEST';
        innerRequestBody.Company_Product_Code = 'TEST';
        innerRequestBody.State = 'TEST';
        innerRequestBody.Revisit_Date = System.today();
        innerRequestBody.Country = 'TEST';
        innerRequestBody.Expected_Business_Per_Month = 100000;
        innerRequestBody.LastName = 'TEST';
        innerRequestBody.Cross_Sell_Lead_Created_From = 'TEST';
        innerRequestBody.Receiver_Mobile = 'TEST';
        innerRequestBody.Other_Lead_Rejection_Reason = 'TEST';
        innerRequestBody.OU_Zone = 'TEST';
        innerRequestBody.Sender_Email = 'TEST';
        innerRequestBody.Sender_Location = 'TEST';
        innerRequestBody.Sender_Mobile = 'TEST';
        innerRequestBody.Sender_Name = 'TEST';
        innerRequestBody.ExternalID = 'TEST';
        requestBodyObj.requestBody = innerRequestBody;
        
        Test.startTest();
        List<String> result = LeadApexBodyUtility.getStringFromRequestBody(new List<LeadApexBodyUtility.requestBodyJSON>{requestBodyObj});
        Test.stopTest();
    }
}