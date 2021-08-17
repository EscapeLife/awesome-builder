import functools
import json
import operator
import sqlite3
import sys

import requests
from apscheduler.schedulers.blocking import BlockingScheduler
from bs4 import BeautifulSoup
from loguru import logger

TENCENT_URL = 'https://s.tencent.com/research?page=1&id=18'
USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36'

MATTERMOST_URL = ''
PAYLOAD = {
    "username": "CI",
    "channel": "escape",
    "icon_url": ""
}


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
    except sqlite3.OperationalError:
        logger.error('Table vulnerability already exists, please check ...')
        logger.error(f'SQL: {sql} ...')
        sys.exit()
    except sqlite3.IntegrityError:
        logger.error('UNIQUE constraint failed: vulnerability.link ...')
        logger.error(f'SQL: {sql} ...')
        sys.exit()
    finally:
        conn.close()


def send_msg_mm(channel, title, link):
    PAYLOAD.update({"channel": f"{channel}"})
    PAYLOAD.update({"text": f":robot: **[腾讯安全漏洞提示]** - [{title}]({link})"})
    r = requests.post(MATTERMOST_URL, data=json.dumps(PAYLOAD))
    if r.status_code == 200:
        logger.debug('Send vulnerability info to mattermost successfully ...')
    else:
        logger.error('Send vulnerability info to mattermost failed ...')


def init_sqlite_db():
    _execute_sqlite_db(
        "CREATE TABLE vulnerability( \
            id     INTEGER    PRIMARY KEY  AUTOINCREMENT, \
            title  CHAR(100)  NOT NULL, \
            link   CHAR(150)  NOT NULL);")
    logger.debug('Database table structure initialized successfully ...')


def get_tencent_security_info():
    title_news_list = []
    headers = {'User-Agent': USER_AGENT, 'Accept-Encoding': 'utf-8'}
    response = requests.get(TENCENT_URL, headers=headers)
    response.encoding = 'utf-8'

    soup = BeautifulSoup(response.text, 'html.parser')
    page_news_list = soup.select('h3.twoline.leading-26px.mt-18px.text-xl')
    for title_new in page_news_list:
        title_name = title_new.string.strip()
        title_link = TENCENT_URL
        title_news_list.append((title_name, title_link))
    return title_news_list[::-1]


def insert_security_info(infos_list):
    logger.debug('The initialization vulnerability data has been inserting ...')
    for title, link in infos_list:
        logger.info(f"The [{title}] insert to db ...")
        _execute_sqlite_db("INSERT INTO vulnerability (title, link) VALUES ('%s', '%s');" % (title, link))
    logger.debug('The initialization vulnerability data has been inserted successfully ...')


def check_news_to_remind(infos_list):
    logger.debug('Begin updating server vulnerability information ...')
    title_new_tuple = _execute_sqlite_db("SELECT title FROM vulnerability ORDER BY link DESC limit 32;")
    title_new_list = list(_convert_tuple(title_new_tuple))
    for title, link in infos_list:
        if title not in title_new_list:
            logger.info(f"The [{title}] is lastest new, then insert to db and send msg ...")
            _execute_sqlite_db("INSERT INTO vulnerability (title, link) VALUES ('%s', '%s')" % (title, link))
            send_msg_mm("@escape", title, link)
    logger.debug('Server vulnerability information update completed ...')


def main():
    infos_list = get_tencent_security_info()
    check_news_to_remind(infos_list)


if __name__ == '__main__':
    init_sqlite_db()
    infos_list = get_tencent_security_info()
    insert_security_info(infos_list)

    scheduler = BlockingScheduler(timezone="Asia/Shanghai")
    # scheduler.add_job(main, 'interval', seconds=60)
    scheduler.add_job(main, "cron", hour=8, minute=30, second=00)

    try:
        logger.warning('Press Ctrl+C to exit ...')
        scheduler.start()
    except (KeyboardInterrupt, SystemExit):
        logger.warning('Bye bye ...')
        send_msg_mm("@escape", "异常退出请处理", "")
        scheduler.shutdown()
