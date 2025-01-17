public class GetCurrLoc {
  public decimal latt { get; set; }       
  public decimal longt { get; set; }

  public void saveRec() {
  //  Journey_plan__c ws = new Journey_plan__c();
    /*intialize your object if already done not needed, then assign as follows*/

 //   ws.Source_Latitude__c = string.valueof(latt);
 ////   ws.Source_Longitude__c = string.valueof(longt);
 //   insert ws; //insert/update/upsert which ever suits you
      system.debug(latt+longt);
  }
}