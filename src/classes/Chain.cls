public class Chain implements Finalizer {
    Promise[] promises;
  
    public Chain(Promise[] promises){
      this.promises = promises;
    }

    public void execute(FinalizerContext context){
        if(this.promises.size() > 0){
            Promise next = this.promises.remove(0);
            next.promises = this.promises;
            System.enqueueJob(next);
        }
        
        if (context.getResult() == System.ParentJobResult.UNHANDLED_EXCEPTION) {
            System.Debug('Parent Queueable (Job ID: ' + context.getAsyncApexJobId() + '): FAILED!');
            System.Debug('Parent Queueable Exception: ' + context.getException().getMessage());

            KAM_Queuable_Error_Log__c errObj = new KAM_Queuable_Error_Log__c (
            AsyncApexJobId__c = context.getAsyncApexJobId (),
            RequestId__c = context.getRequestId (),
            Result__c = String.valueOf (context.getResult()),
            Exception__c = context.getException().getMessage() + ' :: Exception :' + context.getException()
            );   
            
            Database.SaveResult res = Database.insert(errObj, false);
            if (!res.isSuccess())  {System.debug('Error in creating exception log record');}
        }
    }
}

// switch on context.getResult() {
//     when SUCCESS {
//         System.Debug('Parent Queueable (Job ID: ' + context.getAsyncApexJobId() + '): executed successfully!');    
//     }
//     when UNHANDLED_EXCEPTION {
//         System.Debug('Parent Queueable (Job ID: ' + context.getAsyncApexJobId() + '): FAILED!');
//         System.Debug('Parent Queueable Exception: ' + context.getException().getMessage());

//         KAM_Queuable_Error_Log__c errObj = new KAM_Queuable_Error_Log__c (
//         AsyncApexJobId__c = context.getAsyncApexJobId (),
//         RequestId__c = context.getRequestId (),
//         Result__c = String.valueOf (context.getResult()),
//         Exception__c = context.getException().getMessage() + ' :: Exception :' + context.getException()
//         );   
        
//         Database.SaveResult res = Database.insert(errObj, false);
//         if (!res.isSuccess())  {System.debug('Error in creating exception log record');}
//     }
// }