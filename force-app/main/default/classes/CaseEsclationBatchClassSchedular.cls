public class CaseEsclationBatchClassSchedular implements schedulable {
public static void scheduleme(string jobname)
    {
        LeadSLABatchClassSchedular x= new LeadSLABatchClassSchedular();
        system.schedule(jobName, '0 0 0 ? * * *', x);
    }
    public void execute(schedulablecontext c)
    {
        LeadSLABatchClass exec= new LeadSLABatchClass();
        database.executeBatch(exec);
    }
}