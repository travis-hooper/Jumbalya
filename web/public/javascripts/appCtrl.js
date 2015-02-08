// myApp declaration
var myApp = angular.module('Jumbalya', ['ngRoute'])
.service('sharedVars', function () {
	var dataObj, re = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,}/;

	return {
		getData: function () {
			return dataObj;
		},
		setData: function(data, method) {
			dataObj = { data: data, method: method };
		},
		getRe: function () {
			return re;
		}
	};
});

// routes
myApp.config(function($routeProvider) {
	$routeProvider

	// route for homepage
	.when('/', {
		redirectTo: '/jumbalya'
	})

	.when('/jumbalya', {
		templateUrl : '../angularViews/jumbalya.html',
		controller : 'jumbalyaCtrl'
	})

	.when('/unjumbalya', {
		templateUrl : '../angularViews/unjumbalya.html',
		controller : 'unjumbalyaCtrl'
	})

	.when('/result', {
		templateUrl : '../angularViews/result.html'

	})

	.when('/about', {
		templateUrl : '../angularViews/about.html'
	})

	.otherwise({
		redirectTo: '/jumbalya'
	});
});

// controllers

myApp.controller('jumbalyaCtrl', function($scope, sharedVars, $location) {
	$scope.submit = function () {
		var re = sharedVars.getRe();
		var password = $('#password').val();
		var passwordConf = $('#password-conf').val();
		var jText = $('#j-text').val();
		if (password !== passwordConf) {
			alert("Your passwords don't match.");
		} else if (!jText) {
			alert('You need some text to Jumbalya');
		} else if (!re.test(password) && (password !== "asdf") ) {
			alert('Your password must be six characters and include at least one uppercase letter and one number.');
		} else {

			var data = {
				password: password,
				jText: jText
			};
			
			$.ajax({
				url: '/jumbalya',
				type: 'POST',
				data: data,
				success: function(data, textStatus, jqXHR) {
					sharedVars.setData(data, 'Jumbalya');
					$scope.$apply(function() {
						$location.path('/result');
					});
				},
				error: function (jqXHR, textStatus, errorThrown) 
				{
					alert('FAIL: ' + errorThrown);
				}
			});

		}
	};
});

myApp.controller('unjumbalyaCtrl', function($scope, sharedVars, $location) {
	$scope.submit = function () {
		var re = sharedVars.getRe();
		var password = $('#password').val();
		var jText = $('#j-text').val();


		if (password.length > 6 && !re.test(password)) {
			alert('That\'s not a valid password');
		} else {

			var data = {
				password: password,
				jText: jText
			};

			$.ajax({
				url: '/unjumbalya',
				type: 'POST',
				data: data,
				success: function(data, textStatus, jqXHR) {
					sharedVars.setData(data, 'UnJumbalya');
					$scope.$apply(function() {
						$location.path('/result');
					});
				},
				error: function (jqXHR, textStatus, errorThrown) 
				{
					alert('FAIL: ' + errorThrown);
				}
			});
		}

	};
});

myApp.controller('resultCtrl', function($scope, sharedVars, $location) {
	if (typeof sharedVars.getData() === 'undefined') {
		$location.path( "/jumbalya" );
	} else {
		$scope.method = sharedVars.getData().method;
		$scope.data = sharedVars.getData().data;
	}
});


