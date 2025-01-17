({
	init : function (component) { 
    const flow = component.find("ServiceRequest"); 
    flow.startFlow("Service_Request");
  },
})