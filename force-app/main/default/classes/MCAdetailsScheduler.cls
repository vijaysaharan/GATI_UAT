public class MCAdetailsScheduler implements Schedulable {
    
     public void execute(SchedulableContext sc) {
      MCAdetails b = new MCAdetails(); 
      database.executebatch(b);
         
     }


}