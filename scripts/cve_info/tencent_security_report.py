import functools
import operator
import sqlite3
import sys

import click
import requests
from bs4 import BeautifulSoup
from loguru import logger
from prettytable import PrettyTable

URL = 'https://s.tencent.com/research/bsafe/'
USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36'


def _convert_tuple(tup):
    return functools.reduce(operator.add, (tup))


def _execute_sqlite_db(sql):
    try:
        conn = sqlite3.connect('tencent_security.db')
        c = conn.cursor()
        if "SELECT" in sql:
            ret = c.execute(sql).fetchall()
            return ret
        c.execute(sql)
        conn.commit()
        conn.close()
    except sqlite3.OperationalError:
        logger.error('Table vulnerability already exists, please check ...')
        sys.exit()
    except sqlite3.IntegrityError:
        logger.error('UNIQUE constraint failed: vulnerability.link ...')
        sys.exit()


def init_sqlite_db():
    _execute_sqlite_db(
        "CREATE TABLE vulnerability( \
            id     INTEGER    PRIMARY KEY  AUTOINCREMENT, \
            title  CHAR(100)  NOT NULL, \
            link   CHAR(150)  NOT NULL UNIQUE);")
    logger.debug('Database table structure initialized successfully ...')


def get_tencent_security_info():
    title_news_list = []
    headers = {'User-Agent': USER_AGENT, 'Accept-Encoding': 'utf-8'}
    response = requests.get(URL, headers=headers)
    response.encoding = 'utf-8'

    soup = BeautifulSoup(response.text, 'html.parser')
    page_news_list = soup.select('div > h3 > a')
    for title_new in page_news_list:
        title_name = title_new.string.strip()
        title_link = 'https://s.tencent.com/' + title_new['href']
        title_news_list.append((title_name, title_link))
    return title_news_list


def insert_security_info(infos_list):
    logger.debug('The initialization vulnerability data has been inserting ...')
    for title, link in infos_list:
        logger.info(f"The [{title}] insert to db ...")
        _execute_sqlite_db(
            "INSERT INTO vulnerability (title, link) VALUES ('%s', '%s');" % (title, link))
    logger.debug('The initialization vulnerability data has been inserted successfully ...')


def check_news_to_remind(infos_list):
    logger.debug('Begin updating server vulnerability information ...')
    link_new_tuple = _execute_sqlite_db("SELECT link FROM vulnerability limit 8;")
    link_new_list = _convert_tuple(link_new_tuple)
    for title, link in infos_list:
        if link not in link_new_list:
            logger.info(f"The [{title}] is lastest new, then insert to db and send msg ...")
            _execute_sqlite_db(
                "INSERT INTO vulnerability (title, link) VALUES ('%s', '%s')" % (title, link))
    logger.debug('Server vulnerability information update completed ...')


def display_tencent_security_info():
    logger.debug('Displays the latest version of the server vulnerability information ...')
    pt = PrettyTable()
    pt.field_names = ["id", "title", "link"]
    tencent_security_info = _execute_sqlite_db(
        "SELECT id, title, link FROM vulnerability limit 8;")
    for sql_line in tencent_security_info:
        pt.add_row(sql_line)
    print(pt.get_string())


@click.command()
@click.option('--init', is_flag=True, help='initialize the sqlite database')
@click.option('--check', is_flag=True, help='check the most real-time threat intelligence')
@click.option('--display', is_flag=True, help='displays the latest vulnerability list information')
def main(init, check, display):
    if init:
        init_sqlite_db()
        infos_list = get_tencent_security_info()
        insert_security_info(infos_list)
    if check:
        infos_list = get_tencent_security_info()
        check_news_to_remind(infos_list)
    if display:
        display_tencent_security_info()


if __name__ == '__main__':
    main()
