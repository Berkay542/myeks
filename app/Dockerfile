FROM tiangolo/uwsgi-nginx-flask:python3.6-alpine3.7
WORKDIR /app
RUN apk add --no-cache \
    postgresql-dev gcc python3-dev musl-dev build-base \
    && pip install --upgrade pip

COPY requirements.txt .  
RUN pip install --no-cache-dir -r requirements.txt  
COPY ./app /app  
ENV LISTEN_PORT 8080

EXPOSE 8080

CMD ["python", "main.py"]
