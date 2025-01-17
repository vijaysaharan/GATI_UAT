import { LightningElement, wire, track,api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/chartjs';
import getApexJobStatus from '@salesforce/apex/ApexJobController.getApexJobStatus';
import ApexJobsTableData from '@salesforce/apex/ApexJobController.ApexJobsTableData';


export default class ProgressChart extends LightningElement {

    @api batchJobId;

    @track tableData = [];
    @track CompletedStatus = false;
    @track progress = 0;

    showErrorButton = false;
    chart;

    tableColumns = [
        {
            label: 'Apex Job Id',
            fieldName: 'Id'
        },
        {
            label: 'Job Type',
            fieldName: 'JobType'
        },
        {
            label: 'Status',
            fieldName: 'Status'
        },
        /*{
            label: 'Status Detail',
            fieldName: 'ExtendedStatus'
        },*/
        {
            label: 'Job Items Processed',
            fieldName: 'JobItemsProcessed'
        },
        {
            label: 'Total JobItems',
            fieldName: 'TotalJobItems'
        },
        {
            label: 'Number Of Errors',
            fieldName: 'NumberOfErrors'
        },
        {
            label: 'Completed Date',
            fieldName: 'CompletedDate'
        },
        /*{
            label: 'Method Name',
            fieldName: 'MethodName'
        }*/
    ];

    progressChart(){
        console.log(this.batchJobId);
        getApexJobStatus({JobId : this.batchJobId})
        .then((data)=>{
            this.progress = data.progress;
            console.log('in getApexJob----> ~' + this.progress);
            this.updateChart(this.progress);
            if (data.isCompleted) {
                this.CompletedStatus = true;
            }
        })
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, chartjs)
        ]).then(() => {
            this.renderChart(this.progress);
        });
    }

    connectedCallback() {
;
        this.loadData();
        

        this.refreshInterval = setInterval(() => {
            if(this.progress != 100 && this.CompletedStatus == false){
                this.loadData();
                this.renderChart(this.progress);
            }
        }, 10000);

    }


    loadData() {
        ApexJobsTableData({JobId : this.batchJobId})
            .then(resData => {
                this.tableData = resData;
                var jobitemProcessed = 0;
                var totalJobItem = 0;
                this.tableData.forEach(ele => {
                    jobitemProcessed += ele.JobItemsProcessed;
                    totalJobItem += ele.TotalJobItems;
                })
                this.progress = (jobitemProcessed / totalJobItem)*100;  

                if(this.progress == 100){
                    this.showErrorButton = true;
                }
               
            })
            .catch((error) => {
                console.log('error while fetch Jobs--> ' + JSON.stringify(error));
            });
    }

    disconnectedCallback() {
        // clearInterval(this.refreshInterval);
    }

    renderChart(progress) {
        const ctx = this.template.querySelector('canvas.chart').getContext('2d');
        var p = JSON.parse(JSON.stringify(progress));

        this.chart = new window.Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Progress', 'Remaining'],
                datasets: [{
                    data: [p, 100 - p],
                    backgroundColor: ['#8BC34A', '#999999']
                }]
            },
            options: {
                title: {
                    display: true,
                    text: 'Apex Job Progress'
                },
                responsive: true,
                maintainAspectRatio: false,
                // width: 300,
                // height: 300
            }
        });
    }

    updateChart(progress) {
        if (this.chart) {
            console.log(progress);
            this.chart.data.datasets[0].data = [progress, 100 - progress];
            this.chart.update();
        }
    }

    handleErrorCsvClick(){
        this.dispatchEvent(new CustomEvent('errorcsvdemand'));
    }
}