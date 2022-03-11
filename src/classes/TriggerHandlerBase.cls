public virtual class TriggerHandlerBase {

    public void Handle() {
		if(trigger.isafter && trigger.isinsert)
        {
            handleAfterInsert();
        }
        else if(trigger.isbefore && trigger.isinsert)
        {
            handleBeforeInsert();
        }
        else if(trigger.isafter && trigger.isupdate)
        {
            handleAfterUpdate();
        }
        else if(trigger.isafter && trigger.isdelete)
        {
            handleAfterDelete();
        }
        else if(trigger.isbefore && trigger.isupdate)
        {
            handleBeforeUpdate();
        }
        else if(trigger.isbefore && trigger.isdelete)
        {
            handleBeforeDelete();
        }
    }
    
    public virtual void handleBeforeInsert() {}
    
    public virtual void handleAfterInsert() {}
    
    public virtual void handleAfterUpdate() {}
    
    public virtual void handleAfterDelete() {}
    
	public virtual void handleBeforeUpdate() {} 
    
    public virtual void handleBeforeDelete() {} 
    
}