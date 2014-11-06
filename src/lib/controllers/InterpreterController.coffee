define ["angular", "interpreter/Interpreter", "parser/ParserGeneral", "parser/ParserError", "factories/SourceFactory"], (angular, Interpreter, ParserGeneral, ParserError) ->
	angular.module("80x86Script.Controllers").controller "InterpreterController", [
		"$scope"
		"SourceFactory"
		($scope, SourceFactory) ->
			try
				$scope.env = ParserGeneral(SourceFactory.src)
			catch e
				throw e unless e instanceof ParserError
				$scope.env = ParserGeneral("DEF\nASM")
				$scope.env.error = e

			($scope[prop] = obj if Interpreter.controllerLogic.hasOwnProperty(prop)) for prop, obj of Interpreter.controllerLogic

			$scope.isRoot = true
			$scope.callFromRoot = (fun, args) ->
				root = this
				root = root.$parent while !root.isRoot
				fun.apply(root, args)

			$scope.flagState = {}

			$scope.$watch "env.nxt", ->
				mem_loc.changed = false for mem_loc in $scope.env.memArray
				$scope.flagState[flag] = false for flag in ["carry", "zero", "sign", "overflow"]
			for i in [0...$scope.env.memArray.length]
				$scope.$watch "env.memView.getUint32(env.memArray[#{i}].offset, true)", ((x) -> (newValue, oldValue, scope) ->
					$scope.env.memArray[x].val = newValue)(i)
				$scope.$watch "env.memArray[#{i}].val", ((x) -> (newValue, oldValue, scope) ->
					$scope.env.memView.setUint32($scope.env.memArray[x].offset, newValue, true)
					$scope.env.memArray[x].changed = newValue != oldValue)(i)
			for flag in ["carry", "zero", "sign", "overflow"]
				$scope.$watch "env.flags.#{flag}", ((flag) -> (newValue, oldValue, scope) ->
					$scope.flagState[flag] = newValue != oldValue)(flag)

			$scope.env.labelList = []
			$scope.env.labelList[val] = key for key, val of $scope.env.labels
	]