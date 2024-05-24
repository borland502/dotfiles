#!/usr/bin/env python

import logging
from xdg_base_dirs import xdg_state_home

logger = logging.getLogger(__name__)
logging.basicConfig(filename=xdg_state_home().joinpath("chezmoi.log"))
