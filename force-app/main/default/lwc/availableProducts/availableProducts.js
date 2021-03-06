import { LightningElement, wire, api, track } from 'lwc';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductList from '@salesforce/apex/ProductController.getProductList';
import getOrderItems from '@salesforce/apex/ProductController.getOrderItems';
import ORDERITEM_OBJECT from '@salesforce/schema/OrderItem';
import ORDERITEM_ID from '@salesforce/schema/OrderItem.Id';
import ORDERITEM_QUANTITY from '@salesforce/schema/OrderItem.Quantity';
import ORDERITEM_ORDERID from '@salesforce/schema/OrderItem.OrderId';
import ORDERITEM_PRICEBOOKENTRYID from '@salesforce/schema/OrderItem.PricebookEntryId';
import ORDERITEM_UNITPRICE from '@salesforce/schema/OrderItem.UnitPrice';
import restApiMethod from '@salesforce/apex/ProductController.RestApi';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'List Price', fieldName: 'ListPrice', type: 'currency', currencyIsoCode: 'USD' }
];

export default class AvailableProducts extends LightningElement {

    @track data = [];
    @track responsedata;
    @track disableAct = false;
    @api selected = [];
    @api orderItems = [];
    @api products = [];
    @api recordId;
    @api item;

    refreshTable;
    @api wiredList;
    error;
    columns = columns;

    @wire(getProductList, { recordId: '$recordId' })
    wiredProducts({ error, data }) {

        //console.log(products);
        this.data = data;

        if (this.data) {
            let preparedProducts = [];

            this.data.forEach(product => {
                let preparedProduct = {};

                preparedProduct.Id = product.Id;
                preparedProduct.Product2Id = product.Product2Id;
                preparedProduct.Name = product.Product2.Name;
                preparedProduct.ListPrice = product.UnitPrice;

                preparedProducts.push(preparedProduct);

            });
            this.products = preparedProducts;

        }
        else if (error) {
            this.error = error;
            this.data = undefined;

        }
    }

    @wire(getOrderItems, { recordId: '$recordId' })
    wiredOrderItems(value) {

        this.wiredList = value;
        let { error, data } = value;

        if (data) {
            let preparedItems = [];

            data.forEach(orderItem => {
                let preparedOrderItem = {};

                preparedOrderItem.Id = orderItem.Id;
                preparedOrderItem.Name = orderItem.Product2.Name;
                preparedOrderItem.UnitPrice = orderItem.UnitPrice;
                preparedOrderItem.Quantity = orderItem.Quantity;
                preparedOrderItem.TotalPrice = orderItem.TotalPrice;
                preparedOrderItem.PricebookEntryId = orderItem.PricebookEntryId;
                preparedOrderItem.OrderStatus = orderItem.Order.Status;


                preparedItems.push(preparedOrderItem);

                if (preparedItems[0].OrderStatus == 'Activated') {
                    this.disableAct = true;

                }
            });
            this.orderItems = preparedItems;
        }
        else if (error) {
            this.error = error;
            this.orderItems = undefined;

        }
    }

    handleClick(event) {
        var el = this.template.querySelector('lightning-datatable');
        this.selected = el.getSelectedRows();
        var orderItems = this.orderItems;

        for (let pdt in this.selected) {
            const fields = {};

            //if (orderItems.some( item => item.PricebookEntryId == selected[pdt].Id)) {
            if (orderItems.findIndex(x => x.PricebookEntryId === this.selected[pdt].Id) >= 0) {

                var index = orderItems.findIndex(x => x.PricebookEntryId === this.selected[pdt].Id);
                //console.log(orderItems.findIndex(selected[pdt].Id));

                fields[ORDERITEM_ID.fieldApiName] = orderItems[index].Id;
                fields[ORDERITEM_QUANTITY.fieldApiName] = orderItems[index].Quantity + 1;

                const recordInput = { fields };
                recordInput.fields = fields;
                console.log(recordInput);
                updateRecord(recordInput)
                    .then(() => {

                        orderItems[index].Quantity = orderItems[index].Quantity + 1;

                    });
            } else {
                fields[ORDERITEM_QUANTITY.fieldApiName] = 1;
                fields[ORDERITEM_ORDERID.fieldApiName] = this.recordId;
                fields[ORDERITEM_PRICEBOOKENTRYID.fieldApiName] = this.selected[pdt].Id;
                fields[ORDERITEM_UNITPRICE.fieldApiName] = this.selected[pdt].ListPrice;

                const recordInput = { apiName: ORDERITEM_OBJECT.objectApiName, fields };

                createRecord(recordInput)
                    .then(orderItem => {
                        this.orderItemId = orderItem.Id;
                    });
            }

        }
        this.setSelectedRows = [];
        this.template.querySelector('c-order-products').updateValues(orderItems);
        //return refreshApex(this.orderItems);
    }
    handleConfirm() {
        restApiMethod({ recordId: this.recordId })
            .then(result => {

                //block all user interation
                this.disableAct = true;

            })
    }
}