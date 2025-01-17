public with sharing class CreateWeeklyCsvOfCustomerConnect implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    public Date sDate;
    public Date eDate;
    public String csvHeader = 'Id,Name,Created Date,Call Type,Closure Remarks,Contract Name,Customer Type,Day End Km,Day Start Km,Expected Amount,Expected Closure Date,Industry,Key Discussion Description,Kms Travelled,MCM Actionable,Next Visit Date Time,Status of Discussion,Sub Type,Visit End Date,Visit Start Date,MOM Count,Unique Customer Connect,Lead Name,Zone,Owner Role,Owner Manager,Owner Manager Role,Vertical,Closure_Remarks Length,Key Discussion,Actionables,Role Name,Visit Mode,Visit Status,Check In Location Latitude,Check In Location Longitude,Check In Location,Check In Time,Check Out Location Latitude,Check Out Location Longitude,Check Out Location,Check Out Time,Created Today,Email Body,Button Visivility,Check out Visivility,Total Distance,Accompanied,Acompanied With Name,Check In Address,Check Out Address,Customer Name,Visit Date,Visited Location Name, Visit Name,Month Year,MTD Revenue Air,MTD Revenue Surface,Financial Year,Issue,Action Taken,Action Needed,Opportunity Name\n';
    public String csvData;
    /*
    public CreateWeeklyCsvOfCustomerConnect(Date sDate, Date eDate){
        this.sDate = sDate;
        this.eDate = eDate;
        this.csvData = '';
    }
    */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        sDate = System.today().addDays(-7);
       	eDate = System.today().addDays(-1);
        String query = 'SELECT Id, CreatedDate, Name, Customer_Code__r.Name, Call_Type__c, Closure_Remarks__c,'+ 
            'Contract__r.Name, Customer_Type__c, Day_End_Km__c, Day_Start_Km__c, Expected_Amount__c,'+ 
            'Expected_Closure_Date__c, Industry__c, Key_Discussion_Description__c,'+
            'Kms_Travelled__c, MCM_actionable__c, Next_Visit_Date_Time__c, Status_of_Discussion__c,'+
            'Sub_Type__c, Visit_End_Date__c, Visit_Start_Date__c, MOM_Count__c, UniqueCustomerConnect__c,'+
            'Lead__r.Name, Zone__c, Owner_Role__c, Owner_Manager__c, Owner_Manager_Role__c, Vertical__c,'+
            'Closure_Remarks_Length__c, Key_Discussion__c, Actionables__c,Role_Name__c, Visit_Mode__c,'+
            'Visit_Status__c, Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,'+
            'Check_In_Location__c, Check_In_Time__c, Check_Out_Location__Latitude__s,'+
            'Check_Out_Location__Longitude__s, Check_Out_Location__c, Check_Out_Time__c, Created_Today__c,'+
            'EmailBody__c, Button_Visivility__c, Check_out_Visivility__c, Total_Distance__c,'+
            'Accompanied__c, AcompaniedWith__r.Name, Check_In_Address__c, Check_Out_Address__c, Customer_Name__c,'+
            'Visit_Date__c, Visited_Location__r.Name, Visit__r.Name, Month_Year__c, MTD_Revenue_Air__c, MTD_Revenue_Surface__c,'+
            'FinancialYear__c, Issue__c, Action_Taken__c, Action_Needed__c, Opportunity__r.Name '+
            ' FROM Customer_Connect__c'+
            ' WHERE DAY_ONLY(CreatedDate) = LAST_N_DAYS:7' +
            //' AND DAY_ONLY(CreatedDate) <=: eDate' +
            ' AND CreatedDate != TODAY '+
            ' ORDER BY CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Customer_Connect__c> scope) {
        List<Customer_Connect__c> customerConnectListOfLastWeek = scope;
        String csvBody = '';
        if(customerConnectListOfLastWeek != null && customerConnectListOfLastWeek.size() > 0){           
            
            for (Customer_Connect__c customerConnect : customerConnectListOfLastWeek) {
                csvBody += customerConnect.Id + ',' +
                    (customerConnect.Customer_Code__r.Name != null ? '"' + (customerConnect.Customer_Code__r.Name).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.CreatedDate != null ? '"' + (String.valueOf(customerConnect.CreatedDate)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Call_Type__c != null ? '"' + (customerConnect.Call_Type__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Closure_Remarks__c != null ? '"' + (customerConnect.Closure_Remarks__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Contract__r.Name != null ? '"' + (customerConnect.Contract__r.Name).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Customer_Type__c != null ? '"' + (customerConnect.Customer_Type__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Day_End_Km__c != null ? '"' + (String.valueOf(customerConnect.Day_End_Km__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Day_Start_Km__c != null ? '"' + (String.valueOf(customerConnect.Day_Start_Km__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Expected_Amount__c != null ? '"' + (String.valueOf(customerConnect.Expected_Amount__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Expected_Closure_Date__c != null ? '"' + (String.valueOf(customerConnect.Expected_Closure_Date__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Industry__c != null ? '"' + (customerConnect.Industry__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Key_Discussion_Description__c != null ? '"' + (customerConnect.Key_Discussion_Description__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Kms_Travelled__c != null ? '"' + (String.valueOf(customerConnect.Kms_Travelled__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.MCM_actionable__c != null ? '"' + (customerConnect.MCM_actionable__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Next_Visit_Date_Time__c != null ? '"' + (String.valueOf(customerConnect.Next_Visit_Date_Time__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Status_of_Discussion__c != null ? '"' + (customerConnect.Status_of_Discussion__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Sub_Type__c != null ? '"' + (customerConnect.Sub_Type__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Visit_End_Date__c != null ? '"' + (String.valueOf(customerConnect.Visit_End_Date__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Visit_Start_Date__c != null ? '"' + (String.valueOf(customerConnect.Visit_Start_Date__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.MOM_Count__c != null ? '"' + (String.valueOf(customerConnect.MOM_Count__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.UniqueCustomerConnect__c != null ? '"' + (customerConnect.UniqueCustomerConnect__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Lead__r.Name != null ? '"' + (customerConnect.Lead__r.Name).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Zone__c != null ? '"' + (customerConnect.Zone__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Owner_Role__c != null ? '"' + (customerConnect.Owner_Role__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Owner_Manager__c != null ? '"' + (customerConnect.Owner_Manager__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Owner_Manager_Role__c != null ? '"' + (customerConnect.Owner_Manager_Role__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Vertical__c != null ? '"' + (customerConnect.Vertical__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Closure_Remarks_Length__c != null ? '"' + (String.valueOf(customerConnect.Closure_Remarks_Length__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Key_Discussion__c != null ? '"' + (String.valueOf(customerConnect.Key_Discussion__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Actionables__c != null ? '"' + (String.valueOf(customerConnect.Actionables__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Role_Name__c != null ? '"' + (customerConnect.Role_Name__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Visit_Mode__c != null ? '"' + (customerConnect.Visit_Mode__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Visit_Status__c != null ? '"' + (customerConnect.Visit_Status__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_In_Location__Latitude__s != null ? '"' + (String.valueOf(customerConnect.Check_In_Location__Latitude__s)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_In_Location__Longitude__s != null ? '"' + (String.valueOf(customerConnect.Check_In_Location__Longitude__s)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_In_Location__c != null ? '"' + (String.valueOf(customerConnect.Check_In_Location__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_In_Time__c != null ? '"' + (String.valueOf(customerConnect.Check_In_Time__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_Out_Location__Latitude__s != null ? '"' + (String.valueOf(customerConnect.Check_Out_Location__Latitude__s)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_Out_Location__Longitude__s != null ? '"' + (String.valueOf(customerConnect.Check_Out_Location__Longitude__s)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_Out_Location__c != null ? '"' + (String.valueOf(customerConnect.Check_Out_Location__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_Out_Time__c != null ? '"' + (String.valueOf(customerConnect.Check_Out_Time__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Created_Today__c != null ? '"' + (String.valueOf(customerConnect.Created_Today__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.EmailBody__c != null ? '"' + (customerConnect.EmailBody__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Button_Visivility__c != null ? '"' + (String.valueOf(customerConnect.Button_Visivility__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_out_Visivility__c != null ? '"' + (String.valueOf(customerConnect.Check_out_Visivility__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Total_Distance__c != null ? '"' + (String.valueOf(customerConnect.Total_Distance__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Accompanied__c != null ? '"' + (customerConnect.Accompanied__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.AcompaniedWith__r.Name != null ? '"' + (customerConnect.AcompaniedWith__r.Name).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_In_Address__c != null ? '"' + (customerConnect.Check_In_Address__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Check_Out_Address__c != null ? '"' + (customerConnect.Check_Out_Address__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Customer_Name__c != null ? '"' + (customerConnect.Customer_Name__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Visit_Date__c != null ? '"' + (String.valueOf(customerConnect.Visit_Date__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Visited_Location__r.Name != null ? '"' + (customerConnect.Visited_Location__r.Name).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Visit__r.Name != null ? '"' + (customerConnect.Visit__r.Name).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Month_Year__c != null ? '"' + (customerConnect.Month_Year__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.MTD_Revenue_Air__c != null ? '"' + (String.valueOf(customerConnect.MTD_Revenue_Air__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.MTD_Revenue_Surface__c != null ? '"' + (String.valueOf(customerConnect.MTD_Revenue_Surface__c)).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.FinancialYear__c != null ? '"' + (customerConnect.FinancialYear__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Issue__c != null ? '"' + (customerConnect.Issue__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Action_Taken__c != null ? '"' + (customerConnect.Action_Taken__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Action_Needed__c != null ? '"' + (customerConnect.Action_Needed__c).replace('"', '""') + '"' : '') + ',' +
                    (customerConnect.Opportunity__r.Name != null ? '"' + (customerConnect.Opportunity__r.Name).replace('"', '""') + '"' : '') + '\n';
            }
            csvData += csvBody;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        String csvContent = csvHeader + csvData;
        Blob csvBlob = Blob.valueOf(csvContent);
        if(csvData != null && csvData != ''){
            S3_Weekly_Report__c s3 = new S3_Weekly_Report__c();
            s3.From__c = sDate;
            s3.To__c = eDate;
            insert s3;
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'CustomerConnect-'+sDate.year()+'/'+sDate.month()+'/'+sDate.day()+'-'+eDate.year()+'/'+eDate.month()+'/'+eDate.day();
            contentVersion.PathOnClient = 'CustomerConnectLastWeek.csv';
            contentVersion.VersionData = csvBlob;
            insert contentVersion;
            
            contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
            
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
            contentDocumentLink.LinkedEntityId = s3.Id;
            contentDocumentLink.ShareType = 'V';
            contentDocumentLink.Visibility = 'AllUsers';
            insert contentDocumentLink;
        }
        /*
        Date finalDate = Date.newInstance(2024,8,11);        
        if(eDate < finalDate){
            Date sNewDate = sDate.addDays(7);
            Date eNewDate = eDate.addDays(7);
            CreateWeeklyCsvOfCustomerConnect b = new CreateWeeklyCsvOfCustomerConnect(sNewDate, eNewDate);
            database.executeBatch(b,2000);
        }
        */
        if(Test.isRunningTest()){
            List<S3_Weekly_Report__c> s3Report = [SELECT Id FROM S3_Weekly_Report__c];
            if(s3Report != null && s3Report.size() > 0){
                AmazonS3Connect.putFileInS3FromObject(new List<Id>{s3Report[0].Id});
                AmazonS3Connect.getFileFromS3(s3Report[0].Id, 'TEST');
            }
        }
    }
    
    public void execute(SchedulableContext SC){
        CreateWeeklyCsvOfCustomerConnect b = new CreateWeeklyCsvOfCustomerConnect();
        database.executeBatch(b,2000);        
    }
}