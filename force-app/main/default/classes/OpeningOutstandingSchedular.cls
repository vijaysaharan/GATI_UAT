global class OpeningOutstandingSchedular implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        OpeningOutstandingController openingOustaning = new OpeningOutstandingController();
       database.executeBatch(openingOustaning,200);
    }
    
}