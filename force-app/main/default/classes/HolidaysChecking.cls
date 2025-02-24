global class HolidaysChecking {
    global static void esclation(List<Case> cases)
    {
        BusinessHours stdBusinessHours = [select id from Businesshours where isDefault = true];
        DateTime checkDate1 = Date.today().AddDays(1);
        System.debug(checkDate1);
        DateTime outDate1 = (BusinessHours.add(stdBusinessHours.id, checkDate1, 1)).date();
        System.debug(outDate1);
        String outDate1IST = outDate1.format('yyyy-MM-dd HH:mm:ss', 'IST');
        outDate1 = getDateTime(outDate1IST);
        System.debug(outDate1);
        
        DateTime checkDate2 = outDate1.addDays(1);
        System.debug(checkDate2);
        DateTime outDate2 = (BusinessHours.add(stdBusinessHours.id, checkDate2, 1)).date();
        System.debug(outDate2);
        String outDate2IST = outDate2.format('yyyy-MM-dd HH:mm:ss', 'IST');
        outDate2 = getDateTime(outDate2IST);
        System.debug(outDate2);
        
        DateTime checkDate3 = outDate2.addDays(1);
        System.debug(checkDate3);
        DateTime outDate3 = (BusinessHours.add(stdBusinessHours.id, checkDate3, 1)).date();
        System.debug(outDate3);
        String outDate3IST = outDate3.format('yyyy-MM-dd HH:mm:ss', 'IST');
        outDate3 = getDateTime(outDate3IST);
        System.debug(outDate3);
        
        DateTime checkDate4 = outDate3.addDays(1);
        System.debug(checkDate4);
        DateTime outDate4 = (BusinessHours.add(stdBusinessHours.id, checkDate4, 1)).date();
        System.debug(outDate4);
        String outDate4IST = outDate4.format('yyyy-MM-dd HH:mm:ss', 'IST');
        outDate4 = getDateTime(outDate4IST);
        System.debug(outDate4);
        
        for(Case c: cases)
        {
            if(checkDate1 == outDate1 ){
                c.Esclation_Date1__c=Date.today().addDays(1);
                System.debug(c.Esclation_Date1__c);
            } else {
                c.Esclation_Date1__c=outDate1 - 1/4.36363636363636;
                System.debug(c.Esclation_Date1__c);
            } 
            
            if(checkDate2 == outDate2 ){
                c.Esclation_Date2__c=outDate2 - 1/4.36363636363636;
                System.debug(c.Esclation_Date2__c);
            } else {
                c.Esclation_Date2__c=outDate2 - 1/4.36363636363636;
                System.debug(c.Esclation_Date2__c);
            } 
            
            if(checkDate3 == outDate3 ){
                c.Esclation_Date3__c=outDate3 - 1/4.36363636363636;
                System.debug(c.Esclation_Date3__c);
            } else {
                c.Esclation_Date3__c=outDate3 - 1/4.36363636363636;
                System.debug(c.Esclation_Date3__c);
            } 
            
            if(checkDate4 == outDate4 ){
                c.Esclation_Date4__c=outDate4 - 1/4.36363636363636;
                System.debug(c.Esclation_Date4__c);
            } else {
                c.Esclation_Date4__c=outDate4 - 1/4.36363636363636;
                System.debug(c.Esclation_Date4__c);
            } 
        }    
    }
    
    public static DateTime getDateTime(string dtIST)
    {
        Integer Y,Mnt,D,H,Min,S;
        Y = Integer.valueof(dtIST.substring(0,4));
        Mnt = Integer.valueof(dtIST.substring(5,7));
        D = Integer.valueof(dtIST.substring(8,10));
        DateTime ddd = System.now(); 
        string x = ddd.format(); 
        H = Integer.valueof(ddd.hour());
        Min = Integer.valueof(ddd.minute());
        S = Integer.valueof(ddd.second());
        DateTime real = DateTime.newInstanceGmt(Y, Mnt, D, H, Min, S);
        return real;
    }
}