FROM python:3-alpine

ENV TZ=Asia/Shanghai

WORKDIR /opt/cve_report

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY tencent_security_report.py .

CMD [ "python", "./tencent_security_report.py" ]
