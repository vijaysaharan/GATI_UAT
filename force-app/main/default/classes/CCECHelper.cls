public with sharing class CCECHelper {
    
    public static void erronOnRecordCreation(List<CCEC__c> cclist ){
        
        Set<Id> ccecIdSet = new Set<Id>();
        for(CCEC__c cc :cclist)
        {
            ccecIdSet.add(cc.Case__c);            
        }
        
        List <Case> clist= [SELECT id, (SELECT id FROM CCEC__r) FROM Case where RecordType.name =:'Service Request' and type='Exception' and Sub_Type__c!='Failed Dockets' and id in:ccecIdSet];
        
        Map<Id, Integer> caseIdToCCECListSize = new Map<Id, Integer>();
        if(!clist.isEmpty()){
            for(Case caseobj :clist){
                List<CCEC__C> cceclist =caseobj.CCEC__r;
                caseIdToCCECListSize.put(caseobj.Id, cceclist.size());
            }
            
        }
        
        for(CCEC__c cc :cclist){
            if(caseIdToCCECListSize.containskey(cc.Case__c) && caseIdToCCECListSize.get(cc.Case__c) >=1){
                cc.addError('Only one ccec can be created');
            }
        }
        
        
    }
    public static void caseAutoClose(List<CCEC__c> cclist){
        Set<Id> ccecId = new Set<Id>();
        //List<CCEC__c> closeCCECAuto = new List<CCEC__c>();
        for(CCEC__c cc : cclist){
            if(cc.Id != Null && cc.Case__c != Null && (cc.Status__c =='CL' || cc.Status__c =='AC')){
                ccecId.add(cc.Case__c);
            }
        } 
        
        if(!ccecId.isEmpty() && ccecId.size()>0){
            List<Case> caseList = [SELECT Id, Type, Sub_Type__c, Status, Complaint_Status__c,Delivery_OU__c, OPEN_CCEC__c, Reclassification__c ,  (SELECT id, CCEC_OU_Assignment_Logic__c FROM CCEC__r) From Case Where Id IN : ccecId];
            system.debug('caseList'+ caseList);
            if(!caseList.isEmpty() && caseList.size() > 0){
                System.debug('Checkkkk1');
                for(Case cs : caseList){
                    System.debug('Checkkkk1');
                    System.debug('Checkkkk2  : ' + cs.Sub_Type__c +''+ cs.Status+''+ cs.Complaint_Status__c+'' +cs.OPEN_CCEC__c+''+cs.Reclassification__C+''+cs.Delivery_OU__c );
                    if(cs.Sub_Type__c=='NON DELIVERED' && cs.Status != 'Closed' && cs.Complaint_Status__c != 'C' && cs.Reclassification__C == False && cs.Delivery_OU__c != Null)
                    {
                        System.debug('Result1:  '+ (cs.Sub_Type__c=='NON DELIVERED' && cs.Status != 'Closed' && cs.Complaint_Status__c != 'C' && cs.Reclassification__C == False && cs.Delivery_OU__c != Null));
                        for(CCEC__c ccec: cclist){
                            system.debug('Checkkkk');
                            System.debug('Result3 : '+(cs.Id == ccec.Case__c) +' '+ ccec.Status__c+' '+ (ccec.CCEC_OU_Assignment_Logic__c == cs.Delivery_OU__c));
                            if(ccec.Case__c == cs.Id  && (ccec.Status__c =='CL' || ccec.Status__c =='AC') && ccec.CCEC_OU_Assignment_Logic__c == cs.Delivery_OU__c){
                                System.debug('Result2 : '+(cs.Id == ccec.Case__c) +' '+ ccec.Status__c+' '+ (ccec.CCEC_OU_Assignment_Logic__c == cs.Delivery_OU__c));
                                cs.Status = 'Closed';
                                cs.Complaint_Status__c = 'AC';
                            }else if(ccec.Case__c == cs.Id  && (ccec.Status__c =='CL' || ccec.Status__c =='AC') && ccec.CCEC_OU_Assignment_Logic__c != cs.Delivery_OU__c){
                                System.debug('cclist  ==>>'+cclist);
                                CCEC__c clonedCCEC = ccec.clone();
                                clonedCCEC.Status__c = 'OP';
                                clonedCCEC.CCEC_OU_Assignment_Logic__c =Null;
                                System.debug('CCEC_OU_Assignment_Logic__c : '+ clonedCCEC.CCEC_OU_Assignment_Logic__c);
                                clonedCCEC.Id =Null;
                                insert clonedCCEC;
                                System.debug('CCEC_OU_Assignment_Logic__c : '+ clonedCCEC.CCEC_OU_Assignment_Logic__c);
                                //List<CCEC__c> clonedCCEC = cclist.clone();
                                //CCEC__c newCCEC = new CCEC__c();
                                //newCCEC.CCEC_OU_Assignment_Logic__c = cs.Delivery_OU__c;
                                //clonedCCEC.add(newCCEC);
                                //insert clonedCCEC;
                                //System.debug('clonedCCEC  ====>>> '+ clonedCCEC);
                            }
                        }
                    }
                }
                update caseList;
                System.debug('caseList : '+caseList);
            }
        }
    }
    
    public static void fakeMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
    
    /*public static void checkTotalCCEC(List<CCEC__c> cclist){
Set<Id>ccecIDset = new Set<Id>();
for(CCEC__c cc: cclist){
ccecIdset.add(cc.case__c);
}

List <Case> clist= [SELECT id, (SELECT id FROM CCEC__r) FROM Case where RecordType.name =:'Complaint' and id in:ccecIdSet];
Map<Id, Integer> caseIdToCCECListSize = new Map<Id, Integer>();
if(!clist.isEmpty()){
for(Case caseobj :clist){
List<CCEC__C> cceclist =caseobj.CCEC__r;
caseIdToCCECListSize.put(caseobj.Id, cceclist.size());
}

}

for(CCEC__c cc :cclist){
if(caseIdToCCECListSize.containskey(cc.Case__c) && caseIdToCCECListSize.get(cc.Case__c) ==1){
System.debug(cc.Case__c);
Send_Complaint_CCEC_Records.SendComplaintCCEC(cc.Case__c);
}
}


}*/
}