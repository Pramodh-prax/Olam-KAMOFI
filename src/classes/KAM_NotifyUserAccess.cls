public class KAM_NotifyUserAccess {

    public static void notifyUserAccess(Account acc,Account_Plans__c acctPlans,Account_Plans__Share acctShare,String UserName,String userId){  
        // Get the Id for our custom notification type
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                 FROM CustomNotificationType 
                 WHERE DeveloperName='Olam_Custom_Notification']; 
            
            // Create a new custom notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            
            // Set the contents for the notification
            notification.setTitle('Account Plan successfully shared');
            notification.setBody('Hi '+UserName+', you have been given '+acctShare.AccessLevel+' access to the '+acctPlans.Name+' of '+acc.Name+'. Please click here for details.');
            
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(acc.Id);
            
            // Actually send the notification
            try {
                notification.send(new Set<String> {userId});
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }

        
    }

}