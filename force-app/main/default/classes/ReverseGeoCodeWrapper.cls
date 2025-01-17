public class ReverseGeoCodeWrapper {
    
    public class Address_components {
        public String long_name;
        public String short_name;
        public List<String> types;
    }
    
    public class Geometry {
        public Location location;
        public String location_type;
        public Viewport viewport;
    }
    
    public class Geometry_Z {
        public Viewport bounds;
        public Location location;
        public String location_type;
        public Viewport viewport;
    }
    
    public class Results {
        public List<Address_components> address_components;
        public String formatted_address;
        public Geometry geometry;
        public String place_id;
        public List<String> types;
    }
    
    public class Viewport {
        public Location northeast;
        public Location southwest;
    }
    
    public List<Results> results;
    public String status;
    
    public class Location {
        public Double lat;
        public Double lng;
    }
    
}