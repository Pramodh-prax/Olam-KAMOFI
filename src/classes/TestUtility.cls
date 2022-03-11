@isTest
public class TestUtility {
    public static User getUser(Id profileId, Id roleId, String email, String firstName, String lastName, String alias){
        User user = new User();
        user.firstName = firstName;
        user.lastName = lastName;
        user.profileId = profileId;
        user.username = email;
        user.email = email;
        user.Alias = alias;
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey='en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.UserRoleId = roleId;
        
        return user;
    }
}