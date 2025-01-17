trigger New_ttrriger on EmailMessage (after insert,after update) {
    /*
    list<case>caselst =new list<case>();
    List<Case> email1 = [SELECT SuppliedEmail From Case where Status='Closed'and(Origin='Email')];
    system.debug('email1'+trigger.new.size());
    for(EmailMessage e : trigger.new){
        if(e.Incoming == True && e.FromAddress==email1[0].SuppliedEmail && e.FirstOpenedDate	
           <date.today()){
               Case cc = new Case();
               cc.SuppliedEmail = e.FromAddress; 
               cc.Status = 'Open';
               caselst.add(cc);
           }
    }
    insert caselst;
*/
}