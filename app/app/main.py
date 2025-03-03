from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

try:
    app.config["SQLALCHEMY_DATABASE_URI"] = f'postgresql://{os.environ["PSQL_USER"]}:{os.environ["PSQL_PWD"]}@{os.environ["PSQL_HOST"]}/{os.environ["PSQL_DB"]}'

    db = SQLAlchemy(app)
except:
    pass

@app.route("/")
def hello():
    return "Hello World from Flask"

@app.route("/db")
def test_db():
    db.engine.connect()
    return "DB Connected"


if __name__ == "__main__":
    # Only for debugging while developing
    app.run(host='0.0.0.0', debug=True, port=80)
