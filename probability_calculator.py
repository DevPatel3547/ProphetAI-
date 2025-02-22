from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
from scipy.stats import binom
import numpy as np

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes

def coin_probability():
    return 0.5

def dice_probability():
    return 1/6

def lottery_probability():
    return 1/292_000_000

@app.route('/calculate', methods=['POST'])
def calculate_probability():
    data = request.json
    event = data.get("event", "").lower()

    if "coin" in event:
        result = coin_probability()
    elif "dice" in event:
        result = dice_probability()
    elif "lottery" in event:
        result = lottery_probability()
    else:
        result = "unknown event"
    return jsonify({"probability": result})

if __name__ == "__main__":
    app.run(port=5000)
