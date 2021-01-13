@isTest
public class ProductControllerTest {
    
    @testSetup static void setup(){
        Pricebook2 pb = new Pricebook2();
        pb.Id = Test.getStandardPricebookId();
        pb.IsActive = true;
        update pb;
        
        List<Product2> products = new List<Product2>();
        for(integer i = 1 ; i<=100 ; i++){
            Product2 auxProd = new Product2();
            auxProd.Name = 'Product '+i;
            auxProd.IsActive = true;
            products.add(auxProd);
        }
        
        insert products;
        
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for(Product2 prod : products){
            PricebookEntry auxPbe = new PricebookEntry();
            auxPbe.UnitPrice = 100;
            auxPbe.Pricebook2Id = pb.Id;
            auxPbe.Product2Id = prod.Id;
            auxPbe.IsActive = true;
            pricebookEntries.add(auxPbe);
        }
        
        insert pricebookEntries;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contract contract = new Contract(AccountId = account.Id,Status='Draft');
        insert contract;
        contract.Status = 'Activated';
        update contract;
        
        Order order = new Order(
            ContractId = contract.Id, 
            Pricebook2Id = pb.Id,
            Status = 'Draft',
            EffectiveDate = System.today().addDays(1)
        );
        insert order;
        
        OrderItem orderItem = new OrderItem();
        orderItem.PricebookEntryId = pricebookEntries[0].Id;
        orderItem.Product2Id = pricebookEntries[0].Product2Id;
        orderItem.UnitPrice = 100;
        orderItem.OrderId = order.Id;
        orderItem.Quantity = 1;
        
        insert orderItem;
    }
    
    @isTest
    static void main(){
        Order myOrder = [SELECT Id FROM Order LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CallOutMock());
        
        
        List<PriceBookEntry> pbeReturn = ProductController.getProductList(myOrder.Id);
        List<OrderItem> itemReturn = ProductController.getOrderItems(myOrder.Id);
        ProductController.updateRecords(myOrder.Id);
        
        Test.startTest();
        String callOutReturn = ProductController.RestApi(myOrder.Id);
        Test.stopTest();
        
    }

}