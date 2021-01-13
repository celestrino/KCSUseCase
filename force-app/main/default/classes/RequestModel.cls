public with sharing class RequestModel {
    
    public String accountNumber {get;set;} 
	public String orderNumber {get;set;} 
	public String status {get;set;} 
    public List<OrderProducts> orderProducts {get;set;}
    
    public class OrderProducts {
		public String name {get;set;} 
		public String code {get;set;} 
		public Double unitPrice {get;set;} 
        public Integer quantity {get;set;} 
    }
}
