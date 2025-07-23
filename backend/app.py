from flask import Flask, jsonify
from flask_cors import CORS
import random

app = Flask(__name__)
CORS(app)

quotes = [
    "You miss 100% of the shots you don’t take.",
    "Stay hungry, stay foolish.",
    "Whether you think you can or you can’t, you’re right."
]

@app.route('/quote', methods=['GET'])

def get_quote():
    return jsonify({'quote': random.choice(quotes)})

if __name__ == '__main__':
    app.run(debug=True)
