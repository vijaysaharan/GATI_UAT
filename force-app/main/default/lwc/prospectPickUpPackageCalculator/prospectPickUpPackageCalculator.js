import { api, LightningElement, track, wire } from 'lwc';
export default class ProspectPickUpPackageCalculator extends LightningElement {

@track packageList =[{"key":0,"package":0,"height":0,"length":0,"width":0}];
@track TotalVolume=0;
@track TotalPackages=0;
@api totalVol=0;
@api UoM='';
@api recordId;
AddRow(event){
    this.packageList.push({"key":this.packageList.length,"package":0,"height":0,"length":0,"width":0});
}

@api
calculateVolume(event){

    switch(event.target.name)
    {
        case 'package':
            this.packageList[event.target.dataset.item].package =event.target.value;
        break;
        case 'height':
            this.packageList[event.target.dataset.item].height =event.target.value;
        break;
        case 'lenght':
            this.packageList[event.target.dataset.item].length =event.target.value;
        break;
        case 'width':
            this.packageList[event.target.dataset.item].width =event.target.value;
        break;
    }
        this.TotalVolume=0;
        this.TotalPackages=0;
    for(let i=0;i<this.packageList.length;i++)
    {
        this.TotalPackages = parseInt(this.TotalPackages) + parseInt(this.packageList[i].package);
        this.TotalVolume = this.TotalVolume + (this.packageList[i].package * this.packageList[i].height*this.packageList[i].length*this.packageList[i].width);
    }
}

refreshCalculator(event){
    this.packageList =[{"key":0,"package":0,"height":0,"length":0,"width":0}];
    this.TotalVolume=0;
    this.TotalPackages=0;
    this.totalVol=0;
}
}