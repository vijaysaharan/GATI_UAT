public with sharing class CSVIterable implements Iterable<CSVIterator.CsvRow>{
    List<Map<String,String>> data;
    public CSVIterable(List<Map<String,String>> input) {
        data=input;
    }
    public Iterator<CSVIterator.CsvRow> iterator(){
        return new CSVIterator(data);
    }
}