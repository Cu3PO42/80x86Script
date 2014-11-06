require.config
  shim:
    "angular": "exports": "angular"

require ["angular"], (angular) ->
	angular.module("80x86Script.Factories", [])
	angular.module("80x86Script.Controllers", ["80x86Script.Factories"])
	angular.module("80x86Script", ["80x86Script.Controllers", "80x86Script.Factories"])
	require ["Configuration"], -> angular.bootstrap(document, ["80x86Script"])
