

proc getAllFilesOfDiretory(dir: string): seq[string] =
  # todo: make work
  let path = ABSOLUTE_PATH & dir
  let files: seq[string]= @[]
  for kind, path in walkDir(path):
    case kind:
    of pcFile:
      echo "File: ", path
    of pcDir:
      echo "Dir: ", path
    of pcLinkToFile:
      echo "Link to file: ", path
    of pcLinkToDir:
      echo "Link to dir: ", path
    else:
      echo "Unknown: ", path
  return files