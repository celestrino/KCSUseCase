public with sharing class ProductController {

    @AuraEnabled(cacheable=true)
    public static List<PriceBookEntry> getProductList(Id recordId){

        Order order = [Select Id, Pricebook2Id from Order Where Id =: recordId Limit 1];
        
        return [Select Product2Id, Product2.Name, UnitPrice From PricebookEntry Where Pricebook2Id =: order.Pricebook2Id and IsActive = true];
    }

    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItems(Id recordId){

        List<OrderItem> orderItemsList = new List<OrderItem>();
        return [Select Id, Order.Status, Product2.Name, UnitPrice, Quantity, TotalPrice, PricebookEntryId from OrderItem Where OrderId =: recordId];
    }

    @AuraEnabled
    public static void updateRecords(String recordId){

        Order order = new Order(Id = recordId);
        order.Status = 'Activated';

        update order;
    }

    @AuraEnabled
    public static String RestApi(String recordId){

        Order order = [Select Id, Account.AccountNumber, OrderNumber, Status from Order where Id=: recordId];
        
        //List<OrderItem> items = [Select Id, Product2.Name, Product2.ProductCode, UnitPrice, Quantity from OrderItem where OrderId =: recordId];
        
        String resp = null;

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://testinho.requestcatcher.com/');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);

        RequestModel reqModel = new RequestModel();
        reqModel.accountNumber = order.Account.AccountNumber;
        reqModel.orderNumber = order.OrderNumber;
        reqModel.status = order.Status;
        
        List<RequestModel.orderProducts> orderItems = new List<RequestModel.OrderProducts>();
        
        for(OrderItem item : [Select Id, Product2.Name, Product2.ProductCode, UnitPrice, Quantity from OrderItem where OrderId =: recordId]){
            
            RequestModel.OrderProducts reqItem = new RequestModel.OrderProducts();
            reqItem.name = item.Product2.Name;
            reqItem.code = item.Product2.ProductCode;
            reqItem.unitPrice = item.UnitPrice;
            reqItem.quantity = item.Quantity;
            
            orderItems.add(reqItem);
            
        }
        
        reqModel.orderProducts = orderItems;
        
        String body = JSON.serialize(reqModel, true);
         
        request.setBody(body);

        Http http = new Http();
        HttpResponse response;
        
        try{
            
            response = http.send(request);

            if(response.getStatusCode() == 200){
                updateRecords(recordId);
                resp = response.getBody();

            }else{
                throw new CalloutException(response.getBody());
            }
            
        }catch (Exception e){

            throw e;
        }
        return resp;        
    }
}