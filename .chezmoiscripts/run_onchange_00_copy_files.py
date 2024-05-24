#!/usr/bin/env python3

import logging
from pathlib import Path
import importlib.util

if importlib.util.find_spec("xdg_base_dirs") and importlib.util.find_spec("plumbum"):
  from xdg_base_dirs import xdg_state_home, xdg_data_home
  from plumbum.cmd import rsync

  logger = logging.getLogger(__name__)
  logging.basicConfig(filename=xdg_state_home().joinpath("chezmoi.log"))

  sync_bin_cmd = rsync["-avzPh",f"{xdg_data_home()}/automation/dasbootstrap/bin/",f"{Path.home()}/.local/bin/"]
  logger.info(sync_bin_cmd())
  sync_lib_cmd = rsync["-avzPh",f"{xdg_data_home()}/automation/dasbootstrap/lib/",f"{Path.home()}/.local/lib/"]
  logger.info(sync_lib_cmd())
  sync_ansible_cmd = rsync["-avzPh", "--exclude",".git/"
    f"{xdg_data_home()}/automation/dasbootstrap/ansible/",f"{Path.home()}/.ansible/"]
  logger.info(sync_ansible_cmd())
else:
  logging.warn("onchange script failed due to missing imports.  If this is an initial setup then this is expected behavior")