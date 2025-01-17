public class CCLatLongCompare {
    public static void latLong(Account acc){
        Double aclat = acc.BillingLatitude;
        Double aclong = acc.BillingLongitude;
        List<Account> acList = [Select BillingLatitude,BillingLongitude from Account where BillingCity = :acc.BillingCity ];
        for(Account ac: acList){
            if(ac.BillingLatitude>=(aclat-1)&&ac.BillingLatitude<=(aclat+1)&&ac.BillingLongitude>=(aclong-1)&&ac.BillingLongitude<=(aclong+1)){
                system.debug(ac);
            }
        }
    }
}