public with sharing class ProductController {

    @AuraEnabled(cacheable=true)
    public static List<PriceBookEntry> getProductList(Id recordId){

        System.debug('record Id ' +recordId);
        Order order = [Select Id, Pricebook2Id from Order Where Id =: recordId Limit 1];
        System.debug('order '+order);
        System.debug('pricebook '+order.Pricebook2Id);
        //Pricebook2 pbId = [Select Id, Pricebook2Id From Order Where Id = order.Id Limit 1];

        return [Select Product2Id, Product2.Name, UnitPrice From PricebookEntry Where Pricebook2Id =: order.Pricebook2Id and IsActive = true];
    }

    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderItems(Id recordId){

        List<OrderItem> orderItemsList = new List<OrderItem>();

        try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return [Select Id, Order.Status, Product2.Name, UnitPrice, Quantity, TotalPrice, PricebookEntryId from OrderItem Where OrderId =: recordId];
    }

    @AuraEnabled
    public static void updateRecords(String recordId){

        Order order = new Order(Id = recordId);
        order.Status = 'Activated';

        update order;
        //List<OrderItem> items = [Select Id, Status];
    }

    @AuraEnabled
    public static String RestApi(String recordId){

        String resp = null;

        System.debug(recordId);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://testinho.requestcatcher.com/');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);

        RequestModel reqModel = new RequestModel();
        //reqModel.

        String body = '{"accountNumber": "13212312",'+
             '"orderNumber": "123123",'+
             '"type": "order type",'+
             '"status": "order status",'+
             '"orderProducts": [{'+
                 '"name": "product name",'+
                 '"code": "product code",'+
                 '"unitPrice": 10.00,'+
                 '"quantity": 1'+
             '}]}';
         
        request.setBody(body);
        System.debug(request.getBody());

        Http http = new Http();
        HttpResponse response;
        
        try{
            
            response = http.send(request);
            System.debug(response);

            if(response.getStatusCode() == 200){
                updateRecords(recordId);
                resp = response.getBody();

            }else{
                throw new CalloutException(response.getBody());
            }
            
        }catch (Exception e){
            System.debug(response);
            System.debug('exception ' +e);
            throw e;
        }
        return resp;        
    }
}