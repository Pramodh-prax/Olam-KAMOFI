public abstract class Promise implements Queueable, Database.AllowsCallouts {
    public Promise[] promises = new Promise[]{};
    public Object passthrough;
  
    public Promise then(object toAdd){
        promises.add((Promise)toAdd);
        return this;
    }
  
    public Promise(){}
  
    abstract public void execute();
  
    public virtual void execute(QueueableContext context){
        Finalizer chain = new Chain(this.promises);
        System.attachFinalizer(chain);

        execute();
    }
  }