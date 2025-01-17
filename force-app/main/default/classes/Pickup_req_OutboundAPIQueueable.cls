/*
Name : Pickup_req_OutboundAPIQueueable
Test Class Name : Pickup_req_OutboundAPIQueueableTest
Author : Sumit Gupta (sgupta3@kloudrac.com)
Date : Mar 04, 2022
Desc : 
Ref : Pickup_req_OutboundAPIQueueable
*/
public class Pickup_req_OutboundAPIQueueable implements Queueable,Database.AllowsCallouts {
    public List<string> updateIds;
    public Pickup_req_OutboundAPIQueueable(List<String> caseid){
        this.updateIds = caseid;
    }
    
    public void execute(QueueableContext context) {
        system.debug('Pickup_req_OutboundAPIQueueable Called');
       Pickup_req_OutboundAPIClass.Sendpickup(updateIds);
    }
}