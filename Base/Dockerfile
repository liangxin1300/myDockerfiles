FROM opensuse/tumbleweed

WORKDIR /app

COPY . /app

RUN zypper -n install python3

CMD ["python3", "app.py"]
