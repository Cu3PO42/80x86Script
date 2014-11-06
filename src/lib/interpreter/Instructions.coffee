define ["interpreter/ExecutionErrors"], (Errors) ->
	class Instruction
		constructor: (@flags, @addr, @opstring, ops) ->
			@op1 = ops[0]
			@op2 = ops[1]

		name: "GENERIC"

		exec: -> throw new Error("Exec not implemented.")

	_BRK: class InstructionBRK extends Instruction
		constructor: (@org, @clear) ->
			@name = org.name
			@opstring = org.opstring
			@hasStopped = false

		exec: ->
			if @hasStopped
				@hasStopped = false
				@clear()
				@org.exec()
			else
				@hasStopped = true
				throw new Errors.BRKError()

		brkOnlyOnce: false

	_BRKONCE: class InstructionBRKOnce extends InstructionBRK
		brkOnlyOnce: true

	mov: class InstructionMOV extends Instruction
		name: "mov"
		exec: ->
			@op1.set(@op2.get())
			@addr+1

	add: class InstructionADD extends Instruction
		name: "add"
		exec: ->
			res = @op1.get()+@op2.get()
			@op1.set(res)
			@flags.calculate(res)
			@addr+1

	mul: class InstructionMUL extends Instruction
		name: "mul"
		exec: ->
			@op1.set(@op1.get()*@op2.get())
			@addr+1

	sub: class InstructionSUB extends Instruction
		name: "sub"
		exec: ->
			res = @op1.get()-@op2.get()
			@op1.set(res)
			@flags.calculate(res)
			@addr+1

	div: class InstructionDIV extends Instruction
		name: "div"
		exec: ->
			@op1.set((@op1.get()/@op2.get())>>>0)
			@addr+1

	mod: class InstructionMOD extends Instruction
		name: "mod"
		exec: ->
			@op1.set(@op1.get()%@op2.get())
			@addr+1

	jmp: class InstructionJMP extends Instruction
		name: "jmp"
		exec: ->
			@op1.get()

	cmp: class InstructionCMP extends Instruction
		name: "cmp"
		exec: ->
			@flags.calculate(@op1.get()-@op2.get())
			@addr+1

	jl: class InstructionJL extends Instruction
		name: "jl"
		exec: ->
			if @flags.sign!=@flags.overflow then @op1.get() else @addr+1

	jle: class InstructionJLE extends Instruction
		name: "jle"
		exec: ->
			if @flags.sign!=@flags.overflow||@flags.zero then @op1.get() else @addr+1

	jg: class InstructionJG extends Instruction
		name: "jg"
		exec: ->
			if @flags.sign==@flags.overflow&&!@flags.zero then @op1.get() else @addr+1

	jge: class InstructionJGE extends Instruction
		name: "jge"
		exec: ->
			if @flags.sign==@flags.overflow then @op1.get() else @addr+1

	je: class InstructionJE extends Instruction
		name: "je"
		exec: ->
			if @flags.zero then @op1.get() else @addr+1

	jnl: class InstructionJNL extends InstructionJGE
		name: "jnl"

	jnle: class InstructionJNLE extends InstructionJG
		name: "jnle"

	jng: class InstructionJNG extends InstructionJLE
		name: "jng"

	jnge: class InstructionJNGE extends InstructionJL
		name: "jnge"

	jne: class InstructionJNE extends Instruction
		name: "jne"
		exec: ->
			if !@flags.zero then @op1.get() else @addr+1

	hlt: class InstructionHLT extends Instruction
		name: "hlt"
		exec: ->
			throw new Errors.HLTError(@addr)