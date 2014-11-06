define ["angular", "factories/SourceFactory"], (angular) ->
	angular.module("80x86Script.Factories").controller "LoadController", [
		"$scope"
		"SourceFactory"
		($scope, SourceFactory) ->
			$scope.srcRef = SourceFactory

			input = document.getElementById("drop")
			noop = (e) ->
				e.stopPropagation()
				e.preventDefault()
			input.addEventListener("dragenter", noop, false)
			input.addEventListener("dragexit", noop, false)
			input.addEventListener("dragover", noop, false)
			input.addEventListener("drop", (e) ->
				noop(e)
				files = e.dataTransfer.files
				if files.length > 0
					reader = new FileReader()
					reader.onload = (e) -> $scope.$apply(->$scope.srcRef.src = e.target.result)
					reader.readAsText(files[0])
			, false)
	]