define ["parser/ParserStandard", "interpreter/Environment"], (ParserStandard, Environment) ->
	(source) ->
		env = new Environment()
		ParserStandard.call(env, source)
		env