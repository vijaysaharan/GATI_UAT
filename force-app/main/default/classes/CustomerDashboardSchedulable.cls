public class CustomerDashboardSchedulable implements Schedulable {
	public void execute(SchedulableContext SC){
        Date sDate = Date.newInstance(System.today().year(), System.today().month(), 1);
        Date eDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(1).addDays(-1);
        database.executeBatch(new CustomerDashboardCalculationsBatch(sDate,eDate,'MTD'));
    }
}