define ["interpreter/Instructions", "interpreter/ExecutionErrors"], (Instructions, Errors) ->
	class Interpreter
		@controllerLogic = do ->
			error_handle = (fn) -> ->
				try
					fn.apply(this, arguments) if @env.nxt?
				catch error
					@cancelClock()
					@env.nxt = null unless error.name == "BRKError"
					@env.error = switch error.name
						when "HLTError", "BRKError", "ReadOnlyError" then error
						else
							if error instanceof RangeError then new Errors.InvalidAddressError()
							else throw error

			{
				tick: error_handle (n) ->
					@env.nxt = @env.instructions[@env.nxt].exec() for i in [0...n]
					throw new Errors.HLTError(@env.instructions.length-1) if @env.nxt >= @env.instructions.length

				run: error_handle ->
					@env.nxt = @env.instructions[@env.nxt].exec() while @env.nxt < @env.instructions.length
					throw new Errors.HLTError(@env.instructions.length-1)

				clock: (freq) ->
					if @env.nxt? and not @env.intervalID?
						@tick(1)
						@env.intervalID = setInterval((=> @$apply(=> @tick(1))), 1000/freq)

				cancelClock: ->
					clearInterval(@env.intervalID) if @env.intervalID?
					@env.intervalID = null

				updateNext: (next) ->
					@env.nxt = next
					@env.error = null

				setBreakpoint: (line) ->
					@env.instructions[line] = new Instructions._BRK(@env.instructions[line], (=> @env.error = null))

				setOneTimeBreakpoint: (line) ->
					@env.instructions[line] = new Instructions._BRKONCE(@env.instructions[line], (=>
						@env.error = null
						@unsetBreakpoint(line)
					))

				unsetBreakpoint: (line) ->
					@env.instructions[line] = @env.instructions[line].org

				toggleBreakpoint: (line) ->
					if @env.instructions[line].org?
						if @env.instructions[line].brkOnlyOnce
							@unsetBreakpoint(line)
						else
							@unsetBreakpoint(line)
							@setOneTimeBreakpoint(line)
					else
						@setBreakpoint(line)

				toggleFlag: (flag) ->
					@env.flags[flag] = !@env.flags[flag]
			}