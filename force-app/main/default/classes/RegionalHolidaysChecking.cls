global class RegionalHolidaysChecking {
    DateTime checkDate1,checkDate2,checkDate3,checkDate4;
    global static Date esclation1(Date checkDate1)
    {
        List<Regional_Holidays__c> h= [select Date__c from Regional_Holidays__c];
        List<Date> dt = new List<Date>();
        DateTime checkDate2,checkDate3,checkDate4;
        for(Regional_Holidays__c hd:h)
        {
            dt.add(hd.Date__c);
        }
        System.debug(dt);
        for(Date h1: dt)
        {
            if(h1==checkDate1)
            {
                checkDate1 = checkDate1.addDays(1);
                System.debug(checkDate1);
                checkDate2 = checkDate1.addDays(1);
                System.debug(checkDate2);
                checkDate3 = checkDate2.addDays(1);
                System.debug(checkDate3);
                checkDate4 = checkDate3.addDays(1);
                System.debug(checkDate4);
                break;
            }
        }
        return checkDate1;
    }
    /*
    public static Date esclation2(Date esclationDay2)
    {
        List<Regional_Holidays__c> h= [select Date__c from Regional_Holidays__c];
        List<Date> dt = new List<Date>();
        DateTime esclationDay3,esclationDay4;
        for(Regional_Holidays__c hd:h)
        {
            dt.add(hd.Date__c);
        }
        for(Date h1: dt)
        {
            if(h1==esclationDay2)
            {
                esclationDay2 = esclationDay2.addDays(1);
                System.debug(esclationDay2);
                esclationDay3 = esclationDay3.addDays(1);
                System.debug(esclationDay3);
                esclationDay4 = esclationDay4.addDays(1);
                System.debug(esclationDay4);
                break;
            }
        }
        return esclationDay2;
    }
    
    public static Date esclation3(Date esclationDay3)
    {
        List<Regional_Holidays__c> h= [select Date__c from Regional_Holidays__c];
        List<Date> dt = new List<Date>();
        DateTime esclationDay4;
        for(Regional_Holidays__c hd:h)
        {
            dt.add(hd.Date__c);
        }
        for(Date h1: dt)
        {
            if(h1==esclationDay3)
            {
                esclationDay3 = esclationDay3.addDays(1);
                System.debug(esclationDay3);
                esclationDay4 = esclationDay4.addDays(1);
                System.debug(esclationDay4);
                break;
            }
        }
        return esclationDay3;
    }
    
    public static Date esclation4(Date esclationDay4)
    {
        List<Regional_Holidays__c> h= [select Date__c from Regional_Holidays__c];
        List<Date> dt = new List<Date>();
        for(Regional_Holidays__c hd:h)
        {
            dt.add(hd.Date__c);
        }
        for(Date h1: dt)
        {
            if(h1==esclationDay4)
            {
                esclationDay4 = esclationDay4.addDays(1);
                System.debug(esclationDay4);
                break;
            }
        }
        return esclationDay4;
    }
*/
}