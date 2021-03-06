$( document ).ready(function() {
  $(document).ready(function(){

    // Init Menu

    $('#menu > ul > li ul').each(function(index, e){
      var count = $(e).find('li').length;
      var content = '<span class="cnt">' + count + '</span>';
      $(e).closest('li').children('a').append(content);
    });

    $('#menu ul ul li:odd').addClass('odd');
    $('#menu ul ul li:even').addClass('even');

    $('#menu > ul > li > a').click(function() {
      $('#menu li').removeClass('active');
      $(this).closest('li').addClass('active');	
      var checkElement = $(this).next();
      if((checkElement.is('ul')) && (checkElement.is(':visible'))) {
        $(this).closest('li').removeClass('active');
        checkElement.slideUp('normal');
      }
      if((checkElement.is('ul')) && (!checkElement.is(':visible'))) {
        $('#menu ul ul:visible').slideUp('normal');
        checkElement.slideDown('normal');
      }
      if($(this).closest('li').find('ul').children().length == 0) {
        return true;
      } else {
        return false;	
      }	
    });

      // Show/Hide Menu + Switch Captions

    var a=0;
    $(".showhide").click(function(e) {
        //e.preventDefault();
        if (a==0)
          {
              $("#menu").animate({"left":"162px"}, "slow").show();
              $("#a-show").fadeToggle(500);
              $("#a-hide").fadeToggle(500);
              a=1;
          }
        else
           {
             $("#menu").animate({"left":"-160px"}, "slow");
              $("#a-show").fadeToggle(500);
              $("#a-hide").fadeToggle(500);
               a=0;
           }
     });

    $("#canvas").mousedown(function(e) {
      $("#drawhere").fadeOut(150);
    });

  });
});

