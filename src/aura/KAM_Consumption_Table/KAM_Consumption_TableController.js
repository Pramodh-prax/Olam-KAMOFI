({
	scriptLoaded : function(component, event, helper) {
        helper.getConsumptions(component);

         $('[data-toggle="togglelink"').click(function(){
             $(this).parent().toggleClass ('detail_toggle');
             $(this).parent().parent().parent().next('tr.hide').toggle();
         });
    }
})