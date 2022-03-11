({
    doInit : function(component, event, helper) {
         var divContents = component.get('v.content');
            var a = window.open('', '', 'height=500, width=500');
            a.document.write('<html>');
            a.document.write('<body > <h1>Div contents are </h1>');
            a.document.write(divContents);
            a.document.write('</body></html>'); 
            a.print();
          // a.document.close();
        
        
    },
	closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "showAccountplanShare" attribute to "Fasle"  
        component.set("v.showAccountplanGenratePdf", false);
    },
    printDiv:function(component, event, helper) {
        
            var divContents = document.getElementById("GFG").innerHTML;
            var a = window.open('', '', 'height=500, width=500');
            a.document.write('<html>');
            a.document.write('<body > <h1>Div contents are </h1>');
            a.document.write(divContents);
            a.document.write('</body></html>'); 
            a.print();
           a.document.close();
        }
})