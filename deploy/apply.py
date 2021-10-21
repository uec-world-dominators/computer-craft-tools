from pathlib import Path
import argparse
import os.path
import glob
import shutil
import os
from typing import List

parser = argparse.ArgumentParser()
parser.add_argument('--dir', '-d', help='computer directory')
parser.add_argument('--targets', '-t', nargs='+',
                    help='computer ids, disk', default=[])
parser.add_argument('--files', '-f', nargs='+', help='files to sync')
args = parser.parse_args()


files = [x
         for pattern in args.files
         for x in glob.glob(pattern)
         ]


def apply():
    for target in args.targets:
        path = os.path.join(args.dir, target)
        for file in files:
            if os.path.isdir(file):
                shutil.copytree(file, path)
            else:
                shutil.copy(file, path)


def copy_files(prefix: str, files: List[str], dest_dir: str):
    if os.path.isdir(prefix):
        prefix = os.path.join(prefix, '')
    else:
        raise RuntimeError('prefix is not directory')

    for file in files:
        if not Path(file) in Path(prefix):
            raise RuntimeError(f'`{file}` not in `{prefix}`')

        if os.path.isdir(file):
            shutil.copytree(file, os.path.join(dest_dir, file))
        else:
            shutil.copy(file, os.path.join(dest_dir, file))
