import os
import sys

extensions = [
".xml", ".java", ".py", ".as"
]

def is_hidden(path):
    return path.startswith(".")

def patchable(abs_path):
    path, extension = os.path.splitext(abs_path)
    return extension in extensions

def patch_file(abs_path):
    if not patchable(abs_path):
        print "** skipping file: ", abs_path
        return

    print "** patching file: ", abs_path
    f = open(abs_path, "r")
    contents = f.read()
    f.close()
    contents = contents.replace("\t", "    ")
    lines = contents.split('\n')
    lines = [line.rstrip() for line in lines]
    contents = "\n".join(lines)
    f = open(abs_path, "w")
    f.write(contents)
    f.close()

def patch_directory(path):
    print "** patching directory: ", path
    for filename in os.listdir(path):
        if not is_hidden(filename):
            abs_path = os.path.join(path, filename)
            if os.path.isdir(abs_path):
                patch_directory(abs_path)
            else:
                patch_file(abs_path)

if __name__ == "__main__":
    if not len(sys.argv) > 1:
        print "* expect file directory as argument"
        sys.exit(1)
    elif not os.path.exists(sys.argv[1]) or not os.path.isdir(sys.argv[1]):
        print "* ", sys.argv[1], " is not a valid directory"
        sys.exit(1)

    path = sys.argv[1]
    print "* patching: ", path
    patch_directory(path)
