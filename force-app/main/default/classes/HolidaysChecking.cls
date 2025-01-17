global class HolidaysChecking {
    global static void esclation(List<Case> cases){
        BusinessHours stdBusinessHours = [SELECT Id FROM Businesshours WHERE isDefault = true];
        DateTime checkDate1 = Date.today().AddDays(1);
        DateTime outDate1 = (BusinessHours.add(stdBusinessHours.id, checkDate1, 1)).date();
        String outDate1IST = outDate1.format('yyyy-MM-dd HH:mm:ss', 'IST');
        outDate1 = getDateTime(outDate1IST);
        
        DateTime checkDate2 = outDate1.addDays(1);
        DateTime outDate2 = (BusinessHours.add(stdBusinessHours.id, checkDate2, 1)).date();
        String outDate2IST = outDate2.format('yyyy-MM-dd HH:mm:ss', 'IST');
        outDate2 = getDateTime(outDate2IST);
        
        DateTime checkDate3 = outDate2.addDays(1);
        DateTime outDate3 = (BusinessHours.add(stdBusinessHours.id, checkDate3, 1)).date();
        String outDate3IST = outDate3.format('yyyy-MM-dd HH:mm:ss', 'IST');
        outDate3 = getDateTime(outDate3IST);
        
        DateTime checkDate4 = outDate3.addDays(1);
        DateTime outDate4 = (BusinessHours.add(stdBusinessHours.id, checkDate4, 1)).date();
        String outDate4IST = outDate4.format('yyyy-MM-dd HH:mm:ss', 'IST');
        outDate4 = getDateTime(outDate4IST);
        
        for(Case c: cases){
            if(checkDate1 == outDate1 ){
                c.Esclation_Date1__c=Date.today().addDays(1);
            } else {
                c.Esclation_Date1__c=outDate1 - 1/4.36363636363636;
            }
            if(checkDate2 == outDate2 ){
                c.Esclation_Date2__c=outDate2 - 1/4.36363636363636;
            } else {
                c.Esclation_Date2__c=outDate2 - 1/4.36363636363636;
            } 
            
            if(checkDate3 == outDate3 ){
                c.Esclation_Date3__c=outDate3 - 1/4.36363636363636;
            } else {
                c.Esclation_Date3__c=outDate3 - 1/4.36363636363636;
            } 
            
            if(checkDate4 == outDate4 ){
                c.Esclation_Date4__c=outDate4 - 1/4.36363636363636;
            } else {
                c.Esclation_Date4__c=outDate4 - 1/4.36363636363636;
            } 
        }    
    }
    
    public static DateTime getDateTime(string dtIST){
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