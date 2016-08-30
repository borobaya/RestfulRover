#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
from datetime import datetime

logging.basicConfig(filename='logs/rover'+datetime.today().strftime('%Y%m%d')+'.log',
    level=logging.INFO, format='%(asctime)s %(levelname)s: %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
logger = logging.getLogger('RestfulRover')

def info(msg):
    msg = str(msg)
    logger.info(msg)

def warning(msg):
    msg = str(msg)
    logger.warning(msg)

def debug(msg):
    msg = str(msg)
    logger.debug(msg)

def error(msg):
    msg = str(msg)
    logger.error(msg)

def critical(msg):
    msg = str(msg)
    logger.critical(msg)
