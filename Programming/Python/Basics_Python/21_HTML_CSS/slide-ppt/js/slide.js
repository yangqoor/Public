$(function(){
	var $li = $('.slide_list li');
	var iLen = $li.length;
	var $prev = $('.prev');
	var $next = $('.next');
	var $points = $('.points');

	var iNowli = 0;
	var iNextli = 0;

	$li.not(':first').css({left:760});
	$li.each(function(i){
		var $sli = $('<li>');
		if(i==0)
		{
			$sli.addClass('active');
		}
		$sli.appendTo($points);

	})

	var $pointsli = $('.points li');


	$pointsli.click(function(){
		iNextli = $(this).index();

		if(iNextli==iNowli)
		{
			return;
		}

		$(this).addClass('active').siblings().removeClass('active');
		move();
	});


	$prev.click(function(){
		iNextli--;
		move();
		$pointsli.eq(iNextli).addClass('active').siblings().removeClass('active');		
	})


	$next.click(function(){
		iNextli++;
		move();
		$pointsli.eq(iNextli).addClass('active').siblings().removeClass('active');		
	})




	function move(){

		if(iNextli<0)
		{
			iNextli= iLen-1;
			iNowli = 0;
			$li.eq(iNextli).css({left:-760});
			$li.eq(iNextli).stop().animate({left:0});
			$li.eq(iNowli).stop().animate({left:760});
			iNowli = iNextli;
			return;
		}

		if(iNextli>iLen-1)
		{
			iNextli = 0;
			iNowli = iLen-1;
			$li.eq(iNextli).css({left:760});
			$li.eq(iNextli).stop().animate({left:0});
			$li.eq(iNowli).stop().animate({left:-760});
			iNowli = iNextli;
			return;
		}

		if(iNextli>iNowli)
		{
			$li.eq(iNextli).css({left:760});
			$li.eq(iNowli).stop().animate({left:-760});			
		}
		else
		{
			$li.eq(iNextli).css({left:-760});
			$li.eq(iNowli).stop().animate({left:760});			
		}

		$li.eq(iNextli).stop().animate({left:0});
		iNowli = iNextli;

	}



})