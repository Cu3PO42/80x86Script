define [], ->
	class Environment
		constructor: -> @clear()

		clear: ->
			@instructions = []
			@mem = null
			@memView = null
			@memMap = {}
			@memArray = []
			@flags =
				carry: false
				zero: false
				sign: false
				overflow: false
				calculate: (num) ->
					@carry = num < 0x0 or num > 0xFFFFFFFF
					@zero = !num
					@sign = !!(num & 0x80000000)
					@overflow = (if num<0 then -num else num+1) > 0x80000000
			@labels = {}
			@nxt = null
			@error = null
			@intervalID = null
			@noTicks = 1
			@freq = 1
			@tickCount = 0