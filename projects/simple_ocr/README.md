# SimOCR

---

**光学字符识别(`OCR`)**已经成为一种常见的 `Python` 工具。随着诸如 `Tesseract` 和 `Ocrad` 这样第三方库的出现，越来越多的开发人员正在构建以新颖、有趣的方式使用 `OCR`，而 `pytesseract` 就是其中最为突出的那个。

我们这个项目将使用 `Flask` 作为后端框架，提供了在 `Web` 界面上生成 `HTML` 表单，并添加一些前端代码来进行 `API` 调用而获得后端识别之后的 `OCR` 图片对应的识别结果。

```bash
# 命令方式测试
$ curl -X POST http://localhost:5000/v1/ocr \
     -d '{"image_url": "http://www.quiz-server.com/nazonazo/wp-content/uploads/2017/01/pic_quiz74-1024x492.png"}' \
     -H "Content-Type: application/json"

# 测试输出结果
{
  "output": "ABCDE\nFGH I J\nKLMNO\nPQRST"
}
```

---

https://realpython.com/setting-up-a-simple-ocr-server/
https://github.com/ybur-yug/python_ocr_tutorial
https://github.com/madmaze/pytesseract
http://www.quiz-server.com/nazonazo/wp-content/uploads/2017/01/pic_quiz74-1024x492.png
