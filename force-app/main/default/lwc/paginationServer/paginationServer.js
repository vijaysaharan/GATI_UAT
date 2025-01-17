import { api, LightningElement } from 'lwc';

export default class PaginationServer extends LightningElement {
   
    totalRecords;
    @api
    recordSize=5;
total;
current;
@api
get records() {
    return this.totalRecords;
  }
set records(data)
{
    this.setAttribute('records', data);
    this.totalRecords=data;
 
   
    console.log(JSON.stringify(data))
     this.total= Math.ceil(this.totalRecords.length/this.recordSize);
     console.log(JSON.stringify(this.totalRecords)+' total records are ' +this.total )
     this.current=1;
     this.updateRecords();
}

    previousHandler(event)
    {
        if(this.current>1)
        {
            this.current=this.current-1;
            this.updateRecords();
        }


    }
    get disabledPrevious()
    {
        return this.current<=1;
    }
    get disabledNext()
    {
        return this.current>=this.total;
    }
    nextHandler(event)
    {
        if(this.current<this.total )
        {
            this.current=this.current+1;
            this.updateRecords();
        }

    }
    updateRecords()
    {
        console.log('record siz is '+this.recordSize);
        const start=(this.current-1)*this.recordSize;
        console.log(`start is ${start}`)
        const end=this.recordSize*this.current;
        console.log(`end is ${end}`)
        this.visibleRecords=this.totalRecords.slice(start,end);  
        console.log(this.visibleRecords)
        this.dispatchEvent(new CustomEvent('update',{
            detail:{
                records:this.visibleRecords
            }
        }));

    }
}