import sys
import os
from zipfile import ZipFile

foldername = os.path.relpath(sys.argv[1], ".")
with ZipFile(f'{foldername}.zip', 'w') as package:
    for root, dirs, files in os.walk(foldername):
        print(root, dirs, files)
        for file in files:
            filepath = os.path.join(root, file)
            package.write(
                filepath,
                os.path.join('reframework', "autorun", os.path.relpath(
                    filepath,
                    foldername
                    )))

