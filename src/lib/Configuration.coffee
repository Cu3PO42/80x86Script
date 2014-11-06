define ["angular", "controllers/InterpreterController", "controllers/LoadController"], (angular) ->
	angular.module("80x86Script").config [
		"$routeProvider"
		"$locationProvider"
		($routeProvider, $locationProvider) ->
			$routeProvider
				.when "/interpreter",
					controller: "InterpreterController"
					templateUrl: "partials/interpreter.html"
				.when "/load",
					controller: "LoadController"
					templateUrl: "partials/load.html"
				.otherwise redirectTo: "/load"
			$locationProvider
				.html5Mode(false)
				.hashPrefix('!')
	]