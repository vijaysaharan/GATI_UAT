public class cvHelper {
    public static String getFileExtension(String filename) {
        String ext = '';
        if ( filename != null ) {
            List<String> splits = filename.split('\\.');
            ext = splits.get(splits.size()-1);
        }
        return ext.toLowerCase();
    }
}