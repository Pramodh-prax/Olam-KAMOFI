public class OlamLogger {
    private static final Boolean isEnableLog = true;
    
    public static void log(String msg) {
        if(isEnableLog) {
            System.debug('DBG - ' + msg);
        }
    }
    
    public static void logPretty(String msg, object obj) {
        if(isEnableLog) {
            System.debug('DBG - ' + msg + ', OBJECT_VAL = ' + JSON.serializePretty(obj));
        }
    }
}