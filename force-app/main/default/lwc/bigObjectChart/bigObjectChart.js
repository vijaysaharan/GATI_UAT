import { LightningElement, api, track } from 'lwc';
import {subscribe,unsubscribe,onError,setDebugFlag,isEmpEnabled} from 'lightning/empApi';
import getDataForChart from '@salesforce/apex/BigObjectChartController.getDataForChart';


const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
]

const monthCountMap = [
    [0,0],[1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],[9,0],[10,0],[11,0]
]

export default class BigObjectChart extends LightningElement {
    @api recordId;
    @track dataList = [];
    @track detailForChart = [];
    @track labelsForChart = [];
    @api filedName;
    @api chartType = 'bar';
    @api dateField = false;
    @track dateObjToShow = [];
    @track monthLabel = months;
    @api relatedObject;
    @api relatedFieldAtObject;


    connectedCallback(){
        getDataForChart({recordId : this.recordId, filedName: this.filedName,relatedFieldAtObject : this.relatedFieldAtObject,relatedObject: this.relatedObject}).then(res=>{
            this.dataList = JSON.parse(res);
            if(!this.dateField){
                var chartMap = new Map();
                this.dataList.forEach(element => {
                    if(chartMap.has(element[this.filedName])){
                        var count = chartMap.get(element[this.filedName]);
                        count = count + 1;
                        chartMap.set(element[this.filedName], count);
                    }else{
                        chartMap.set(element[this.filedName], 1);
                    }
                });
    
                this.labelsForChart = Array.from(chartMap.keys());
                this.detailForChart = Array.from(chartMap.values());
            }
            // for date
            else{
                var chartMap = new Map();
                this.dataList.forEach(element => {
                    var eleInDate = new Date(element[this.filedName]);
                    if(eleInDate!='Invalid Date'){
                        var year = eleInDate.getFullYear();
                        var monthc = eleInDate.getMonth();
                        if(chartMap.has(year)){
                            var monthMap = chartMap.get(year);
                            if(monthMap.has(monthc)){
                                var count = monthMap.get(monthc);
                                count += 1;
                                monthMap.set(monthc, count);
                            }else{
                                monthMap.set(monthc,1);
                            }
                        }else{
                            chartMap.set(year, new Map(monthCountMap));
                            var monthMap = chartMap.get(year); 
                            var count = monthMap.get(monthc);
                            count += 1;
                            monthMap.set(monthc, count);
                        }
                    }
                });
                var objList = [];
                chartMap.forEach((value,key) => {
                    var obj = {
                        YEAR : key,
                        DETAILLIST : Array.from(value.values())
                    }
                    objList.push(obj);
                });
                this.dateObjToShow = objList;
                console.log(chartMap);
                console.log(objList);
                    
               
            }
        })
    }

}