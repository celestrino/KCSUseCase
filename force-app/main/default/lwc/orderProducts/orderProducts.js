import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOrderItems from '@salesforce/apex/ProductController.getOrderItems';

const columns = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency'},
    {label: 'Quantity', fieldName: 'Quantity', type: 'number'},
    {label: 'Total Price', fieldName: 'TotalPrice', type: 'currency'}
];

export default class OrderProducts extends LightningElement {

    @api values;
    @track data = [];
    @api recordId;

    error;
    columns = columns;

    @api
    updateValues(teste){
        this.value = teste;
        if(this.values){
            refreshApex(this.values);
        }
    }
}