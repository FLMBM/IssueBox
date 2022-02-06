import { LightningElement, wire, track, api } from 'lwc';  
import getTicketList from '@salesforce/apex/HelpDesk.getTicketList';  
import getTicketCount from '@salesforce/apex/HelpDesk.getTicketCount';  
import { refreshApex } from '@salesforce/apex';



const columns = [
    { label: 'Ticket No', fieldName: 'urlId', 'initialWidth': 100, 'type': 'url', typeAttributes: { label: { fieldName: 'name' } }},
    { label: 'Status', fieldName: 'status',  'initialWidth': 75 },
    { label: 'Type', fieldName: 'type',  'initialWidth': 120 },
    { label: 'Priority', fieldName: 'priority',  'initialWidth': 100 },
    { label: 'Assigned To', fieldName: 'urlUid',  'initialWidth': 110, 'type': 'url', typeAttributes: { label: { fieldName: 'assignedto' } } },
    { label: 'Details', fieldName: 'details' },
];
const PAGE_SIZE = 10; 
//Pagination sample from https://salesforcelightningwebcomponents.blogspot.com/2019/04/pagination-with-search-step-by-step.html
 export default class RecordList extends LightningElement {  

    @track currentpage = 1;
    @track pagesize = PAGE_SIZE;
    @track tickets = Array();
    @track columns = columns;
    @track error;
    @track totalpages;  
    @track totalrecords;
    localCurrentPage = this.currentpage;

    //Sending totalrecords as we want wire to refresh when this number changes
    //Without it, it will not refreshbecause other variables may stay the same
    @wire(getTicketList, { pageNumber: '$currentpage', pageSize: '$pagesize', totalRecords: '$totalrecords' })
    wiredTicketList(value) {
        this.wiredTicketListPointer = value; 
        const { error, data } = value;
        if (data) {
            this.tickets = [];//Remove old rows and add new rows
            for(var i = 0; i < data.length; i++){
                let urlUid = (typeof(data[i].helpdesk__AssignedTo__c) != 'undefined')?'/'+data[i].helpdesk__AssignedTo__c:'';
                let assignedToName = (typeof(data[i].helpdesk__AssignedTo__r) != 'undefined')?data[i].helpdesk__AssignedTo__r.Name:'';
                this.tickets.push({
                    'id': data[i].Id, 'name': data[i].Name, 
                    'urlId': '/'+data[i].Id, 'urlUid': urlUid,
                    'status': data[i].helpdesk__Status__c, 'type': data[i].helpdesk__Type__c,
                    'priority': data[i].helpdesk__Priority__c, 'assignedto': assignedToName,
                    'details': data[i].helpdesk__Details__c,
                });
            }
            /**/
            this.error = undefined;  
        } else if (error) {
            this.error = error;  
            this.tickets = []; 
        }
    }
    @wire(getTicketCount)
    wiredTicketCount(value) {
        this.wiredTicketCountPointer = value; 
        const { error, data } = value;

        //Checking for =0 because it's possible that all records were deleted
        //So if it's 0 then we need to refresh the list to remove all the records
        if (typeof(error) == 'undefined' && data >= 0) {
            this.totalrecords = data;  
            if (!isNaN(data) && data >= 0) {  
                this.totalpages = Math.ceil(data / this.pagesize);
            } else { 
                this.totalpages = 0;  
                this.totalrecords = 0;  
            }
        } else if (error) {
            this.error = error; 
            this.totalrecords = 0;  
        }
    }
   
    getLatest(){
        //Reset to page#1 on refresh
        //Scenario: User maybe on a later page but records get deleted (or ownership changed for a particular user)
        //In that scenario, it may show empty page because there are no records for that page; hence reset to first 1st page (to show at leaset some records)
        
        this.currentpage = 1;

        //Because this.totalrecords will change in this wire, the other wired method for records will automatically refresh
        refreshApex(this.wiredTicketCountPointer);
    }
  
    handlePrevious() {  
        if (this.currentpage > 1) {  
            this.currentpage = this.currentpage - 1; 
        } 
    }  
    handleNext() {  
        if (this.currentpage < this.totalpages)  {
            this.currentpage = this.currentpage + 1; 
        }
    }  
    handleFirst() {
        if(this.currentpage !== 1){
            this.currentpage = 1;  
        }
    }  
    handleLast() {  
        if(this.classList !== this.totalpages){
            this.currentpage = this.totalpages; 
        }
    }
}