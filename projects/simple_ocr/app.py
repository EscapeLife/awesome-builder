import logging
import os
from logging import FileHandler, Formatter

from flask import Flask, jsonify, render_template, request

from ocr import process_image


_VERSION = 1
_IMAGE_TYPE = ['jpg', 'png']


app = Flask(__name__)


@app.route('/')
def main():
    return render_template('index.html')


@app.route('/v{}/ocr'.format(_VERSION), methods=["POST"])
def ocr():
    try:
        url = request.json['image_url']
        if 'png' in url:
            output = process_image(url)
            return jsonify({"output": output})
        else:
            return jsonify({"error": "only .jpg files, please"})
    except:
        return jsonify({"error": "Did you mean to send: {'image_url': 'some_jpeg_url'}"})


@app.errorhandler(500)
def internal_error(error):
    print(str(error))


@app.errorhandler(404)
def not_found_error(error):
    print(str(error))


if not app.debug:
    file_handler = FileHandler('error.log')
    file_handler.setFormatter(
        Formatter('%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]')
    )
    app.logger.setLevel(logging.INFO)
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
    app.logger.info('errors')


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
