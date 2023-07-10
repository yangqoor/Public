$(function(){

	var $username = $('#user_name');

	$username.blur(function(){
		check_username();
	});

	$username.click(function(){
		$(this).next().hide();
	});

	function check_username(){

		var val = $username.val();
		var re = /^\w{6,20}$/;

		if(val=='')		{
			$username.next().html('用户名不能为空');
			$username.next().show();
			return;
		}

		if(re.test(val))
		{
			$username.next().hide();
		}
		else
		{
			$username.next().html('用户名是6到20位的数字、字母或下画线');
			$username.next().show();
		}

	}



})