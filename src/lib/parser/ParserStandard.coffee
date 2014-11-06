define ["interpreter/Instructions", "parser/ParserError", "interpreter/ExecutionErrors"], (Instructions, ParserError, ExecutionErrors) ->
	(source) ->
		valid_instructions =
			mov: 2
			add: 2
			mul: 2
			sub: 2
			div: 2
			mod: 2
			jmp: 1
			cmp: 2
			jl: 1
			jle: 1
			jg: 1
			jge: 1
			je: 1
			jnl: 1
			jnle: 1
			jng: 1
			jnge: 1
			jne: 1
			hlt: 0
		OFFSET_MULTIPLIER = 4
		sourceMatch = /^\s*DEF *\r?\n(?:([\s\S]*?)\r?\n)?ASM *(?:\r?\n([\s\S]*))?$/.exec(source)
		throw new ParserError("Your code does not match the specification.") unless sourceMatch
		mem_array = []
		for def in (sourceMatch[1] or "").split(/\r?\n/)
			continue if /^ *$/.exec(def)
			match = /^([a-zA-Z]+) +(\w+) +(\d+|\[ *\d+(?: *, *\d+)* *\])$/.exec(def)
			throw new ParserError("Invalid memory declaration '#{def}'.") unless match
			val = eval(match[3])
			@memMap[match[2]] = mem_array.length*OFFSET_MULTIPLIER
			switch match[1].toLowerCase()
				when "list"
					start = mem_array.length
					len = if typeof(val) == "number"
						(mem_array.push(0) for i in [0...val])
						val
					else
						Array::push.apply(mem_array, val)
						val.length
					@memArray.push(name: "#{match[2]}[#{i}]", offset: (start+i)*OFFSET_MULTIPLIER) for i in [0...len]
				when "int"
					@memArray.push(name: match[2], offset: mem_array.length*OFFSET_MULTIPLIER)
					mem_array.push(val)
				else throw new ParserError("Type '#{match[1]}' does not exist.")
		re = /\bR(\d+)\b/gi
		for i in [1...Math.max.apply(null, (parseInt(res[1]) while (res = re.exec(sourceMatch[2]))).concat([0]))+1]
			@memMap["R#{i}"] = mem_array.length*OFFSET_MULTIPLIER
			@memArray.push(name: "R#{i}", offset: mem_array.length*OFFSET_MULTIPLIER)
			mem_array.push(0)
		@mem = new ArrayBuffer(mem_array.length*OFFSET_MULTIPLIER)
		@memView = new DataView(@mem)
		memView = @memView
		view32 = new Uint32Array(@mem)
		for i in [0...mem_array.length]
			view32[i] = mem_array[i]
		revisit_instructions = []
		for instruction in (sourceMatch[2] or "").split(/\r?\n/)
			continue if /^ *$/.exec(instruction)
			match = /^([a-zA-Z]+) *?(?: +(\.?\w+|\[ *(\w+)(?: *, *(\w+))? *\])(?: *, *(\w+|\[ *(\w+)(?: *, *(\w+))? *\]) *)?)?$|^(\.?\w+):$/.exec(instruction)
			if match[8]?
				@labels[match[8]] = @instructions.length
			else
				throw new ParserError("Invalid instruction '#{op}'") unless (op = match[1].toLowerCase()) of valid_instructions
				ops = []
				opstring = []
				for i in [0...2]
					ops.push(match[2+i*3]) if match[2+i*3]?
					if match[3+i*3]?
						oprnd = [match[3+i*3]]
						if match[4+i*3]?
							oprnd.push(match[4+i*3])
						opstring.push("[#{oprnd.join(', ')}]")
					else if match[2+i*3]? then opstring.push(match[2+i*3])
				opstring = opstring.join(", ")
				throw new ParserError("Invalid number of arguments (#{ops.length}) for instruction '#{op}'.") unless valid_instructions[op] == ops.length
				ops = if instruction.toLowerCase()[0] != "j" then for operand, i in ops then do (operand, i) =>
					throw new ParserError("Only label identifiers may start with a period.") if operand[0] == "."
					offset = @memMap[operand]
					if match[3+i*3]?
						offset = @memMap[match[3+i*3]]
						throw new ParserError("Variable '#{match[3+i*3]}' was not previously defined.") unless offset? or not isNaN(literal = parseInt(match[3+i*3])) and not match[4+i*3]?
						unless /^R\d+$/.exec(match[3+i*3])
							unless match[4+i*3]?
								offset = literal unless isNaN(literal)
								get: memView.getUint32.bind(memView, offset, true), set: ((val) -> memView.setUint32(offset, val, true))
							else if not isNaN(offset2 = parseInt(match[4+i*3]))
								offset += offset2*OFFSET_MULTIPLIER
								get: memView.getUint32.bind(memView, offset, true), set: ((val) -> memView.setUint32(offset, val, true))
							else if /^R\d+$/.exec(match[4+i*3])
								offset2 = @memMap[match[4+i*3]]
								get: -> memView.getUint32(offset+memView.getUint32(offset2, true)*OFFSET_MULTIPLIER, true)
								set: (val) -> memView.setUint32(offset+memView.getUint32(offset2, true)*OFFSET_MULTIPLIER, val, true)
							else throw new ParserError("Invalid addressing '#{operand}'.")
						else
							unless match[4+i*3]?
								get: -> memView.getUint32(memView.getUint32(offset, true), true)
								set: (val) -> memView.setUint32(memView.getUint32(offset, true), val, true)
							else if not isNaN(offset2 = parseInt(match[4+i*3])*OFFSET_MULTIPLIER)
								get: -> memView.getUint32(memView.getUint32(offset, true)+offset2, true)
								set: (val) -> memView.setUint32(memView.getUint32(offset, true)+offset2, val, true)
							else if /^R\d+$/.exec(match[4+i*3])
								offset2 = @memMap[match[4+i*3]]
								get: -> memView.getUint32(memView.getUint32(offset, true)+memView.getUint32(offset2, true)*OFFSET_MULTIPLIER, true)
								set: (val) -> memView.setUint32(memView.getUint32(offset, true)+memView.getUint32(offset2, true)*OFFSET_MULTIPLIER, val, true)
							else throw new ParserError("Invalid addressing '#{operand}'.")
					else if /^R\d+$/.exec(operand) then get: memView.getUint32.bind(memView, offset, true), set: ((val) -> memView.setUint32(offset, val, true))
					else if not isNaN(literal = parseInt(match[2+i*3])) then get: (-> literal), set: (-> throw new ExecutionErrors.ReadOnlyError("Literals are read only."))
					else if offset? then get: (-> offset), set: (-> throw new ExecutionErrors.ReadOnlyError("Addresses are read only."))
					else throw new ParserError("Variable '#{operand}' was not previously defined.")
				else
					revisit_instructions.push(@instructions.length)
					[ops[0]]
				@instructions.push(new Instructions[match[1].toLowerCase()](@flags, @instructions.length, opstring, ops))
		for i in revisit_instructions
			label = @instructions[i].op1
			throw new ParserError("Unknown label '#{label}'.") unless (dest = @labels[label])?
			do (dest) => @instructions[i].op1 =
				get: ->	dest
				set: -> throw new ExecutionErrors.ReadOnlyError("Labels are read only.")
		if @instructions.length then @nxt = 0
		else
			@error = new ExecutionErrors.HLTError(undefined)