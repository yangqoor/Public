#!/usr/bin/env python
# coding: utf-8
import sys
from typing import Sequence, Union
import os
import time

import logging

logger_ = logging.getLogger('__main__')


def get_collection(client, collection_name, database_name='crawl'):
    """
    get collection from db by collection name
    return collection cursor
    """
    db = client[database_name]
    return db[collection_name]


def log_wrapper(logger: logging.Logger, handler: logging.Handler = None,
                formatter: logging.Formatter = None, log_path: str = None, base_dir: str = None) -> None:
    """
    custom logger object support: change output stream and output format
    instructions about change output and format on logging officiate:
    https://docs.python.org/3/library/logging.html
    """
    if not handler:
        if log_path:
            if not os.path.exists(log_path):
                logging.info("{log_name} don't exist. create it by default")
                base_dir_ = os.path.dirname(log_path)
                os.mkdir(base_dir_)
        else:
            time_ = time.strftime('%y%B')
            suffix = time_ + '.log'
            base_dir = base_dir if base_dir else 'log/'
            if not os.path.exists(base_dir):
                os.makedirs(base_dir)
            log_path = os.path.join(base_dir, suffix)

        handler = logging.FileHandler(log_path)
    if not formatter:
        formatter = logging.Formatter("%(asctime)s - %(funcName)s  - %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)


def dir_existed(path: Union[str, Sequence[str]]) -> bool:
    """
    check whether path is existed if not
    create it
    @param path:
    @return: None
    """
    if isinstance(path, str):
        if not os.path.exists(path):
            os.makedirs(path)
    elif isinstance(path, Sequence):
        for _path in path:
            if not os.path.exists(_path):
                os.makedirs(_path)
    else:
        raise TypeError


def verify_path(path: str, sub_name: str) -> str:
    """
    verify if path is valid
    :param
    path:
    sub_name: sub name for path
    :return:
    """
    if path:
        base_dir = os.path.join(path, sub_name)
        dir_existed(base_dir)
    else:
        logger_.info("Don't give base directory")
        cur_path = os.path.dirname(sys.argv[0])
        base_dir = os.path.join(cur_path, sub_name)
        logger_.info(f"Create path_ as default")
        dir_existed(base_dir)
    return base_dir


def timestamp():
    return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())


