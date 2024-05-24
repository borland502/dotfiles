#!/usr/bin/env python
import os
from pathlib import Path

import xdg_base_dirs
from dotenv import load_dotenv
from pykeepass import create_database, PyKeePass

KEEPASS_DB_PATH: str = f"{Path.home()}/.local/share/keepass/secrets.kdbx"
KEEPASS_DB_KEY: str = f"{Path.home()}/.config/keepass/key.txt"
KEEPASS_DB_TOKEN: str = f"{Path.home()}/.local/state/keepass/keepass_token"

# adjust python shell path as by default the commands will be run non-interactively.  This is important for shell cmds
os.environ["PATH"] = ":".join([f"{Path.home()}/.local/bin", f"{os.environ['PATH']}"])
load_dotenv(dotenv_path=Path.home().joinpath(".env"), interpolate=True, override=True, encoding="utf-8")


# from plumbum.cmd import has, chezmoi, zsh

# Validate expected executables
# print(f"{has('pipx')}{has('fzf')}")
# def initialize_poetry() -> None:


# Initialize secrets database if not already present
def create_kp_database() -> None | PyKeePass:
  """Create a new keepass vault in the KEEPASS_DB_PATH, with the KEEPASS_DB_KEY, and KEEPASS_DB_TOKEN."""

  kp_path: Path = Path(KEEPASS_DB_PATH)
  if not kp_path.is_file():
    # make the directory at least if the database does not exist
    kp_path.parent.mkdir(mode=0o700, exist_ok=True, parents=True)
  else:
    # database exists
    return None

  # Token and key must exist in the target destinations ahead of time
  kp_token: Path = Path(KEEPASS_DB_TOKEN)
  if not kp_token.is_file():
    # make the directory at least if the database does not exist
    kp_token.parent.mkdir(mode=0o700, exist_ok=True, parents=True)
    raise FileNotFoundError(f"Token file not found in path {kp_token}")

  kp_key: Path = Path(KEEPASS_DB_KEY)
  if not kp_key.is_file():
    # make the directory at least if the database does not exist
    kp_key.parent.mkdir(mode=0o700, exist_ok=True, parents=True)
    raise FileNotFoundError(f"Key file not found in path {kp_key}")

  return create_database(KEEPASS_DB_PATH, KEEPASS_DB_TOKEN, KEEPASS_DB_KEY)


# Validate XDG variables and correct if necessary
def validate_xdg_folders():
  # TODO: Learn formatting
  for xdg_func in [func for func in vars(xdg_base_dirs) if func.startswith("xdg")]:
    path: Path = getattr(xdg_base_dirs, xdg_func)()

    # some xdg vars are lists of paths
    if isinstance(path, Path):
      print(f"XDG variable {xdg_func.upper()} at {path} exists? {str(path.is_dir()).lower()}")
    else:
      print(f"XDG variable {xdg_func.upper()} with")
      for resolved_path in [s_path for s_path in path]:
        print(f"{resolved_path!s:<60} path exists? {str(resolved_path.is_dir()).lower()}")
        if not resolved_path.is_dir():
          resolved_path.mkdir(mode=0o700, parents=True)


# Validate path

# Validate taskfiles

create_kp_database()
validate_xdg_folders()
