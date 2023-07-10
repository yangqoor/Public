$(function(){

	var $slide = $('.slide');

	//选取所有的幻灯片
	var $li = $('.slide_list li');

	//获取幻灯片的个数
	var $len = $li.length;

	//选择小圆点的容器
	var $points_con = $('.points');

	// 要运动过来的幻灯片的索引值
	var nowli = 0;

	// 要离开的幻灯片的索引值
	var prevli = 0;

	var $prev = $('.prev');
	var $next = $('.next');

	var timer = null;


	var ismove = false;



	// 根据幻灯片的个数，动态创建小圆点
	for(var i=0;i<$len;i++)
	{
		var $newli = $('<li>');

		//第一个小圆点含有'active'的样式
		if(i==0)
		{
			$newli.addClass('active');
		}
		$newli.appendTo($points_con);
	}

	//第一个幻灯片不动，将其他的幻灯片放到右边去
	$li.not(':first').css({'left':760});
	// 获取小圆点
	var $points = $('.points li');

	//小圆点点击切换幻灯片
	$points.click(function(){
		nowli = $(this).index();
		// 修复重复点击的bug
		if(nowli==prevli)
		{
			return;
		}
		$(this).addClass('active').siblings().removeClass('active');
		move();
	})

	//向前的按钮点击切换幻灯片
	$prev.click(function(){

		if(ismove)
		{
			return;
		}

		ismove = true;

		nowli--;
		move();
		$points.eq(nowli).addClass('active').siblings().removeClass('active');
	})

	//向后的按钮点击切换幻灯片
	$next.click(function(){

		if(ismove)
		{
			return;
		}

		ismove = true;

		nowli++;
		move();
		$points.eq(nowli).addClass('active').siblings().removeClass('active');

	})


	timer = setInterval(autoplay,5000);


	$slide.mouseenter(function(){
		clearInterval(timer);
	});


	$slide.mouseleave(function(){
		timer = setInterval(autoplay,3000);
	});


	function autoplay(){		
		nowli++;
		move();
		$points.eq(nowli).addClass('active').siblings().removeClass('active');
	}



	// 幻灯片运动函数，通过判断nowli和prevli的值来移动对应的幻灯片
	function move(){
		// 第一张幻灯片往前的时候
		if(nowli<0)
		{
			nowli = $len-1;
			prevli = 0;
			$li.eq(nowli).css({'left':-760});
			$li.eq(nowli).animate({'left':0});
			$li.eq(prevli).animate({'left':760},function(){
				ismove = false;
			});
			prevli = nowli;
			return;
		}

		//最后一张幻灯片再往后的时候
		if(nowli>$len-1)
		{
			nowli = 0;
			prevli = $len-1;
			$li.eq(nowli).css({'left':760});
			$li.eq(nowli).animate({'left':0});
			$li.eq(prevli).animate({'left':-760},function(){
				ismove = false;
			});
			prevli = nowli;
			return;
		}

		// 幻灯片从右边过来
		if(nowli>prevli)
		{	
			// 把要过来的幻灯片先放到右边去
			$li.eq(nowli).css({'left':760});			
			$li.eq(prevli).animate({'left':-760});			
		}
		else //幻灯片从左边过来
		{
			// 把要过来的幻灯片先放到左边去
			$li.eq(nowli).css({'left':-760});		
			$li.eq(prevli).animate({'left':760});			
		}

		$li.eq(nowli).animate({'left':0},function(){
			ismove = false;
		});
		prevli = nowli;


	}
})