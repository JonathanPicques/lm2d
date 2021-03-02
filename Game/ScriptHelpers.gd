class_name ScriptHelpers

# array_join returns a new string by concatenating all of the elements in the given array.
# @pure
static func array_join(array: Array, separator = ",") -> String:
	var joined := ""
	var array_size := array.size()
	for i in range(0, array_size):
		joined += String(array[i])
		if i < array_size - 1:
			joined += separator
	return joined

# enum_join returns a new string by concatenating all of the names in the given enum.
# @pure
static func enum_join(enumeration, separator := ",") -> String:
	var keys = enumeration.keys()
	var joined := ""
	var enum_size: int = keys.size()
	for i in range(0, enum_size):
		var key = keys[i]
		joined += key
		if i < enum_size - 1:
			joined += separator
	return joined

# dic_int_join returns a new string by concatenating all of the names and indexes in the given dictionary.
# @pure
static func dic_int_join(dictionary: Dictionary, separator := ",") -> String:
	var keys := dictionary.keys()
	var joined := ""
	var dictionary_size := keys.size()
	for i in range(0, dictionary_size):
		var key = keys[i]
		joined += String(key + ":" + String(i))
		if i < dictionary_size - 1:
			joined += separator
	return joined

# dic_string_join returns a new string by concatenating all of the names in the given dictionary.
# @pure
static func dic_string_join(dictionary: Dictionary, separator := ",") -> String:
	var keys := dictionary.keys()
	var joined := ""
	var dictionary_size := keys.size()
	for i in range(0, dictionary_size):
		joined += keys[i]
		if i < dictionary_size - 1:
			joined += separator
	return joined
