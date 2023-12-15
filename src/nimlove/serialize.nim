import std/[strutils,strformat, tables]
import ../nimlove


# Serialisiering machen wir mit json.
# das heißt wir machen für jedes feld ein {}
# und dann parse wir da seinfach und je nah dem was 
# für ein type dort steht damit parsemn wir das 
# und die parse-functions muss man dann als unserializeCallback hinterlegen


# DIe serialisierung soll im grunde den nuter in kontrolle lassen


var unSerializeCallbackTable*
    : Table[string, proc(fields: Table[string, string])] 
    = initTable[string, proc(fields: Table[string, string])]()

proc readReprLine*(line: string) = 
    let name = line.split("(")[0]  
    let rawFields = line.split("(")[1].split(")")[0].split(", ")
    var fields = initTable[string, string]()
    for raw_field in raw_fields:
        let field = raw_field.split(":")
        fields[field[0]] = field[1]
    let callbackExists = unSerializeCallbackTable.hasKey(name)
    if callbackExists:
        unSerializeCallbackTable[name](fields)
    else:
        echo "Repr callback for ", name, " not found!"
        echo "Igoring line: ", line
    unSerializeCallbackTable[name](fields)

proc assembleOutputString*(fields: Table[string, string]): string =
    # todo: check that name does not contain any of the following: (, ), :, ", \n or space
    result = ""
    assert fields.hasKey("__type__")
    assert fields.hasKey("__version__")
    result.add(fields["__type__"])
    result.add("(")
    for key, value in fields:
        result.add(key)
        result.add(":")
        result.add(value)
        result.add(", ")
    result.add(")")
    return result


# TODO: add the repr procs here ... 

proc unSerializeFloat*(s: string): float =
  return parseFloat(s)

proc serialize*(f: float): string =
  return $f

proc unSerializeInt*(s: string): int =
  return parseInt(s)

proc serialize*(i: int): string =
    return $i

proc unSerializeBool*(s: string): bool =
  return parseBool(s)

proc serialize*(b: bool): string =
    return $b

proc unSerializeString*(s: string): string =
  assert s[0] == '$'
  var rawString = s[1..s.len-1]
  rawString = rawString
    .replace("__quote__", "\"")
    .replace("__newline__", "\n")
    .replace("__COLON__", ":")
    .replace("__BRACE_OPEN__", "(")
    .replace("__BRACE_CLOSED__", ")")
    .replace("__COMMA__", ",")
    .replace("__DOLLAR__", "$")
  return rawString

proc serialize*(s: string): string =
    var result = "$"
    result.add(
      s
        .replace("\"", "__quote__")
        .replace("\n", "__newline__")
        .replace(":", "__COLON__")
        .replace("(", "__BRACE_OPEN__")
        .replace(")", "__BRACE_CLOSED__")
        .replace(",", "__COMMA__")
        .replace("$", "__DOLLAR__")
    )
    return result

#TODO: add proc that puts the results into a file and reads from a file ... 

###
## Move to color ... 
###
proc serialize*(c: Color): string =
  result = fmt"nimlove.Color({c.int})"

proc unSerializeColor*(s: string): Color =
  let intAsS = s.replace("nimlove.Color(", "").replace(")", "")
  result = Color(intAsS.parseInt())


proc serialize*[T1, T2](table: tables.Table[T1, T2]): string = 
  result = ""
  result.add("Table[")

  for key, value in table:
    result.add("TablePair[")
    result.add(serialize key )
    result.add(", ")
    result.add(serialize value )
    result.add("], ")

  result.add("]")
  return result

proc unserializeTable*[T1, T2](
  s: string, 
  unserializeKey: proc(s: string): T1, 
  unserializeValue: proc(s: string): T2
  ): Table[T1, T2] =
  let rawTable = s.replace("[", "").replace("]", "").split("), ")
  var result = initTable[T1, T2]()
  for rawEntry in rawTable:
    let entry = rawEntry.replace("(", "").replace(")", "").split(", ")
    result[unSerializeKey entry[0]] = unSerializeValue entry[1]
  return result

## todo: serialize tuples and lists ...