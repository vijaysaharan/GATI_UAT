public with sharing class CSVIterator implements Iterator<CSVIterator.CsvRow>
{
   private List<Map<String,Object>> mapCSVData;
   private Integer mapintroValue;
   public CSVIterator(List<Map<String,String>> fileData)
   {
      mapCSVData = fileData;
      mapintroValue = 0; 
   }
   public Boolean hasNext()
   {    
      return mapCSVData.size() -1> mapintroValue ? true : false;
   }
   public CsvRow next()
   {
       if(hasNext())
       {

        CsvRow  row= new CsvRow((map<string,string>)mapCSVData.get(mapintroValue));
        mapintroValue++;
        return row;
       }
       else {
        throw new NoSuchElementException();
       }
   }
  
   public class CsvRow {
    public map<string,string>  tokenList;
    public CsvRow (map<string,string> tokenList) {
      this.tokenList = tokenList;
    }
}
}