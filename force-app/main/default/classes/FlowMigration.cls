public class FlowMigration {
	 public static void updateTaskandApproval(List<case> newMap){
       //  System.debug('--- check 1 task--');
      //  list<case> listToUpdate = new List<Case>();
        for(Case c : newMap){
            if(c.OwnerId != null && c.Status != 'Closed' && (c.Type == 'ADD Extension' || c.Type == 'Bill back of Expenses' || c.Type == 'Appointment Delivery' || c.Type == 'Claim' || c.Type == 'Exception' ) ){
                c.ADD_Approval_Status__c = 'Y';
                /*if(c.OwnerId != UserInfo.getUserId() && c.Type != 'Claim' && c.Type != 'Exception' ){
                   //caa.Case_Owner__c = c.OwnerId;
                }*/
            //   listToUpdate.add(c); 
            }
        }
         /*if(!listToUpdate.isEmpty() && listToUpdate.size()>0){
             // System.debug('--- check 2 task updated--'+listToUpdate);
             update listToUpdate;
         }*/
    }
}