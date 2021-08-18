# -*- coding: UTF-8 -*-

import asyncio
import datetime
import json
import os
import sys

import easyocr
import requests
from loguru import logger
from pyppeteer import launch


XIQU_99_USERNAME = os.environ.get('XIQU_99_USERNAME') or None
XIQU_99_PASSWORD = os.environ.get('XIQU_99_PASSWORD') or None


def get_verification_code(img_obj_path):
    with open(img_obj_path, 'rb') as f:
        img_obj = f.read()
        reader = easyocr.Reader(['en'])
        ocr_result = reader.readtext(img_obj, detail=0)
        verification_code = ''.join([str(item) for item in ocr_result]).strip(' ').replace(' ', '')

        verification_code = verification_code.replace('+', 'x')
        if len(verification_code) != 4:
            return None
        return verification_code


def run_once():
    today = datetime.datetime.now().strftime('%Y-%m-%d')
    if not os.path.exists('./once.lock'):
        with open('./once.lock', 'w', encoding='utf-8') as f:
            f.write(today)
            logger.warning(f'>>> today: {today} - Bye ~')
            sys.exit()
    else:
        with open('./once.lock', 'r', encoding='utf-8') as f:
            lock_today = f.read()
            if today == lock_today:
                logger.warning(f'>>> today: {today} - {lock_today} - Bye ~')
                sys.exit()
    logger.info(f'>>> today: {today} - Run login ~')


async def main():
    if XIQU_99_USERNAME is None or XIQU_99_PASSWORD is None:
        logger.error('>>> the XIQU_99_USERNAME or XIQU_99_PASSWORD is none, please check again ...')
        sys.exit()
    else:
        run_once()

    # browser = await launch(headless=True, userDataDir='./userdata')
    browser = await launch(headless=True, path="/usr/bin/chromium-browser", args=["--no-sandbox"])
    page = await browser.newPage()
    await page.setViewport({'width': 1920, 'height': 1080})
    await page.goto('http://www.xiqu99.com/member/login/')
    await page.evaluateOnNewDocument('() =>{ Object.defineProperties(navigator,' '{ webdriver:{ get: () => false } }) }')
    await asyncio.sleep(2)

    code_img = await page.waitForSelector('#loginn > p:nth-child(3) > img')
    await code_img.screenshot({'path': './xiqu.png'})
    await asyncio.sleep(2)

    logger.info(f'>>> Begin to identify ...')
    code_text = get_verification_code('./xiqu.png')
    logger.debug(f'>>> The verification code: {code_text} ...')
    await asyncio.sleep(2)

    if not code_text is None:
        logger.info(f'>>> To login ...')
        await page.type('#login_user', XIQU_99_USERNAME)
        await page.type('#loginn > p:nth-child(2) > input', XIQU_99_PASSWORD)
        await page.type('#loginn > p:nth-child(3) > input', code_text)
        await asyncio.sleep(2)
        await page.click('#loginn > p:nth-child(4) > input.reg')
        logger.info(f'>>> Click login ...')
        await asyncio.sleep(5)
    else:
        logger.error('>>> Oops!')
        await browser.close()
        sys.exit()

    fen_value = None
    logger.info(f'>>> To get the points ...')
    await page.goto('http://www.xiqu99.com/member/user/')
    fen_elements = await page.Jx('//*[@id="user_right"]/table/tbody/tr[7]/td[2]')
    for item in fen_elements:
        fen_value = await (await item.getProperty('textContent')).jsonValue()
        if fen_value is not None:
            logger.info(f'>>> Login successful ...')
            fen_value = fen_value.strip(' ').replace('\xa0+2\xa0\xa0(积分永远有效用完为止)立即充值', '')
            logger.debug(f'>>> The remaining points: {fen_value}')
        else:
            logger.error(f'>>> Login failed ...')
    await asyncio.sleep(3)

    try:
        fen_value = int(fen_value)
        with open('./once.lock', 'w', encoding='utf-8') as f:
            today = datetime.datetime.now().strftime('%Y-%m-%d')
            f.write(today)
            logger.info(f'>>> Date written successfully ...')
            logger.info(f'>>> today: {today} - End ~')
    except ValueError:
        logger.error(f'>>> Failed to obtain points ...')

    await browser.close()
    sys.exit()


if __name__ == '__main__':
    logger.add("xiqu_99.log")
    asyncio.get_event_loop().run_until_complete(main())
