# app.py
from flask import Flask, jsonify
import requests

app = Flask(__name__)

@app.route("/")
def get_joke():
    headers = {
        'Accept': 'application/json',
        'User-Agent': 'Jackie Chan Joke App (https://github.com/grbod/chucknorris)'
    }
    response = requests.get("https://icanhazdadjoke.com/", headers=headers)
    joke_data = response.json()
    joke = joke_data.get("joke", "No joke found.")
    return jsonify({"joke": joke})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

# wsgi.py
from app import app

if __name__ == "__main__":
    app.run()

