({
	doInit : function(cmp, evt, helper) {
        var canvasParamList = cmp.get('v.canvasTabsList');
        var canvasParamArray = canvasParamList.split(",");
        var listOfCanvas = [];
        for(let i = 0; i < canvasParamArray.length; i++){
            var tempArray = canvasParamArray[i].split("|");
            var tempTab = {TabName:tempArray[0],CanvasName:tempArray[1] }; 
            debugger;
            listOfCanvas.push(tempTab);
        }
        debugger;
        cmp.set("v.canvasTabsandParameter",listOfCanvas);
		
	}
})