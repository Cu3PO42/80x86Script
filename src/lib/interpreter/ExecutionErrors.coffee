define [], ->
	HLTError: class HLTError extends Error
		constructor: (@addr) ->
		name: "HLTError"
		notification: "Your program has executed successfully."

	InvalidAddressError: class InvalidAddressError extends Error
		constructor: ->
		name: "InvalidAddressError"
		notification: "This address is invalid."

	BRKError: class BRKError extends Error
		constructor: ->
		name: "BRKError"
		notification: "You have reached a breakpoint."

	ReadOnlyError: class ReadOnlyError extends Error
		constructor: ->
		name: "ReadOnlyError"
		notification: "Addresses are read only."