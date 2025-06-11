public class UnmodifiedCaseService {
    public static Integer getUnmodifiedCaseCount() {
        List<Case> cases = [
            SELECT Id, CreatedDate, LastModifiedDate
            FROM Case
            WHERE CreatedDate = TODAY
            LIMIT 10000
        ];
        return cases.size();
    }
}