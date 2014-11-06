define [], ->
	class ParserError extends Error
		constructor: (@notification) ->
		name: "ParserError"