public class EinsteinOCRResponse {
    public String task;	
    public Probabilities[] probabilities;
    public class Probabilities {
        public Double probability;
        public String label;	
        public BoundingBox boundingBox;
        public ClsAttributes attributes;
    }
    public class BoundingBox {
        public Integer minX;	
        public Integer minY;	
        public Integer maxX;	
        public Integer maxY;	
    }
   public class ClsAttributes {
		public String tag;	//OTHER
		public String pageNumber;	//1
	}
}