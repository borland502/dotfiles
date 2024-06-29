#!/usr/bin/env python3
import os
from pathlib import Path

import xdg_base_dirs
from dotenv import load_dotenv

# adjust python shell path as by default the commands will be run non-interactively.  This is important for shell cmds
os.environ["PATH"] = ":".join([f"{Path.home()}/.local/bin", f"{os.environ['PATH']}"])
load_dotenv(
    dotenv_path=Path.home().joinpath(".env"),
    interpolate=True,
    override=True,
    encoding="utf-8",
)


# Validate XDG variables and correct if necessary
def validate_xdg_folders():
    # TODO: Learn formatting
    for xdg_func in [func for func in vars(xdg_base_dirs) if func.startswith("xdg")]:
        path: Path = getattr(xdg_base_dirs, xdg_func)()

        # some xdg vars are lists of paths
        if isinstance(path, Path):
            print(
                f"XDG variable {xdg_func.upper()} at {path.name} exists? {str(path.exists()).lower()}"
            )


# Validate path

# Validate taskfiles
validate_xdg_folders()
