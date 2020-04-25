from io import StringIO

import requests
from PIL import Image, ImageFilter
from pytesseract import image_to_string


def _get_image(url):
    return Image.open(StringIO(requests.get(url).content))


def process_image(url):
    image = _get_image(url)
    image.filter(ImageFilter.SHARPEN)
    return image_to_string(image)
    print(image_to_string(image))
